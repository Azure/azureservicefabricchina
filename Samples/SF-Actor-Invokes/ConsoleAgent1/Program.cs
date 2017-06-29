using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.ServiceFabric.Actors;
using Microsoft.ServiceFabric.Actors.Client;
using Actor1.Interfaces;
using System.Threading;

namespace ConsoleAgent1
{
    class Program
    {
        static void Main(string[] args)
        {

            ActorId aid = new ActorId(Guid.NewGuid());
            var actorProxy = ActorProxy.Create<IActor1>(aid, "fabric:/Invokes");
            for (int i = 1; i < 10; i++)
            {
                actorProxy.SetCountAsync(i).Wait();
                Console.WriteLine(actorProxy.GetCountAsync().Result);
                Thread.Sleep(1000);
            }

            Console.Read();

        }
    }
}
