# Logic App to App Service OAuth example
![Solution Diagram](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/solution.png)

## Prerequisites
- Ensure you're running on a Windows OS since the 'AzureAD' module only support Windows PowerShell, not PowerShell v6.0 (x-plat) 

- Install the Azure PowerShell module
  - `PS C:\> Find Module Az | Install-Module`
- Install the Azure AD Module
  - `PS C:\> Find  Module AzureAD | Install Module`

## Deployment
- Clone the repo
- Change current directory to /deploy
  - `PS C:/> cd ./deploy` 
- Ensure you're authenticated via PowerShell 'Login-AzAccount' and have selected the target subscription with 'Set-AzSubscription -SubscriptionId <subscriptionId>
- Execute the PowerShell script
  - `PS C:/> ./deploy.ps1`
