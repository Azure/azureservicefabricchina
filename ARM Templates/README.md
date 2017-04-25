

```sh

#Login with China Azure account
Add-AzureRmAccount -EnvironmentName azurechinacloud 
Select-AzureRmSubscription –SubscriptionId ***

#Create SF Cluster (Unsecure)
Test-AzureRmResourceGroupDeployment -ResourceGroupName jianwSFRG -TemplateFile ".\azuredeploy.json" -TemplateParameterFile ".\azuredeploy.parameters.json" 
New-AzureRmResourceGroupDeployment -Name exampleARM-SF -ResourceGroupName jianwSFRG -TemplateFile ".\azuredeploy.json" -TemplateParameterFile ".\azuredeploy.parameters.json" 

# Get resources for SF Cluster
Get-AzureRmResource | Where-Object {$_.ResourceGroupName -eq "jianwsfrgbj"}

```
