
After SF SDK installation, there will be a native SF explorer tool for managing service fabric clusters, including on premise ones and cloud clusters, the location of the tool is:

C:\Program Files\Microsoft SDKs\Service Fabric\Tools\ServiceFabricExplorer



Service fabric cluster can be created quickly via serval ways, such as Azure Portal, Visual Studio and ARM template, no matter which way you choose, you will finally get an ARM template created for Azure platform to provision your customized cluster. Generally, for continuous delivery and continuous integration (CI/CD), ARM template is a perfect way to make the customized cluster replicable anytime
without duplicate efforts, and the guide of create service fabric cluster and popular service fabric ARM templates are good reference for designing and deploying your Service Fabric cluster.

When following the guide or template to design your service fabric cluster, please be noted that endpoints in Azure clouds are
different, see the endpoint mapping.
