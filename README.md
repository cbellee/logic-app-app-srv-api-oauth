# Logic App to App Service OAuth example

![Solution Diagram](https://github.com/cbellee/logic-app-app-srv-api-oauth/solution.png)

## Prerequisites

- install the Azure PowerShell module
  - `PS C:\> Find Module Az | Install-Module`
- install the Azure AD Module
  - `PS C:\> Find  Module AzureAD | Install Module`
## Deployment

- set the AAD tenant guid to yuor own tenant at the top of BOTH scripts
  - `$aadTenantId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'` 
- `PS C:/> cd ./deploy` 
- `PS C:/> ./1-deployInfrastructure.ps1`
- enable Managed Identity for the Logic App dispalyed at the end of the previous script, in the Azure portal
  - https://docs.microsoft.com/en-us/azure/logic-apps/create-managed-service-identity#enable-managed-identity
- `PS C:\> ./2-addAppRolePermission.ps1`
