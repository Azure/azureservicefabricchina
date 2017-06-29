using Actor1.Interfaces;
using Microsoft.ServiceFabric.Actors;
using Microsoft.ServiceFabric.Actors.Client;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Web.Http;

namespace Gateway_WebApi1.Controllers
{
    [ServiceRequestActionFilter]
    public class ValuesController : ApiController
    {
        // GET api/values 
        public IEnumerable<string> Get()
        {
            ActorId aid = new ActorId(Guid.NewGuid());
            var actorProxy = ActorProxy.Create<IActor1>(aid, "fabric:/Invokes");
            for (int i = 1; i < 5; i++)
            {
                actorProxy.SetCountAsync(i).Wait();
                Thread.Sleep(1000);
            }

            return new string[] { "value1", actorProxy.GetCountAsync().Result.ToString() };
        }

        // GET api/values/5 
        public string Get(int id)
        {
            return "value";
        }

        // POST api/values 
        public void Post([FromBody]string value)
        {
        }

        // PUT api/values/5 
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/values/5 
        public void Delete(int id)
        {
        }
    }
}
