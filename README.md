# Logic App to App Service OAuth example

![Solution Diagram](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/solution.png)

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
- Browse to 'Azure Active Directory -> Enterprise Applications'
- Click 'New Application' button.
![step 1](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/1-application-registration.png)
- Click 'Create your own application' button 
![step 2](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/2-application-registration.png)
- Add a name for the app registration & select 'Register an application to integrate with Azure AD (App you're developing)'
- Click 'Add'
![step 3](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/3-application-registration.png)
- For the 'Supported Account Types' option, select the first option 'Accounts in this organizational directory only'
![step 4](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/4-application-registration.png)
- Wait for the 'Create Application' event notification to be displayed
![step 5](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/5-application-registration.png)
2. Add new scope to Web API's Enterprise Application (Service Principal)
- Browse to 'Azure Active Directory -> Application Registrations'
- Copy the 'Application (client) ID' to your clipboard
- Click the 'Managed Application in Directory' link
- ![step 1](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/10-application-registration.png)
- Select the 'App Roles' menu item
- Click 'Create App Role'
- Add a display name, such as 'Api.Caller'
- In 'Allowed member types' select the 'Application' option 
- Ensure 'Do you want to enable this App role?' is checked
![step 2](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/11-application-registration.png)
- Navigate back to 'Azure Active Directory -> Application Registrations' and find the App registration you just created.
- Click on 'App roles' menu item and your newly created app role should be displayed
![step 3](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/12-application-registration.png)
3. Enable Managed Identity on Logic App
![step 1](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/13-application-registration.png)
4. Add Logic App's Managed Identity to allowed users on Web API's Enterprise Application
- This can currently only be achieved using Azure CLI or PowerShell. Use the ./deploy/2-addAppRolePermission.ps1 script to do this.
5. Add 'Microsoft' identity provider in the Azure App Service's Web Application's 'Authentication' section 
![step 1](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/14-application-registration.png)
![step 2](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/15-application-registration.png)
