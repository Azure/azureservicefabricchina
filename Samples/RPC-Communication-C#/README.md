

### Define and implement APIs of RPC

```sh
    public interface IMyService : IService    
    {        
        Task<string> GetHelloWorld();    
    }
    /// <summary>    
    /// An instance of this class is created for each service replica by the Service Fabric runtime.    
    /// </summary>    
    internal sealed class rpcStateful1 : StatefulService, IMyService    
    {        
        public rpcStateful1(StatefulServiceContext context)            : base(context)        
        { 
        }

        public Task<string> GetHelloWorld()        
        {            
            return Task.FromResult("Hello!");        
        }
        
        ...
```

### RPC request with customized balancing
```sh
            // IF need to do balancing in RPC, add logistics with the low/high keys and partition count            
            using (var client = new FabricClient())            
            {                
                var serviceDescription = await client.ServiceManager.GetServiceDescriptionAsync(this.Context.ServiceName);                
                var partitions = await client.QueryManager.GetPartitionListAsync(new Uri("fabric:/sfcomm/rpcStateful1"));                
                int partitionLength = partitions.Count;                
                long lowKey = ((Int64RangePartitionInformation) partitions[0].PartitionInformation).LowKey;                
                long highKey = ((Int64RangePartitionInformation)partitions[partitionLength-1].PartitionInformation).HighKey;
                // RPC Call                
                IMyService helloWorldClient = ServiceProxy.Create<IMyService>(new Uri("fabric:/sfcomm/rpcStateful1"), 
                new ServicePartitionKey(lowKey));                
                string message = await helloWorldClient.GetHelloWorld();            
            }
```
