$location = 'australiaeast'
$aadTenantId = '3d49be6f-6e38-404b-bbd4-f61c1a2d25bf'
$rgName = 'logic-app-rg'
$deploymentName = 'my-logic-app-deployment'
$appName = 'go-web-api-test'

az login --tenant $aadTenantId
az bicep build --file ./api.bicep

$rg = New-AzResourceGroup -Name $rgName -Location $location -Force

# Create an application role of given name and description
Function CreateAppRole([string] $Name, [string] $Description)
{
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

# create application registration and app role
$role = CreateAppRole -Name "Api.Call" -Description "Api.Call Application Role"
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
    -webApiName 'cbellee-go-web-api' `
    -webApiPath 'api/v1/report' `
    -logicAppName 'cbellee-logic-app' `
    -appServicePlan 'cbellee-alliance-asp' `
    -containerImage 'belstarr/go-web-api:v1.0'

# you'll now need to manually enable managed identity for the logic app in the portal
https://docs.microsoft.com/en-us/azure/logic-apps/create-managed-service-identity#enable-managed-identity

# next, run 2-addAppRolePermission.ps1 script
