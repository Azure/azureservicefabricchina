
#Login with China Azure account
Add-AzureRmAccount -EnvironmentName azurechinacloud 
Select-AzureRmSubscription –SubscriptionId ***

#Create SF Cluster (Unsecure)

Test-AzureRmResourceGroupDeployment -ResourceGroupName jianwSFRG -TemplateFile ".\azuredeploy.json" -TemplateParameterFile ".\azuredeploy.parameters.json" 

New-AzureRmResourceGroupDeployment -Name exampleARM-SF -ResourceGroupName jianwSFRG -TemplateFile ".\azuredeploy.json" -TemplateParameterFile ".\azuredeploy.parameters.json" 

New-AzureRmResourceGroupDeployment -Name sfbj-deployment1 -ResourceGroupName jianwsfrgbj -TemplateFile ".\azuredeploy.json" -TemplateParameterFile ".\azuredeploy.parameters.json" 

Get-AzureRmResourceGroupDeployment -Name sfbj-deployment1 -ResourceGroupName jianwsfrgbj

            ====output:====

            DeploymentName    : exampleARM-SF
            ResourceGroupName : jianwSFRG
            ProvisioningState : Succeeded
            Timestamp         : 2016/6/15 6:07:46
            Mode              : Incremental
            TemplateLink      :
            Parameters        :
                                Name             Type                       Value
                                ===============  =========================  ==========
                                clusterName      String                     jianwsfcluster1
                                fabricTcpGatewayPort  Int                        19000
                                fabricHttpGatewayPort  Int                        19080
                                adminUserName    String                     testadmin
                                adminPassword    SecureString
                                loadBalancedAppPort1  Int                        80
                                loadBalancedAppPort2  Int                        8081
                                storageAccountType  String                     Standard_LRS
                                supportLogStorageAccountType  String                     Standard_LRS

            Outputs           :
                                Name             Type                       Value
                                ===============  =========================  ==========
                                clusterProperties  Object                     {
                                  "provisioningState": "Succeeded",
                                  "clusterId": "4c7dafb5-8a50-420d-8619-b2cc55e41fae",
                                  "clusterCodeVersion": "5.0.228.9590",
                                  "clusterState": "WaitingForNodes",
                                  "managementEndpoint": "http://jianwsfcluster1.chinaeast.cloudapp.chinacloudapi.cn:19080",
                                  "clusterEndpoint": "https://chinaeast.servicefabric.chinacloudapi.cn/runtime/clusters/4c7dafb5-8a50-420d-8619-b2cc55e41fae",
                                  "clientCertificateThumbprints": [],
                                  "clientCertificateCommonNames": [],
                                  "fabricSettings": [],
                                  "diagnosticsStorageAccountConfig": {
                                    "storageAccountName": "n3iqenpzrkiuu2",
                                    "protectedAccountKeyName": "StorageAccountKey1",
                                    "blobEndpoint": "https://n3iqenpzrkiuu2.blob.core.chinacloudapi.cn/",
                                    "queueEndpoint": "https://n3iqenpzrkiuu2.queue.core.chinacloudapi.cn/",
                                    "tableEndpoint": "https://n3iqenpzrkiuu2.table.core.chinacloudapi.cn/"
                                  },
                                  "vmImage": "Windows",
                                  "reliabilityLevel": "Bronze",
                                  "nodeTypes": [
                                    {
                                      "name": "nt1vm",
                                      "clientConnectionEndpointPort": 19000,
                                      "httpGatewayEndpointPort": 19080,
                                      "applicationPorts": {
                                        "startPort": 20000,
                                        "endPort": 30000
                                      },
                                      "ephemeralPorts": {
                                        "startPort": 49152,
                                        "endPort": 65534
                                      },
                                      "isPrimary": true,
                                      "vmInstanceCount": 5,
                                      "durabilityLevel": "Bronze"
                                    }
                                  ]
                                }



# Get resources for SF Cluster
Get-AzureRmResource | Where-Object {$_.ResourceGroupName -eq "jianwsfrgbj"}

#get LB details
Get-AzureRmLoadBalancer -Name LB-sfcluster1-nt1vm -ResourceGroupName jianwsfrgbj



#Create SF Cluster (Secure)

Import-Module "D:\Practice\Azure Validation\Service Fabric\practice\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"
Login-AzureRmAccount -EnvironmentName azurechinacloud

Invoke-AddCertToKeyVault -SubscriptionId abda8356-5cee-4b7f-a2be-1cc415ef78a7 -ResourceGroupName jianwsfshrg -Location chinaeast -VaultName jianwsfKV1 -CertificateName jianwsfcert1 -Password User@123 -CreateSelfSignedCertificate -DnsName mysfcluster.chinaazure.com -OutputPath C:\Temp

        Switching context to SubscriptionId abda8356-5cee-4b7f-a2be-1cc415ef78a7
        Ensuring ResourceGroup jianwsfshrg in chinaeast
        WARNING: The usability of Tag parameter in this cmdlet will be modified in a future release. This will impact creating, updating and appending tags for Azure resources. For more details about the change, please vi
        sit https://github.com/Azure/azure-powershell/issues/726#issuecomment-213545494
        WARNING: The usage of Tag parameter in this cmdlet will be modified in a future release. This will impact creating, updating and appending tags for Azure resources. For more details about the change, please visit 
        https://github.com/Azure/azure-powershell/issues/726#issuecomment-213545494
        Creating new vault jianwsfKV1 in chinaeast
        WARNING: The usage of Tag parameter in this cmdlet will be modified in a future release. This will impact creating, updating and appending tags for Azure resources. For more details about the change, please visit 
        https://github.com/Azure/azure-powershell/issues/726#issuecomment-213545494
        Creating new self signed certificate at C:\Temp\jianwsfcert1.pfx
        Reading pfx file from C:\Temp\jianwsfcert1.pfx
        Writing secret to jianwsfcert1 in vault jianwsfKV1


        Name  : CertificateThumbprint
        Value : E7A1734E98775ECADE03023F7F17DDA5A19AD9BB

        Name  : SourceVault
        Value : /subscriptions/abda8356-5cee-4b7f-a2be-1cc415ef78a7/resourceGroups/jianwsfshrg/providers/Microsoft.KeyVault/vaults/jianwsfKV1

        Name  : CertificateURL
        Value : https://jianwsfkv1.vault.azure.cn:443/secrets/jianwsfcert1/0e37db277cfb44cd8bb9ba4b9f5dddc2


Test-AzureRmResourceGroupDeployment -ResourceGroupName jianwSFRG -TemplateFile "D:\Practice\Azure Validation\Service Fabric\practice\mooncake-sf-unsecure-cluster-5-node-1-nodetype\azuredeploy.json" -TemplateParameterFile "D:\Practice\Azure Validation\Service Fabric\practice\mooncake-sf-unsecure-cluster-5-node-1-nodetype\azuredeploy.parameters.json" 

New-AzureRmResourceGroupDeployment -Name exampleARM-SF -ResourceGroupName jianwSFRG -TemplateFile "D:\Practice\Azure Validation\Service Fabric\practice\mooncake-sf-unsecure-cluster-5-node-1-nodetype\azuredeploy.json" -TemplateParameterFile "D:\Practice\Azure Validation\Service Fabric\practice\mooncake-sf-unsecure-cluster-5-node-1-nodetype\azuredeploy.parameters.json" 



PS D:\Practice\Azure Validation\Service Fabric\practice\mooncake-sf-secure-cluster-5-node-1-nodetype-wad> New-AzureRmResourceGroupDeployment -ResourceGroupName jianwsfshrg -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json


DeploymentName          : azuredeploy
ResourceGroupName       : jianwsfshrg
ProvisioningState       : Succeeded
Timestamp               : 2016/6/21 8:57:25
Mode                    : Incremental
TemplateLink            : 
Parameters              : 
                          Name             Type                       Value     
                          ===============  =========================  ==========
                          clusterName      String                     sfcluster2
                          fabricTcpGatewayPort  Int                        19000     
                          fabricHttpGatewayPort  Int                        19080     
                          adminUserName    String                     testadmin 
                          adminPassword    SecureString                         
                          loadBalancedAppPort1  Int                        80        
                          loadBalancedAppPort2  Int                        8081      
                          certificateStoreValue  String                     My        
                          certificateThumbprint  String                     E7A1734E98775ECADE03023F7F17DDA5A19AD9BB
                          sourceVaultValue  String                     /subscriptions/abda8356-5cee-4b7f-a2be-1cc415ef78a7/resourceGroups/jianwsfshrg/providers/Microsoft.KeyVault/vaults/jianwsfKV1
                          certificateUrlValue  String                     https://jianwsfkv1.vault.azure.cn:443/secrets/jianwsfcert1/0e37db277cfb44cd8bb9ba4b9f5dddc2
                          clusterProtectionLevel  String                     EncryptAndSign
                          storageAccountType  String                     Standard_LRS
                          supportLogStorageAccountType  String                     Standard_LRS
                          applicationDiagnosticsStorageAccountType  String                     Standard_LRS
                          
Outputs                 : 
                          Name             Type                       Value     
                          ===============  =========================  ==========
                          clusterProperties  Object                     {
                            "provisioningState": "Succeeded",
                            "clusterId": "43e926ac-171b-44ce-a62a-29d63e39be69",
                            "clusterCodeVersion": "5.1.150.9590",
                            "clusterState": "WaitingForNodes",
                            "managementEndpoint": "https://sfcluster2.chinaeast.cloudapp.chinacloudapi.cn:19080",
                            "clusterEndpoint": "https://chinaeast.servicefabric.chinacloudapi.cn/runtime/clusters/43e926ac-171b-44ce-a62a-29d63e39be69",
                            "certificate": {
                              "thumbprint": "E7A1734E98775ECADE03023F7F17DDA5A19AD9BB",
                              "x509StoreName": "My"
                            },
                            "clientCertificateThumbprints": [],
                            "clientCertificateCommonNames": [],
                            "fabricSettings": [
                              {
                                "name": "Security",
                                "parameters": [
                                  {
                                    "name": "ClusterProtectionLevel",
                                    "value": "EncryptAndSign"
                                  }
                                ]
                              }
                            ],
                            "diagnosticsStorageAccountConfig": {
                              "storageAccountName": "xphbgqztkn4n22",
                              "protectedAccountKeyName": "StorageAccountKey1",
                              "blobEndpoint": "https://xphbgqztkn4n22.blob.core.chinacloudapi.cn/",
                              "queueEndpoint": "https://xphbgqztkn4n22.queue.core.chinacloudapi.cn/",
                              "tableEndpoint": "https://xphbgqztkn4n22.table.core.chinacloudapi.cn/"
                            },
                            "vmImage": "Windows",
                            "reliabilityLevel": "Bronze",
                            "nodeTypes": [
                              {
                                "name": "nt1vm",
                                "clientConnectionEndpointPort": 19000,
                                "httpGatewayEndpointPort": 19080,
                                "applicationPorts": {
                                  "startPort": 20000,
                                  "endPort": 30000
                                },
                                "ephemeralPorts": {
                                  "startPort": 49152,
                                  "endPort": 65534
                                },
                                "isPrimary": true,
                                "vmInstanceCount": 5,
                                "durabilityLevel": "Bronze"
                              }
                            ]
                          }
                          
DeploymentDebugLogLevel : 




#### AAD for secure

Get-AzurermSubscription

cd "D:\Practice\Azure Validation\Service Fabric\practice\mooncake-sf-secure-cert_AAD-cluster-5-node-1-nodetype\MicrosoftAzureServiceFabric-AADHelpers"

 .\SetupApplications.ps1 -TenantId '99d86385-9b07-4221-9a3a-facb274186b5' -ClusterName 'mycluster111' -WebApplicationReplyUrl 'https://mycluster111.chinaeast.cloudapp.chinacloudapi.cn:19080/Explorer/index.html' -location china
            
            ### output
             Name                           Value                                                                                                                                                                                
            ----                           -----                                                                                                                                                                                
            TenantId                       99d86385-9b07-4221-9a3a-facb274186b5                                                                                                                                                 
            WebAppId                       1440a413-dbcf-480e-8e84-89b7a88aca78                                                                                                                                                 
            NativeClientAppId              2c9d3224-a605-4ec7-87d9-8f7af0c782ee                                                                                                                                                 
            ServicePrincipalId             08af41d5-ede8-4296-9012-80c81c4e39ce                                                                                                                                                 

            -----ARM template-----
            "azureActiveDirectory": {
              "tenantId":"99d86385-9b07-4221-9a3a-facb274186b5",
              "clusterApplication":"1440a413-dbcf-480e-8e84-89b7a88aca78",
              "clientApplication":"2c9d3224-a605-4ec7-87d9-8f7af0c782ee"
            },




# A second deploy against existing SF cluster to update with more endpoints

PS D:\Practice\Azure Validation\Service Fabric\practice\mooncake-sf-secure-cluster-5-node-1-nodetype-wad> New-AzureRmResourceGroupDeployment -ResourceGroupName jianwsfshrg -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json


DeploymentName          : azuredeploy
ResourceGroupName       : jianwsfshrg
ProvisioningState       : Succeeded
Timestamp               : 2016/6/21 9:24:30
Mode                    : Incremental
TemplateLink            : 
Parameters              : 
                          Name             Type                       Value     
                          ===============  =========================  ==========
                          clusterName      String                     sfcluster2
                          fabricTcpGatewayPort  Int                        19000     
                          fabricHttpGatewayPort  Int                        19080     
                          adminUserName    String                     testadmin 
                          adminPassword    SecureString                         
                          loadBalancedAppPort1  Int                        80        
                          loadBalancedAppPort2  Int                        8081      
                          loadBalancedAppPort3  Int                        8080      
                          loadBalancedAppPort4  Int                        8088      
                          certificateStoreValue  String                     My        
                          certificateThumbprint  String                     E7A1734E98775ECADE03023F7F17DDA5A19AD9BB
                          sourceVaultValue  String                     /subscriptions/abda8356-5cee-4b7f-a2be-1cc415ef78a7/resourceGroups/jianwsfshrg/providers/Microsoft.KeyVault/vaults/jianwsfKV1
                          certificateUrlValue  String                     https://jianwsfkv1.vault.azure.cn:443/secrets/jianwsfcert1/0e37db277cfb44cd8bb9ba4b9f5dddc2
                          clusterProtectionLevel  String                     EncryptAndSign
                          storageAccountType  String                     Standard_LRS
                          supportLogStorageAccountType  String                     Standard_LRS
                          applicationDiagnosticsStorageAccountType  String                     Standard_LRS
                          
Outputs                 : 
                          Name             Type                       Value     
                          ===============  =========================  ==========
                          clusterProperties  Object                     {
                            "provisioningState": "Succeeded",
                            "clusterId": "43e926ac-171b-44ce-a62a-29d63e39be69",
                            "clusterCodeVersion": "5.1.150.9590",
                            "clusterState": "Ready",
                            "managementEndpoint": "https://sfcluster2.chinaeast.cloudapp.chinacloudapi.cn:19080",
                            "clusterEndpoint": "https://chinaeast.servicefabric.chinacloudapi.cn/runtime/clusters/43e926ac-171b-44ce-a62a-29d63e39be69",
                            "certificate": {
                              "thumbprint": "E7A1734E98775ECADE03023F7F17DDA5A19AD9BB",
                              "x509StoreName": "My"
                            },
                            "clientCertificateThumbprints": [],
                            "clientCertificateCommonNames": [],
                            "fabricSettings": [
                              {
                                "name": "Security",
                                "parameters": [
                                  {
                                    "name": "ClusterProtectionLevel",
                                    "value": "EncryptAndSign"
                                  }
                                ]
                              }
                            ],
                            "diagnosticsStorageAccountConfig": {
                              "storageAccountName": "xphbgqztkn4n22",
                              "protectedAccountKeyName": "StorageAccountKey1",
                              "blobEndpoint": "https://xphbgqztkn4n22.blob.core.chinacloudapi.cn/",
                              "queueEndpoint": "https://xphbgqztkn4n22.queue.core.chinacloudapi.cn/",
                              "tableEndpoint": "https://xphbgqztkn4n22.table.core.chinacloudapi.cn/"
                            },
                            "vmImage": "Windows",
                            "reliabilityLevel": "Bronze",
                            "nodeTypes": [
                              {
                                "name": "nt1vm",
                                "clientConnectionEndpointPort": 19000,
                                "httpGatewayEndpointPort": 19080,
                                "applicationPorts": {
                                  "startPort": 20000,
                                  "endPort": 30000
                                },
                                "ephemeralPorts": {
                                  "startPort": 49152,
                                  "endPort": 65534
                                },
                                "isPrimary": true,
                                "vmInstanceCount": 5,
                                "durabilityLevel": "Bronze"
                              }
                            ]
                          }
                          
DeploymentDebugLogLevel : 


#Scale capacity of SF Cluster
Get-AzureRmResource -ResourceGroupName jianwsfshrg -ResourceType Microsoft.Compute/VirtualMachineScaleSets

Get-AzureRmVmss -ResourceGroupName jianwsfshrg -VMScaleSetName <VM Scale Set name>


$vmssobj = Get-AzureRmVmss -ResourceGroupName jianwsfshrg -VMScaleSetName nt1vm
$vmssobj.Sku.Capacity = 6
Update-AzureRmVmss -ResourceGroupName jianwsfshrg -Name nt1vm -VirtualMachineScaleSet $vmssobj



#Delete 
Remove-AzureRmResourceGroupDeployment -ResourceGroupName ContosoEngineering -Name contosoDeployment

Remove-AzureRmResourceGroup -Name -ContosoRG01





#### MNC tool cluster setup and app deploy
Invoke-AddCertToKeyVault -SubscriptionId b46ff9c8-1685-4e13-877c-9331eb93ebe6 -ResourceGroupName cat-migration-resource-group -Location "West US" -VaultName migrationcentervault -CertificateName migrationcentercert -Password "Password01!" -CreateSelfSignedCertificate -DnsName cat-mc-sf.westus.cloudapp.azure.com -OutputPath C:\Temp

Name  : CertificateThumbprint
Value : 865D6178112D6B88B447250B084164A345E435D3

Name  : SourceVault
Value : /subscriptions/b46ff9c8-1685-4e13-877c-9331eb93ebe6/resourceGroups/cat-migration-resource-group/providers/Microsoft.KeyVault/vaults/migrationcentervault

Name  : CertificateURL
Value : https://migrationcentervault.vault.azure.net:443/secrets/migrationcentercert/506af65511c04df89171faf58bd12df7

Connect-serviceFabricCluster -ConnectionEndpoint cat-mc-sf.westus.cloudapp.azure.com:19000 `
          -KeepAliveIntervalInSec 10 `
          -X509Credential -ServerCertThumbprint 865D6178112D6B88B447250B084164A345E435D3 `
          -FindType FindByThumbprint -FindValue 865D6178112D6B88B447250B084164A345E435D3 `
          -StoreLocation CurrentUser -StoreName My