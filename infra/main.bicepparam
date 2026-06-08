using './main.bicep'

// ============================================================================
// BASIC PARAMETERS
// ============================================================================
param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'citadel-Staging')
param location = readEnvironmentVariable('AZURE_LOCATION', 'southafricanorth')
param apicLocation = readEnvironmentVariable('APIC_LOCATION', 'swedencentral')
param tags = {
  'azd-env-name': readEnvironmentVariable('AZURE_ENV_NAME', 'citadel-Staging')
  SecurityControl: 'Ignore'
}

// ============================================================================
// RESOURCE NAMES - Assign custom names to different provisioned services
// ============================================================================
param resourceGroupName = readEnvironmentVariable('AZURE_RESOURCE_GROUP', 'rg-poc-zan-001')
param apimIdentityName = readEnvironmentVariable('APIM_IDENTITY_NAME', 'apim-id-poc-zan-001')
param usageLogicAppIdentityName = readEnvironmentVariable('USAGE_LOGIC_APP_IDENTITY_NAME', 'logic-poc-zan-001')
param apimServiceName = readEnvironmentVariable('APIM_SERVICE_NAME', 'apim-serv-poc-zan-001')
param logAnalyticsName = readEnvironmentVariable('LOG_ANALYTICS_NAME', 'loganalytics-poc-zan-001')
param apimApplicationInsightsDashboardName = readEnvironmentVariable('APIM_APP_INSIGHTS_DASHBOARD_NAME', 'apim-appi-dashboard-poc-zan-001')
param funcAplicationInsightsDashboardName = readEnvironmentVariable('FUNC_APP_INSIGHTS_DASHBOARD_NAME', 'func-appi-dashboard-poc-zan-001')
param foundryApplicationInsightsDashboardName = readEnvironmentVariable('FOUNDRY_APP_INSIGHTS_DASHBOARD_NAME', 'foundry-appi-dashboard-poc-zan-001')
param apimApplicationInsightsName = readEnvironmentVariable('APIM_APP_INSIGHTS_NAME', 'apim-appi-poc-zan-001')
param funcApplicationInsightsName = readEnvironmentVariable('FUNC_APP_INSIGHTS_NAME', 'func-appi-poc-zan-001')
param foundryApplicationInsightsName = readEnvironmentVariable('FOUNDRY_APP_INSIGHTS_NAME', 'foundry-appi-poc-zan-001')
param eventHubNamespaceName = readEnvironmentVariable('EVENTHUB_NAMESPACE_NAME', 'evh-poc-zan-001')
param cosmosDbAccountName = readEnvironmentVariable('COSMOS_DB_ACCOUNT_NAME', 'cosmos-poc-zan-001')
param usageProcessingLogicAppName = readEnvironmentVariable('USAGE_PROCESSING_LOGIC_APP_NAME', 'usage-logic-poc-zan-001')
param storageAccountName = readEnvironmentVariable('STORAGE_ACCOUNT_NAME', 'storagepoczan001')
param apicServiceName = readEnvironmentVariable('APIC_SERVICE_NAME', 'apic-poc-zan-001')
param aiFoundryResourceName = readEnvironmentVariable('AI_FOUNDRY_RESOURCE_NAME', 'ai-foundry-poc-zan-001')
param keyVaultName = readEnvironmentVariable('KEY_VAULT_NAME', 'keyvault-poc-zan-001')
param redisCacheName = readEnvironmentVariable('REDIS_CACHE_NAME', 'redis-poc-zan-001')

// ============================================================================
// MONITORING - Log Analytics configuration
// ============================================================================
param useExistingLogAnalytics = bool(readEnvironmentVariable('USE_EXISTING_LOG_ANALYTICS', 'true'))
param existingLogAnalyticsName = readEnvironmentVariable('EXISTING_LOG_ANALYTICS_NAME', 'UCT-law')
param existingLogAnalyticsRG = readEnvironmentVariable('EXISTING_LOG_ANALYTICS_RG', 'uct-mgmt')
param existingLogAnalyticsSubscriptionId = readEnvironmentVariable('EXISTING_LOG_ANALYTICS_SUBSCRIPTION_ID', '44697594-38de-45d3-94b7-e5fae5e97c6e')

// ============================================================================
// NETWORKING PARAMETERS - Network configuration and access controls
// ============================================================================
param vnetName = readEnvironmentVariable('VNET_NAME', 'UCT-hub-southafricanorth')
param useExistingVnet = bool(readEnvironmentVariable('USE_EXISTING_VNET', 'true')
param existingVnetRG = readEnvironmentVariable('EXISTING_VNET_RG', 'UCT-vnethub-southafricanorth')

// Subnet names
param apimSubnetName = readEnvironmentVariable('APIM_SUBNET_NAME', 'snet-apim-poc-zan-001')
param privateEndpointSubnetName = readEnvironmentVariable('PRIVATE_ENDPOINT_SUBNET_NAME', 'snet-se-poc-zan-001')
param functionAppSubnetName = readEnvironmentVariable('FUNCTION_APP_SUBNET_NAME', 'snet-func-poc-zan-001')
param agentSubnetName = readEnvironmentVariable('AGENT_SUBNET_NAME', 'snet-agnt-poc-zan-001')

// NSG & route table names
param apimNsgName = readEnvironmentVariable('nsg-apim-poc-zan-001')
param privateEndpointNsgName = readEnvironmentVariable('nsg-se-poc-zan-001')
param functionAppNsgName = readEnvironmentVariable('nsg-func-poc-zan-001')
param agentSubnetNsgName = readEnvironmentVariable('nsg-agnt-poc-zan-001')
param apimRouteTableName = readEnvironmentVariable('rt-apim-poc-zan-001')

// VNet address space and subnet prefixe
param vnetAddressPrefix = readEnvironmentVariable('VNET_ADDRESS_PREFIX', '')
param apimSubnetPrefix = readEnvironmentVariable('APIM_SUBNET_PREFIX', '')
param privateEndpointSubnetPrefix = readEnvironmentVariable('PRIVATE_ENDPOINT_SUBNET_PREFIX', '')
param functionAppSubnetPrefix = readEnvironmentVariable('FUNCTION_APP_SUBNET_PREFIX', '')
param agentSubnetPrefix = readEnvironmentVariable('AGENT_SUBNET_PREFIX', '')

// Foundry network injection (agents). Defaults to true; required agent subnet is provisioned automatically when not using an existing VNet.
param foundryNetworkInjectionEnabled = bool(readEnvironmentVariable('FOUNDRY_NETWORK_INJECTION_ENABLED', 'true'))

// DNS Zone parameters (legacy approach - single subscription/RG)
param dnsZoneRG = readEnvironmentVariable('DNS_ZONE_RG', 'UCT-privatedns')
param dnsSubscriptionId = readEnvironmentVariable('DNS_SUBSCRIPTION_ID', '2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa')

// Existing Private DNS Zones (BYO approach - specify resource IDs per DNS zone type)
// Use this when you have existing Private DNS Zones in different subscriptions/resource groups
// Leave empty strings to use the legacy dnsZoneRG/dnsSubscriptionId approach
param existingPrivateDnsZones = {
  openai: readEnvironmentVariable('EXISTING_DNS_ZONE_OPENAI', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com')              // privatelink.openai.azure.com
  keyVault: readEnvironmentVariable('EXISTING_DNS_ZONE_KEYVAULT', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net')          // privatelink.vaultcore.azure.net
  monitor: readEnvironmentVariable('EXISTING_DNS_ZONE_MONITOR', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.monitor.azure.com')            // privatelink.monitor.azure.com
  eventHub: readEnvironmentVariable('EXISTING_DNS_ZONE_EVENTHUB', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net')          // privatelink.servicebus.windows.net
  cosmosDb: readEnvironmentVariable('EXISTING_DNS_ZONE_COSMOSDB', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com')          // privatelink.documents.azure.com
  storageBlob: readEnvironmentVariable('EXISTING_DNS_ZONE_STORAGE_BLOB', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net')   // privatelink.blob.core.windows.net
  storageFile: readEnvironmentVariable('EXISTING_DNS_ZONE_STORAGE_FILE', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net')   // privatelink.file.core.windows.net
  storageTable: readEnvironmentVariable('EXISTING_DNS_ZONE_STORAGE_TABLE', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net') // privatelink.table.core.windows.net
  storageQueue: readEnvironmentVariable('EXISTING_DNS_ZONE_STORAGE_QUEUE', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net') // privatelink.queue.core.windows.net
  cognitiveServices: readEnvironmentVariable('EXISTING_DNS_ZONE_COGNITIVE', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com') // privatelink.cognitiveservices.azure.com
  apimGateway: readEnvironmentVariable('EXISTING_DNS_ZONE_APIM', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net')           // privatelink.azure-api.net
  aiServices: readEnvironmentVariable('EXISTING_DNS_ZONE_AI_SERVICES', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.services.azure.com')     // privatelink.services.azure.com
  redis: readEnvironmentVariable('EXISTING_DNS_ZONE_REDIS', '/subscriptions/2fbab2a1-8a8e-4963-812d-67bc2ba3b6fa/resourceGroups/UCT-privatedns/providers/Microsoft.Network/privateDnsZones/privatelink.redis.azure.net')                // privatelink.redis.azure.net
}

// Private Endpoint names
param storageBlobPrivateEndpointName = readEnvironmentVariable('STORAGE_BLOB_PE_NAME', 'storage-blob-pe-poc-zan-001')
param storageFilePrivateEndpointName = readEnvironmentVariable('STORAGE_FILE_PE_NAME', 'storage-file-pe-poc-zan-001')
param storageTablePrivateEndpointName = readEnvironmentVariable('STORAGE_TABLE_PE_NAME', 'storage-table-pe-poc-zan-001')
param storageQueuePrivateEndpointName = readEnvironmentVariable('STORAGE_QUEUE_PE_NAME', 'storage-queue-pe-poc-zan-001')
param cosmosDbPrivateEndpointName = readEnvironmentVariable('COSMOS_DB_PE_NAME', 'cosmos-db-pe-poc-zan-001')
param eventHubPrivateEndpointName = readEnvironmentVariable('EVENTHUB_PE_NAME', 'eventhub-pe-poc-zan-001')
param apimV2PrivateEndpointName = readEnvironmentVariable('APIM_V2_PE_NAME', 'apim-v2-pe-poc-zan-001')
param aiFoundryPrivateEndpointName = readEnvironmentVariable('AI_FOUNDRY_PE_NAME', 'foundry-pe-poc-zan-001')

// Services network access configuration
param apimNetworkType = readEnvironmentVariable('APIM_NETWORK_TYPE', 'External')
param apimV2UsePrivateEndpoint = bool(readEnvironmentVariable('APIM_V2_USE_PRIVATE_ENDPOINT', 'true'))
param apimV2PublicNetworkAccess = bool(readEnvironmentVariable('APIM_V2_PUBLIC_NETWORK_ACCESS', 'true'))
param cosmosDbPublicAccess = readEnvironmentVariable('COSMOS_DB_PUBLIC_ACCESS', 'Disabled')
param eventHubNetworkAccess = readEnvironmentVariable('EVENTHUB_NETWORK_ACCESS', 'Enabled')
param aiFoundryExternalNetworkAccess = readEnvironmentVariable('AI_FOUNDRY_EXTERNAL_NETWORK_ACCESS', 'Disabled')
param keyVaultExternalNetworkAccess = readEnvironmentVariable('KEY_VAULT_EXTERNAL_NETWORK_ACCESS', 'Disabled')
param useAzureMonitorPrivateLinkScope = bool(readEnvironmentVariable('USE_AZURE_MONITOR_PRIVATE_LINK_SCOPE', 'false'))
param redisPublicNetworkAccess = readEnvironmentVariable('REDIS_PUBLIC_NETWORK_ACCESS', 'Disabled')

// ============================================================================
// FEATURE FLAGS - Deploy specific capabilities
// ============================================================================
param createAppInsightsDashboards = bool(readEnvironmentVariable('CREATE_DASHBOARDS', 'false'))
param enableAIModelInference = bool(readEnvironmentVariable('ENABLE_AI_MODEL_INFERENCE', 'true'))
param enableDocumentIntelligence = bool(readEnvironmentVariable('ENABLE_DOCUMENT_INTELLIGENCE', 'false'))
param enableAzureAISearch = bool(readEnvironmentVariable('ENABLE_AZURE_AI_SEARCH', 'false'))
param enableAIGatewayPiiRedaction = bool(readEnvironmentVariable('ENABLE_PII_REDACTION', 'true'))
param enableOpenAIRealtime = bool(readEnvironmentVariable('ENABLE_OPENAI_REALTIME', 'true'))
param entraAuth = bool(readEnvironmentVariable('AZURE_ENTRA_AUTH', 'false'))
param enableAPICenter = bool(readEnvironmentVariable('ENABLE_API_CENTER', 'false'))
param enableManagedRedis = bool(readEnvironmentVariable('ENABLE_MANAGED_REDIS', 'true'))
param enableUnifiedAiApi = bool(readEnvironmentVariable('ENABLE_UNIFIED_AI_API', 'true'))

// ============================================================================
// INFERENCE API DIAGNOSTIC LOG SETTINGS
// ============================================================================

// Azure Monitor diagnostic log settings for inference APIs
// Controls frontend/backend request/response headers, body bytes, and LLM-specific log settings.
// Max size in bytes for request/response bodies is 262144 bytes (256 KB).
param azureMonitorLogSettings = {
  frontend: {
    request:  { headers: [], body: { bytes: 0 } }
    response: { headers: [], body: { bytes: 0 } }
  }
  backend: {
    request:  { headers: [], body: { bytes: 0 } }
    response: { headers: ['Content-type', 'User-agent', 'x-ms-region', 'x-ratelimit-remaining-tokens', 'x-ratelimit-remaining-requests'], body: { bytes: 0 } }
  }
  largeLanguageModel: {
    logs: 'enabled'
    requests:  { messages: 'all', maxSizeInBytes: 262144 }
    responses: { messages: 'all', maxSizeInBytes: 262144 }
  }
}

// Application Insights diagnostic log settings for inference APIs
// Controls which headers are captured and body byte limits (max 8192 bytes).
param appInsightsLogSettings = {
  headers: [ 'Content-type', 'User-agent', 'x-ms-region', 'x-ratelimit-remaining-tokens', 'x-ratelimit-remaining-requests' ]
  body: { bytes: 8192 }
}

// ============================================================================
// COMPUTE SKU & SIZE - SKUs and capacity settings for services
// ============================================================================
param apimSku = readEnvironmentVariable('APIM_SKU', 'StandardV2')
param apimSkuUnits = int(readEnvironmentVariable('APIM_SKU_UNITS', '1'))
param eventHubCapacityUnits = int(readEnvironmentVariable('EVENTHUB_CAPACITY', '1'))
param cosmosDbRUs = int(readEnvironmentVariable('COSMOS_DB_RUS', '400'))
param logicAppsSkuCapacityUnits = int(readEnvironmentVariable('LOGIC_APPS_SKU_CAPACITY_UNITS', '1'))
param apicSku = readEnvironmentVariable('APIC_SKU', 'Free')
param keyVaultSkuName = readEnvironmentVariable('KEY_VAULT_SKU_NAME', 'standard')
param redisSkuName = readEnvironmentVariable('REDIS_SKU_NAME', 'Balanced_B1')
param redisSkuCapacity = int(readEnvironmentVariable('REDIS_SKU_CAPACITY', '1'))

// ============================================================================
// ACCELERATOR SPECIFIC PARAMETERS
// ============================================================================
param logicContentShareName = readEnvironmentVariable('LOGIC_CONTENT_SHARE_NAME', 'usage-logic-content')

// AI Search instances configuration - add more instances by adding to this array
// Example: [{name: 'ai-search-01', url: 'https://search1.search.windows.net/', description: 'AI Search 1'}]
param aiSearchInstances = []

// AI Foundry instances configuration array
// Per-instance `networkInjectionEnabled` opts the specific Foundry into (or out of)
// agent network injection. Omit it to inherit the global foundryNetworkInjectionEnabled flag.
// Agent subnet is regional - typically only enable injection for the instance in the VNet's region.
param aiFoundryInstances = [
  {
    name: readEnvironmentVariable('AI_FOUNDRY_RESOURCE_NAME', '')
    location: readEnvironmentVariable('AZURE_LOCATION', 'southafricanorth')
    customSubDomainName: ''
    defaultProjectName: 'citadel-governance-project'
    networkInjectionEnabled: true
  }
  {
    name: readEnvironmentVariable('AI_FOUNDRY_RESOURCE_NAME', 'aifoundry-poc-zan-001')
    location: 'southafricanorth'
    customSubDomainName: ''
    defaultProjectName: 'citadel-governance-project'
    networkInjectionEnabled: false
  }
]

// AI Foundry model deployments configuration
// Each model can optionally include metadata for the Unified AI API routing:
//   - apiVersion: API version for OpenAI-type requests (default: '2024-02-15-preview')
//   - timeout: Request timeout in seconds (default: 120)
//   - inferenceApiVersion: API version for inference-type requests (e.g., '2024-05-01-preview' for non-OpenAI models)
param aiFoundryModelsConfig = [
  {
    name: 'gpt-4.1'
    publisher: 'OpenAI'
    version: '2025-04-14'
    sku: 'GlobalStandard'
    capacity: 100
    retirementDate: '2026-10-14'
    apiVersion: '2025-04-01-preview'
    timeout: 180
    aiserviceIndex: 0
  }
  {
    name: 'DeepSeek-R1'
    publisher: 'DeepSeek'
    version: '1'
    sku: 'GlobalStandard'
    capacity: 1
    retirementDate: '2099-12-30'
    inferenceApiVersion: '2024-05-01-preview'
    aiserviceIndex: 0
  }
  {
    name: 'text-embedding-3-large'
    publisher: 'OpenAI'
    version: '1'
    sku: 'GlobalStandard'
    capacity: 100
    retirementDate: '2027-04-14'
    aiserviceIndex: 0
  }
  {
    name: 'Mistral-Large-3'
    publisher: 'Mistral AI'
    version: '1'
    sku: 'GlobalStandard'
    capacity: 100
    retirementDate: '2099-12-30'
    aiserviceIndex: 0
  }
  {
    name: 'gpt-5.4-mini'
    publisher: 'OpenAI'
    version: '2026-03-17'
    sku: 'GlobalStandard'
    capacity: 100
    retirementDate: '2026-09-30'
    aiserviceIndex: 0
  }
  {
    name: 'Phi-4'
    publisher: 'Microsoft'
    version: '7'
    sku: 'GlobalStandard'
    capacity: 1
    retirementDate: '2099-10-14'
    apiVersion: '2025-04-01-preview'
    timeout: 180
    aiserviceIndex: 0
  }
  {
    name: 'Phi-4'
    publisher: 'Microsoft'
    version: '7'
    sku: 'GlobalStandard'
    capacity: 1
    retirementDate: '2099-10-14'
    apiVersion: '2025-04-01-preview'
    timeout: 180
    aiserviceIndex: 1
  }
  {
    name: 'gpt-5.4-mini'
    publisher: 'OpenAI'
    version: '2026-03-17'
    sku: 'GlobalStandard'
    capacity: 100
    retirementDate: '2026-09-30'
    aiserviceIndex: 1
  }
  {
    name: 'gpt-5.2'
    publisher: 'OpenAI'
    version: '2025-12-11'
    sku: 'GlobalStandard'
    capacity: 100
    retirementDate: '2027-02-05'
    aiserviceIndex: 1
  }
  {
    name: 'DeepSeek-R1'
    publisher: 'DeepSeek'
    version: '1'
    sku: 'GlobalStandard'
    capacity: 1
    retirementDate: '2099-12-30'
    inferenceApiVersion: '2024-05-01-preview'
    aiserviceIndex: 1
  }
  {
    name: 'text-embedding-3-large'
    publisher: 'OpenAI'
    version: '1'
    sku: 'GlobalStandard'
    capacity: 100
    retirementDate: '2027-04-14'
    aiserviceIndex: 1
  }
]

// Semantic caching APIM integration configurations
param primaryFoundryEmbeddingModelName = readEnvironmentVariable('PRIMARY_FOUNDRY_EMBEDDING_MODEL_NAME', 'text-embedding-3-large')

// ============================================================================
// ENTRA ID AUTHENTICATION
// ============================================================================
// Values are populated by the entra-id-setup script (bicep/infra/entra-id-setup/setup.ps1)
// which creates the App Registration and stores values as azd environment variables.
// For bring-your-own app registrations, set these values directly via 'azd env set'.
param entraTenantId = readEnvironmentVariable('AZURE_TENANT_ID', '')
param entraClientId = readEnvironmentVariable('AZURE_CLIENT_ID', '')
param entraAudience = readEnvironmentVariable('AZURE_AUDIENCE', '')
param entraClientSecret = readEnvironmentVariable('ENTRA_CLIENT_SECRET', '')
