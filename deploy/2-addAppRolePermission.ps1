#Requires –Modules Az, AzureAD

# set your AAD tenantID
$aadTenantId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
$suffix = 'jwf8w9'
$appName = "web-api-$suffix"
$rgName = "$appName-rg"
$deploymentName = "$appName-deployment"

# get previous deployment output
$deployment = Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name $deploymentName
$mid = Get-AzADServicePrincipal -DisplayNameBeginsWith $deployment.Outputs.logicAppName.value

# app role name
$permissionsToAdd = "Api.Call"

# get App Service app registration
$app = Get-AzADApplication -DisplayName $appName

# auth to Azure AD
Connect-AzureAD -TenantId $aadTenantId

# get the App Service app registration's associated Service Principal object
$sp = Get-AzureADServicePrincipal -Filter "AppId eq '$($app.ApplicationId)'"

# add Logic App's Managed Identity to the Web app's app registration app role
foreach ($permission in $permissionsToAdd)
{
   $role = $sp.AppRoles | Where-Object Value -Like $permission | Select-Object -First 1
   New-AzureADServiceAppRoleAssignment -Id $role.Id -ObjectId $mid.Id -PrincipalId $mid.Id -ResourceId $sp.Id
}
