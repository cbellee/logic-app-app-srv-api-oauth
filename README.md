# Logic App to App Service OAuth example
![Solution Diagram](https://github.com/cbellee/logic-app-app-srv-api-oauth/blob/main/images/solution.png)

## Prerequisites
- install the Azure PowerShell module
  - `PS C:\> Find Module Az | Install-Module`
- install the Azure AD Module
  - `PS C:\> Find  Module AzureAD | Install Module`

## Deployment
- clone the repo
- change current directory to /deploy
  - `PS C:/> cd ./deploy` 
- ensure you're authenticated via PowerShell 'Login-AzAccount' and have selected the target subscription with 'Set-AzSubscription -SubscriptionId <subscriptionId>
- execute the PowerShell script
  - `PS C:/> ./deploy.ps1`
