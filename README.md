
#### By this github repo, specific templates, samples, practice and patterns for Service Fabric in China Azure will be shared, end users working with China Azure Service Fabric can refer to these materials first during planning, building, releasing and operationing phase to ensure best practice of projects.

Service Fabric is a distributed systems platform that makes it easy to package, deploy, and manage scalable and reliable microservices and addresses the significant challenges in developing and managing cloud applications. By using Service Fabric, developers and administrators can avoid solving complex infrastructure problems and focus instead on implementing mission-critical, demanding workloads knowing that they are scalable, reliable, and manageable. Service Fabric represents the next-generation middlewareplatform for building and managing these enterprise-class, Tier-1 cloud-scale applications.
Service fabric is coming up with completely different architecture.As PaaS V2, service fabric will run on top of Virtual Machines (ARM based) and host customer application by distributed computing cluster, by that pattern, backend incident like VM outage and customer operation like application upgrade will ideally cause 0 data loss and not impact real time transaction at all.

More reference:</br>
https://azure.microsoft.com/en-us/documentation/articles/service-fabric-overview/
https://www.azure.cn/documentation/articles/service-fabric-overview/ 

### Frequently used PowerShell commands and ARM templates for China Azure Service Fabric:
Common Practice - Service Fabric Cluster (China Azure):</br>
http://jianwstorage.blob.core.chinacloudapi.cn/sf-arm-templates/Mooncake-SF-Cluster-Deploy.ps1

Common Practice - Service Fabric App (China Azure):</br>
http://jianwstorage.blob.core.chinacloudapi.cn/sf-arm-templates/Mooncake-SF-App-Deploy.ps1

ARM templates for China Azure Service Fabric:</br>
http://jianwstorage.blob.core.chinacloudapi.cn/sf-arm-templates/ServiceFabric-ARMTemplates-ChinaAzure.zip

Service Fabric Helper script referred by common practice:</br> 
http://jianwstorage.blob.core.chinacloudapi.cn/sf-arm-templates/ServiceFabricRPHelpers.psm1


### Quick Start:
Setup local dev environment:</br>
https://azure.microsoft.com/en-us/documentation/articles/service-fabric-get-started/

Create first SF app:</br>
https://azure.microsoft.com/en-us/documentation/articles/service-fabric-create-your-first-application-in-visual-studio/




# Contributing
----------------------------------------------------------------------------------------------------------------------------------
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
