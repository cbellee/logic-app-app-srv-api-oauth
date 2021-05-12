# set your AAD tenantID
$aadTenantId = "3d49be6f-6e38-404b-bbd4-f61c1a2d25bf"
$rgName = 'logic-app-rg'
$deploymentName = 'my-logic-app-deployment'
$appName = 'go-web-api-test'

# get deployment
$deployment = Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name $deploymentName
$mid = Get-AzADServicePrincipal -DisplayNameBeginsWith $deployment.Outputs.logicAppName.value

# app role
$permissionsToAdd = "Api.Call"

# App Service app registration
$app = Get-AzADApplication -DisplayName $appName

# authN to Azure AD
Connect-AzureAD -TenantId $aadTenantId

# get the App Service app registration's associated Service Principal object
$sp = Get-AzureADServicePrincipal -Filter "AppId eq '$($app.ApplicationId)'"

# add Logic App's Managed Identity to the Web app's app registration app role
foreach ($permission in $permissionsToAdd)
{
   $role = $sp.AppRoles | Where-Object Value -Like $permission | Select-Object -First 1
   New-AzureADServiceAppRoleAssignment -Id $role.Id -ObjectId $mid.Id -PrincipalId $mid.Id -ResourceId $sp.Id
}
