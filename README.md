# Get-WFPFilters
Get-WFPFilters is a PowerShell function which grabs your Windows Firewall WFP filters and parses out provider data in an easy-to-read object.
<br>
<br>
This function was particularly useful when I was troubleshooting network connectivity issues being caused by the Cloudflare WARP client logic handling Windows Firewall filters.

## Usage

### Get-WFPFilters
To use this function, **ensure you are executing this script as a local administrator**, then simply run Get-WFPFilters, or set a variable to this function's output. Example:
```
$filters = Get-WFPFilters
```

This function will output an object, which will be formatted as follows (converted to JSON for readability):
```
{
  "providerData": {
    "FWPM_PROVIDER_MPSSVC_APP_ISOLATION": {
      "Filters": {
        "InternetClientServer Outbound Default Rule": 2,
        "UWP Default Inbound Block Rule": 2,
        "UWP Default Outbound Block Rule": 2,
        "InternetClient Default Rule": 2,
        "InternetClientServer Inbound Default Rule": 2
      },
      "Count": 10
    },
    ...,
    "total": 1276
}
```
