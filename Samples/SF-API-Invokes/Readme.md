Typical Communications with API in SF:
- Resolve and Connect via Naming service. See <a href="https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-reliable-services-communication" target="_blank">Reference</a>
- Resolve and Connect via DNS service. See <a href="https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-dnsservice" target="_blank">Reference</a>
- Connect and Get Forwarded via Reverse Proxy. See <a href="https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-reverseproxy" target="_blank">Reference</a>
- Connect as external via Azure Load Balancer (public domain & IP). See <a href="https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-connect-and-communicate-with-services" target="_blank">Reference</a>

Bring your own ways as processes' talks in traditional:
- RPC
- WCF
- Socket
- ...

Snipnet in this sample to show SPI invokes:

        // GET api/values         
        [HttpGet]        
        [Route("values")]        
        public IEnumerable<string> Get()        
        {            
            Uri serviceUri = new Uri(FabricRuntime.GetActivationContext().ApplicationName + "/WebApi_Service1");
            ServicePartitionResolver resolver = ServicePartitionResolver.GetDefault();            
            ResolvedServicePartition partition = resolver.ResolveAsync(serviceUri, new ServicePartitionKey(), CancellationToken.None).Result;
            ResolvedServiceEndpoint endpoint = partition.GetEndpoint();
            JObject addresses = JObject.Parse(endpoint.Address);            
            string address = (string)addresses["Endpoints"].First();
            HttpClient client = new HttpClient();            
            client.BaseAddress = new Uri(address);            
            client.DefaultRequestHeaders.Accept.Clear();            
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));           
            HttpResponseMessage response =  client.GetAsync("api/values").Result;            
            if (response.IsSuccessStatusCode)            
            {                
                 return new string[] {"Result rendered from backend API", response.Content.ReadAsStringAsync().Result};            
            }
            return new string[] { "value1", "value2" };        
         }
         
        // GET api/values/5         
        [HttpGet]        
        [Route("values/id")]        
        public string Get(int id)        
        {            
            Uri serviceUri = new Uri(FabricRuntime.GetActivationContext().ApplicationName + "/WebApi_Service1");            
            TimeSpan backoffQueryDelay = TimeSpan.FromSeconds(3);            
            FabricClient fabricClient = new FabricClient();            
            HttpCommunicationClientFactory communicationFactory = new HttpCommunicationClientFactory(new ServicePartitionResolver(() => fabricClient));            
            string content = "nothing happened.";
            try            
            {                
            ServicePartitionClient<HttpCommunicationClient> partitionClient                    = new ServicePartitionClient<HttpCommunicationClient>(communicationFactory, serviceUri, new ServicePartitionKey());
            partitionClient.InvokeWithRetryAsync(async (client) =>                    
            {                        
            HttpResponseMessage response = await client.HttpClient.GetAsync(new Uri(client.Url, "api/values"));                       
            content = response.Content.ReadAsStringAsync().Result;                    
            }).Wait();            
            }            
            catch (Exception ex)            
            {                
            // Sample code: print exception                
            return "Error occured at " + DateTime.Now;            
            }            
            return content;        
        }
