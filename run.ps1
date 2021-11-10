using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

 
$body = @{}

# Get an access token from the managed identity
$resourceId = "https://management.azure.com"
$identity_endpoint = "{0}?resource={1}&api-version=2019-08-01" -f $Env:IDENTITY_ENDPOINT,$resourceId 
$r = Invoke-RestMethod -Uri $identity_endpoint -Method 'GET' -Headers @{'X-IDENTITY-HEADER' = $Env:IDENTITY_HEADER }

# Call the management rest api (need to determine which permissions are required, test with subscription contributor)
$headers = @{}
$headers.Add("content-type", "application/json")
$headers.Add("authorization", "Bearer $($r.access_token)")

$appConfig = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.AppConfiguration/configurationStores/{2}/listKeyValue?api-version=2019-10-01" -f $Env:SubscriptionId, $Env:ResourceGroup, $Env:AppConfigName
$getVal = Invoke-RestMethod -Uri $appConfig -Method 'POST' -Headers $headers -ContentType 'application/json' -Body '{"key": "MyKey","label": ""}'
$body.Value = $getVal.Value 

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
