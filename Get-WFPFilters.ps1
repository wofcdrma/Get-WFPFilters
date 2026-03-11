Function Get-WFPFilters {

    [OutputType([Object])]

    Param ()

    Begin {

        # initialize objects
        $rawFilters   = $null
        $providerData = @{}
        $totalCounts  = @{}

        try {
            $tempFilePath = (New-TemporaryFile).FullName
            netsh wfp show filters file=$tempFilePath | Out-Null
            $rawFilters = ([xml](Get-Content -Path $tempFilePath -Raw)).wfpdiag.filters.item
            Remove-Item $tempFilePath -ErrorAction SilentlyContinue -Force

            If ($null -eq $rawFilters) {
                throw "rawFilters is null. netsh was likely unable to output the raw filter XML data to a temporary file. Please verify if you are running this script as an administrator."
            }

        } catch {
            throw "Error creating the temporary file to export raw filter XML data from netsh. $_"
        }


    }



    Process {

        # parsing logic

        ForEach ($filter in $rawFilters) {

            $provider_key_raw = $filter.providerKey
            $name_raw         = $filter.displayData.Name

            if ($null -ne $provider_key_raw -and $null -ne $name_raw) {

                $name         = $name_raw.ToString().Trim()
                $provider_key = $provider_key_raw.ToString().Trim()

                if (-not $providerData.ContainsKey($provider_key)) {
                    $providerData[$provider_key] = @{}
                }

                if (-not $providerData[$provider_key].ContainsKey($name)) {
                    $providerData[$provider_key][$name] = 0
                }

                $providerData[$provider_key][$name]++

            }

        }


        # count each provider

        ForEach ($providerEntry in $providerData.GetEnumerator()) {

            $providerKey = $providerEntry.Name
            $nameCounts  = $providerEntry.Value
            $totalCountForProvider = ($nameCounts.Values | Measure-Object -Sum).Sum
            $totalCounts[$providerKey] = $totalCountForProvider

        }


        # sort logic: (number of filters per displayName, descending)

        $main = @{}
        $sortedProviderData = [ordered]@{}
        ForEach ($providerEntry in $providerData.GetEnumerator()) {
            $providerKey = $providerEntry.Name
            $innerHashTable = $providerEntry.Value

            $countForThisProvider = $totalCounts[$providerKey]

            $sortedInnerHashTable = [ordered]@{}
            $innerHashTable.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object { $sortedInnerHashTable[$_.Name] = $_.Value }

            $sortedProviderData[$providerKey]         = @{}
            $sortedProviderData[$providerKey].Filters = $sortedInnerHashTable
            $sortedProviderData[$providerKey].Count   = [int]$countForThisProvider
        }

        $main.total        = ($totalCounts.Values | Measure-Object -Sum).Sum
        $main.providerData = $sortedProviderData

        Write-Output $main

    }

}