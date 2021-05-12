param webApiName string
param webApiPath string
param webApiAppId string
param logicAppName string
param appServicePlan string
param containerImage string
param appServicePlanSku object = {
  name: 'P1v2'
  tier: 'PremiumV2'
  size: 'P1v2'
  family: 'Pv2'
  capacity: 1
}

var prefix = uniqueString(resourceGroup().id)
var storageAccount1Name = 'stor1${prefix}'
var storageAccount2Name = 'stor2${prefix}'

resource logic_app_resource 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: resourceGroup().location
  /*     identity: {
    tenantId: subscription().tenantId
    type: 'SystemAssigned'
  } */
  properties: {
    accessControl: {
      actions: {
        allowedCallerIpAddresses: []
        openAuthenticationPolicies: {
          policies: {
            aud: {
              claims: [
                {
                  name: 'iss'
                  value: 'https://sts.windows.net/${subscription().tenantId}/'
                }
                {
                  name: 'aud'
                  value: 'https://management.core.windows.net/'
                }
              ]
            }
          }
        }
      }
    }
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {}
          }
        }
      }
      actions: {
        HTTP: {
          runAfter: {}
          type: 'Http'
          inputs: {
            authentication: {
              audience: '${webApiAppId}'
              type: 'ManagedServiceIdentity'
            }
            method: 'GET'
            uri: 'https://${webApiName}.azurewebsites.net/${webApiPath}'
          }
        }
        Response: {
          runAfter: {
            HTTP: [
              'Succeeded'
            ]
          }
          type: 'Response'
          kind: 'Http'
          inputs: {
            body: '@body(\'HTTP\')'
            statusCode: 200
          }
        }
      }
      outputs: {}
    }
    parameters: {}
  }
}

resource storage_account_1_resource 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccount1Name
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource storage_account_2_resource 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccount2Name
  location: 'centralus'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource app_service_plan_resource 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: appServicePlan
  location: resourceGroup().location
  sku: {
    name: 'P1v3'
    tier: 'PremiumV3'
    size: 'P1v3'
    family: 'Pv3'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource storage_account_1_default 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  name: '${storage_account_1_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource storage_account_2_default 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  name: '${storage_account_2_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource storage_account_1_fileservices 'Microsoft.Storage/storageAccounts/fileServices@2021-02-01' = {
  name: '${storage_account_1_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storage_account_2_default 'Microsoft.Storage/storageAccounts/fileServices@2021-02-01' = {
  name: '${storage_account_2_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storage_account_1_default 'Microsoft.Storage/storageAccounts/queueServices@2021-02-01' = {
  name: '${storage_account_1_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storage_account_2_default 'Microsoft.Storage/storageAccounts/queueServices@2021-02-01' = {
  name: '${storage_account_2_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource tableServices_storage_account_1_default 'Microsoft.Storage/storageAccounts/tableServices@2021-02-01' = {
  name: '${storage_account_1_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource tableServices_storage_account_2_default 'Microsoft.Storage/storageAccounts/tableServices@2021-02-01' = {
  name: '${storage_account_2_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource web_api_name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: webApiName
  location: resourceGroup().location
  kind: 'app,linux,container'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${webApiName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webApiName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: app_service_plan_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    siteConfig: {}
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
  }
}

resource web_api_name_web 'Microsoft.Web/sites/config@2018-11-01' = {
  name: '${web_api_name_resource.name}/web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'DOCKER|${containerImage}'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$${webApiName}'
    azureStorageAccounts: {}
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    ftpsState: 'AllAllowed'
    reservedInstanceCount: 0
  }
}

resource web_api_name_web_api_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2018-11-01' = {
  name: '${web_api_name_resource.name}/${webApiName}.azurewebsites.net'
  properties: {
    siteName: webApiName
    hostNameType: 'Verified'
  }
}

resource storage_account_1_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${storage_account_1_default.name}/azure-webjobs-hosts'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storage_account_1_resource
  ]
}

resource storage_account_2_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${storage_account_2_default.name}/azure-webjobs-hosts'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_1_default_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${storage_account_1_default.name}/azure-webjobs-secrets'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storage_account_1_resource
  ]
}

resource storage_account_2_default_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${storage_account_2_default.name}/azure-webjobs-secrets'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_1_default_au_chamber_alliance_api8ec8 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-02-01' = {
  name: '${storage_account_1_fileservices.name}/au-chamber-alliance-api8ec8'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storage_account_1_resource
  ]
}

resource storage_account_2_default_auchamberalliance_testac5a 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-02-01' = {
  name: '${Microsoft_Storage_storageAccounts_fileServices_storage_account_2_default.name}/auchamberalliance-testac5a'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_2_default_flowd67d6be4ba71bfejobtriggers00 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-02-01' = {
  name: '${Microsoft_Storage_storageAccounts_queueServices_storage_account_2_default.name}/flowd67d6be4ba71bfejobtriggers00'
  properties: {
    metadata: {}
  }
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_2_default_flowd67d6be4ba71bfe658e8ac24ffbd82flows 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-02-01' = {
  name: '${tableServices_storage_account_2_default.name}/flowd67d6be4ba71bfe658e8ac24ffbd82flows'
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_2_default_flowd67d6be4ba71bfef2f1991a497d531flows 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-02-01' = {
  name: '${tableServices_storage_account_2_default.name}/flowd67d6be4ba71bfef2f1991a497d531flows'
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_2_default_flowd67d6be4ba71bfeflowaccesskeys 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-02-01' = {
  name: '${tableServices_storage_account_2_default.name}/flowd67d6be4ba71bfeflowaccesskeys'
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_2_default_flowd67d6be4ba71bfeflowruntimecontext 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-02-01' = {
  name: '${tableServices_storage_account_2_default.name}/flowd67d6be4ba71bfeflowruntimecontext'
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_2_default_flowd67d6be4ba71bfeflows 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-02-01' = {
  name: '${tableServices_storage_account_2_default.name}/flowd67d6be4ba71bfeflows'
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_2_default_flowd67d6be4ba71bfeflowsubscriptions 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-02-01' = {
  name: '${tableServices_storage_account_2_default.name}/flowd67d6be4ba71bfeflowsubscriptions'
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_2_default_flowd67d6be4ba71bfeflowsubscriptionsummary 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-02-01' = {
  name: '${tableServices_storage_account_2_default.name}/flowd67d6be4ba71bfeflowsubscriptionsummary'
  dependsOn: [
    storage_account_2_resource
  ]
}

resource storage_account_2_default_flowd67d6be4ba71bfejobdefinitions 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-02-01' = {
  name: '${tableServices_storage_account_2_default.name}/flowd67d6be4ba71bfejobdefinitions'
  dependsOn: [
    storage_account_2_resource
  ]
}

output logicAppName string = logic_app_resource.name
