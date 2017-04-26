 
#Deploy by PS script from SF project

## Deploy app
Deploy-FabricApplication.ps1 -ApplicationPackagePath '..\pkg\Debug' -PublishProfileFile '..\PublishProfiles\Local.xml' -DeployOnly:$true -UnregisterUnusedApplicationVersionsAfterUpgrade $false -OverrideUpgradeBehavior 'None' -OverwriteBehavior 'Always' -SkipPackageValidation:$true -ErrorAction Stop

##Unpublish app
Import-Module 'C:\Program Files\Microsoft SDKs\Service Fabric\Tools\PSModule\ServiceFabricSDK\ServiceFabricSDK.psm1'; 
Unpublish-ServiceFabricApplication -ApplicationName 'fabric:/VisualObjects' -ErrorAction Stop



#Publish SF app by PowerShell
Import-Module "$ENV:ProgramFiles\Microsoft SDKs\Service Fabric\Tools\PSModule\ServiceFabricSDK\ServiceFabricSDK.psm1"
Connect-ServiceFabricCluster localhost:19000
Publish-NewServiceFabricApplication -ApplicationPackagePath ..\pkg\Debug -ApplicationParameterFilePath ..\ApplicationParameters\Local.xml


Connect-ServiceFabricCluster sfcluster1.chinanorth.cloudapp.chinacloudapi.cn:19000
Connect-ServiceFabricCluster jianwsfcluster1g.eastasia.cloudapp.azure.com:19000


Connect-ServiceFabricCluster sfcluster2.chinaeast.cloudapp.chinacloudapi.cn:19000

Connect-serviceFabricCluster -ConnectionEndpoint sfcluster2.chinaeast.cloudapp.chinacloudapi.cn:19000 `
          -KeepAliveIntervalInSec 10 `
          -X509Credential -ServerCertThumbprint E7A1734E98775ECADE03023F7F17DDA5A19AD9BB `
          -FindType FindByThumbprint -FindValue E7A1734E98775ECADE03023F7F17DDA5A19AD9BB `
          -StoreLocation CurrentUser -StoreName My

Connect-serviceFabricCluster -ConnectionEndpoint sfcluster3.chinaeast.cloudapp.chinacloudapi.cn:19000 `
          -KeepAliveIntervalInSec 10 `
          -X509Credential -ServerCertThumbprint E7A1734E98775ECADE03023F7F17DDA5A19AD9BB `
          -FindType FindByThumbprint -FindValue E7A1734E98775ECADE03023F7F17DDA5A19AD9BB `
          -StoreLocation CurrentUser -StoreName My


#Get cluster load info
Get-ServiceFabricClusterLoadInformation
#Get app load info
Get-ServiceFabricApplicationLoadInformation -ApplicationName "fabric:/StatefulActor1"

#Update app setting in SF cluster
Update-ServiceFabricApplication -Name fabric:/MyApplication1 6 -MaximumNodes 2
Update-ServiceFabricApplication -Name fabric:/MyApplication1 6 -MinimumNodes 6


#Upgrade SF app
Publish-UpgradedServiceFabricApplication -ApplicationPackagePath ..\pkg\Debug -ApplicationParameterFilePath ..\ApplicationParameters\Local.xml -UpgradeParameters @{"FailureAction"="Rollback"; "UpgradeReplicaSetCheckTimeout"=1; "Monitored"=$true; "Force"=$true}


#Unpublish app
Unpublish-ServiceFabricApplication -ApplicationName "fabric:/VisualObjects"

#Remove app type
Remove-ServiceFabricApplicationType -ApplicationTypeName "VisualObjectsApplicationType" -ApplicationTypeVersion "1.0.0"
Remove-ServiceFabricApplicationType -ApplicationTypeName WordCount -ApplicationTypeVersion 2.0.0


#Restrict app in certain node type
Update-ServiceFabricService -Stateful -ServiceName $serviceName -PlacementConstraints "NodeType == NodeType01"
Update-ServiceFabricService -Stateful -ServiceName "fabric:/StatefulActor1/Actor1ActorService" -PlacementConstraints "NodeType == nt1vm"