param location string = 'australiaeast'
param resourceGroupName string
param webApiPath string = 'api/v1/report'
param webApiAppId string
param containerImage string = 'belstarr/go-web-api:v1.0'
param appServicePlanSku object = {
  name: 'P1v2'
  tier: 'PremiumV2'
  size: 'P1v2'
  family: 'Pv2'
  capacity: 1
}

targetScope = 'subscription'

resource resourceGroupResource 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: resourceGroupName
}

module apiModule './api.bicep' = {
  scope: resourceGroupResource
  name: 'apiDeployment'
  params: {
    appServicePlanSku: appServicePlanSku
    containerImage: containerImage
    webApiAppId: webApiAppId
    webApiPath: webApiPath
  }
}

output webAppName string = apiModule.outputs.webAppName
output webAppUrl string = apiModule.outputs.webAppUrl
output logicAppName string = apiModule.outputs.logicAppName
output logicAppManagedIdentityPricipalId string = apiModule.outputs.logicAppManagedIdentityPrincipalId
