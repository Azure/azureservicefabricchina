


Service fabric cluster can be created quickly via serval ways, such as Azure Portal, Visual Studio and ARM template, no matter which way you choose, you will finally get an ARM template created for Azure platform to provision your customized cluster. Generally, for continuous delivery and continuous integration (CI/CD), ARM template is a perfect way to make the customized cluster replicable anytime
without duplicate efforts, and the guide of create service fabric cluster and <a href="https://github.com/Azure/azure-quickstart-templates">popular service fabric ARM templates</a> are good reference for designing and deploying your Service Fabric cluster.

When following the global guide or template to design your service fabric cluster, please be noted that endpoints in Azure clouds are different, see the <a href="https://msdn.microsoft.com/en-us/library/azure/dn578439.aspx">endpoint mapping</a>.


Quick creating cluster is performed as below:

```sh

#Login with China Azure account
Add-AzureRmAccount -EnvironmentName azurechinacloud 
Select-AzureRmSubscription –SubscriptionId ***

#Create SF Cluster (Unsecure)
Test-AzureRmResourceGroupDeployment -ResourceGroupName jianwSFRG -TemplateFile ".\azuredeploy.json" -TemplateParameterFile ".\azuredeploy.parameters.json" 
New-AzureRmResourceGroupDeployment -Name exampleARM-SF -ResourceGroupName jianwSFRG -TemplateFile ".\azuredeploy.json" -TemplateParameterFile ".\azuredeploy.parameters.json" 

# Get resources for SF Cluster
Get-AzureRmResource | Where-Object {$_.ResourceGroupName -eq "jianwSFRG"}

```
