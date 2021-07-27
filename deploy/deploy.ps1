$location = 'australiaeast'
$resourceGroupName = 'logic-app-auth-rg'
$appName = 'web-api-app-reg'

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

az bicep build --f ./main.bicep
az bicep build --f ./api.bicep

# auth to Azure AD
Connect-AzureAD -TenantId (Get-AzContext).Tenant.Id

# create application registration and app role for backend web app
if (!($webAppRegistration = Get-AzureADApplication -SearchString $appName)) {
    $appRole = New-AzAppRole -Name "Api.Call" -Description "Api.Call Application Role"
    $webAppRegistration = New-AzureADApplication -DisplayName $appName -AppRoles $appRole
    $webAppServicePrincipal = New-AzADServicePrincipal -ApplicationId $webAppRegistration.AppId -DisplayName $appName -SkipAssignment
    "Created App Name: $appName"
} else {
    $webAppRegistration = Get-AzureADApplication -SearchString $appName 
    $webAppServicePrincipal = Get-AzADServicePrincipal -ApplicationId $webAppRegistration.AppId
    $appRole = ($webAppRegistration.AppRoles | Where-Object DisplayName -eq 'Api.Call')
    "App Registration: $appName already exists"
    "RoleName: $($appRole.DisplayName) already exists"
}

# deploy the infrastructure
"Deploying resources..."
$deployment = New-AzSubscriptionDeployment `
    -Name 'apiDeployment' `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ./main.json `
    -location $location `
    -containerImage 'belstarr/go-web-api:v1.0' `
    -webApiPath = '/api/v1/report' `
    -webApiAppId $webAppRegistration.appId `
    -Verbose

# get deployment output
$logicApp = Get-AzADServicePrincipal -DisplayNameBeginsWith $deployment.Outputs.logicAppName.value
$webAppUrl = $deployment.Outputs.webAppUrl.value

# enforce user app role pre-assignment & prevent user self-consent to an application
Set-AzureADServicePrincipal -ObjectId $webAppServicePrincipal.Id -AppRoleAssignmentRequired $true

# set web app reply URL
Set-AzureADApplication -ObjectId $webAppRegistration.ObjectId -ReplyUrls "https://$webAppUrl/.auth/login/aad/callback"
       
# add Logic App's Managed Identity to the Web app's app registration app role
if (!(Get-AzureADServiceAppRoleAssignment -ObjectId $webAppServicePrincipal.Id).PrincipalId -eq $logicApp.Id) {
    "Assigning RoleId: $($appRole.Id) to Service Principal $($webAppServicePrincipal.Id)"
    New-AzureADServiceAppRoleAssignment -Id $appRole.Id -ObjectId $logicApp.Id -PrincipalId $logicApp.Id -ResourceId $webAppServicePrincipal.Id
} else {
    "RoleId: $($appRole.Id) already assigned to Service Principal $($webAppServicePrincipal.Id)"
}
