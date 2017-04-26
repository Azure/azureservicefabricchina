using System;
using System.Collections.Generic;
using System.Fabric;
using System.Fabric.Description;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.ServiceFabric.Data.Collections;
using Microsoft.ServiceFabric.Services.Client;
using Microsoft.ServiceFabric.Services.Communication.Runtime;
using Microsoft.ServiceFabric.Services.Remoting;
using Microsoft.ServiceFabric.Services.Remoting.Client;
using Microsoft.ServiceFabric.Services.Remoting.Runtime;
using Microsoft.ServiceFabric.Services.Runtime;

namespace rpcStateful1
{
    public interface IMyService : IService
    {
        Task<string> GetHelloWorld();
    }

    /// <summary>
    /// An instance of this class is created for each service replica by the Service Fabric runtime.
    /// </summary>
    internal sealed class rpcStateful1 : StatefulService, IMyService
    {
        public rpcStateful1(StatefulServiceContext context)
            : base(context)
        { }

        public Task<string> GetHelloWorld()
        {
            return Task.FromResult("Hello!");
        }

        /// <summary>
        /// Optional override to create listeners (e.g., HTTP, Service Remoting, WCF, etc.) for this service replica to handle client or user requests.
        /// </summary>
        /// <remarks>
        /// For more information on service communication, see http://aka.ms/servicefabricservicecommunication
        /// </remarks>
        /// <returns>A collection of listeners.</returns>
        protected override IEnumerable<ServiceReplicaListener> CreateServiceReplicaListeners()
        {
            return new[] {new ServiceReplicaListener(context => this.CreateServiceRemotingListener(context)),};
        }

        /// <summary>
        /// This is the main entry point for your service replica.
        /// This method executes when this replica of your service becomes primary and has write status.
        /// </summary>
        /// <param name="cancellationToken">Canceled when Service Fabric needs to shut down this service replica.</param>
        protected override async Task RunAsync(CancellationToken cancellationToken)
        {
            // TODO: Replace the following sample code with your own logic 
            //       or remove this RunAsync override if it's not needed in your service.

            IList<string> list = Context.CodePackageActivationContext.GetConfigurationPackageNames();

            FabricRuntime.GetActivationContext().GetConfigurationPackageObject("Config");
            string str = FabricRuntime.GetActivationContext().GetServiceTypes()[0].PlacementConstraints;
            

            // IF need to do balancing in RPC, add logistics with the low/high keys and partition count
            using (var client = new FabricClient())
            {
                var serviceDescription = await client.ServiceManager.GetServiceDescriptionAsync(this.Context.ServiceName);
                var partitions = await client.QueryManager.GetPartitionListAsync(new Uri("fabric:/sfcomm/rpcStateful1"));
                int partitionLength = partitions.Count;
                long lowKey = ((Int64RangePartitionInformation) partitions[0].PartitionInformation).LowKey;
                long highKey = ((Int64RangePartitionInformation)partitions[partitionLength-1].PartitionInformation).HighKey;

                // RPC Call
                IMyService helloWorldClient = ServiceProxy.Create<IMyService>(new Uri("fabric:/sfcomm/rpcStateful1"), new ServicePartitionKey(lowKey));
                string message = await helloWorldClient.GetHelloWorld();
            }





            var myDictionary = await this.StateManager.GetOrAddAsync<IReliableDictionary<string, long>>("myDictionary");

            while (true)
            {
                cancellationToken.ThrowIfCancellationRequested();

                using (var tx = this.StateManager.CreateTransaction())
                {
                    var result = await myDictionary.TryGetValueAsync(tx, "Counter");

                    ServiceEventSource.Current.ServiceMessage(this, "Current Counter Value: {0}",
                        result.HasValue ? result.Value.ToString() : "Value does not exist.");

                    await myDictionary.AddOrUpdateAsync(tx, "Counter", 0, (key, value) => ++value);

                    // If an exception is thrown before calling CommitAsync, the transaction aborts, all changes are 
                    // discarded, and nothing is saved to the secondary replicas.
                    await tx.CommitAsync();
                }

                await Task.Delay(TimeSpan.FromSeconds(1), cancellationToken);
            }
        }
    }
}
