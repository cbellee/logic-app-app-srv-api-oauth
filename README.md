# Logic App to App Service OAuth example

![Solution Diagram](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/solution.png)

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

### Manual deployment of application registration 

1. Create a new Application Registration for Web API
- ![step 1](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/1-application-registration.png)
- ![step 2](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/2-application-registration.png)
- ![step 3](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/3-application-registration.png)
- ![step 4](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/4-application-registration.png)
- ![step 5](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/5-application-registration.png)
2. Add new client secret to Web API's Application Registration
- ![step 1](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/6-application-registration.png)
- ![step 2](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/7-application-registration.png)
- ![step 3](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/8-application-registration.png)
- ![step 4](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/9-application-registration.png)
3. Add new scope to Web API's Enterprise Application (Service Principal)
- ![step 1](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/10-application-registration.png)
- ![step 2](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/11-application-registration.png)
- ![step 3](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/12-application-registration.png)
4. Enable Managed Identity on Logic App
- ![step 1](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/12-application-registration.png)
5. Add Logic App's Managed Identity to allowed users on Web API's Enterprise Application
- this can currently only be achieved using Azure CLI or PowerShell. Use the ./deploy/2-addAppRolePermission.ps1 script to do this.