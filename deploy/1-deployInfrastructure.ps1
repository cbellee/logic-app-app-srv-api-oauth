#Requires –Modules Az, AzureAD

$location = 'australiaeast'
$aadTenantId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
$suffix = 'jwf8w9'
$appName = "web-api-$suffix"
$rgName = "$appName-rg"
$deploymentName = "$appName-deployment"

Function New-AzAppRole([string] $Name, [string] $Description) {
    $appRole = New-Object Microsoft.Open.AzureAD.Model.AppRole
    $appRole.AllowedMemberTypes = New-Object System.Collections.Generic.List[string]
    $appRole.AllowedMemberTypes.Add("Application");
    $appRole.DisplayName = $Name
    $appRole.Id = New-Guid
    $appRole.IsEnabled = $true
    $appRole.Description = $Description
    $appRole.Value = $Name;
    return $appRole
}

# build ARM temaplate from .bicep file
az bicep build --file ./api.bicep

# create resource group
$rg = New-AzResourceGroup -Name $rgName -Location $location -Force

# auth to Azure AD
Connect-AzureAD -TenantId $aadTenantId

# create application registration and app role for backend app services web app
$role = New-AzAppRole -Name "Api.Call" -Description "Api.Call Application Role"
$app = New-AzureADApplication -DisplayName $appName -AppRoles $role

# add app secret
$appPassword = New-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId -CustomKeyIdentifier "AppAccessKey" -EndDate (Get-Date).AddYears(2)

# display app secret
$appPassword.Value

# deploy the infrastructure
New-AzResourceGroupDeployment `
    -Name $deploymentName `
    -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ./api.json `
    -webApiAppId $app.appId `
    -webApiName "web-api-$suffix" `
    -webApiPath 'api/v1/report' `
    -logicAppName "logic-app-$suffix" `
    -appServicePlan "asp-$suffix" `
    -containerImage 'belstarr/go-web-api:v1.0'

$deploymentOutput = Get-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -Name $deploymentName

# enable EasyAuth on web app.
az webapp auth update `
    --name $deploymentOutput.Outputs.webAppName.value `
    --resourcegroup $rg.ResourceGroupName `
    --enabled true `
    --action LoginWithAzureActiveDirectory `
    --aad-client-id $app.AppId `
    --aad-client-secret $appPassword.Value `
    --token-store true `
    --output none

# display Logic App name
$deployment = Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name $deploymentName
"Logic App Name: $($deployment.Outputs.logicAppName.value)"

# you'll now need to manually enable managed identity for the logic app name shown above, in the portal (currently this can't be achieved using an ARM template, PowerShell or CLI...
https://docs.microsoft.com/en-us/azure/logic-apps/create-managed-service-identity#enable-managed-identity

# now run the next script - ./2-addAppRolePermission.ps1
