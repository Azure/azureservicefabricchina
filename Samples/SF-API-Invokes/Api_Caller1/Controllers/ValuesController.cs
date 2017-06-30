using System.Collections.Generic;
using System.Web.Http;
using Microsoft.ServiceFabric.Services.Client;
using System.Fabric;
using System.Threading;
using System;
using System.Linq;
using Newtonsoft.Json.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using Microsoft.ServiceFabric.Services.Communication.Client;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;

namespace Api_Caller1.Controllers
{
    [ServiceRequestActionFilter]
    public class ValuesController : ApiController
    {
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
            HttpResponseMessage response =  client.GetAsync("api/values").Result;
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
                ServicePartitionClient<HttpCommunicationClient> partitionClient
                    = new ServicePartitionClient<HttpCommunicationClient>(communicationFactory, serviceUri, new ServicePartitionKey());

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

        // POST api/values 
        [HttpPost]
        [Route("values")]
        public void Post([FromBody]string value)
        {
        }

        //// PUT api/values/5 
        //public void Put(int id, [FromBody]string value)
        //{
        //}

        //// DELETE api/values/5 
        //public void Delete(int id)
        //{
        //}
    }


    public class HttpCommunicationClient : ICommunicationClient
    {
        public HttpCommunicationClient(HttpClient client, string address)
        {
            this.HttpClient = client;
            this.Url = new Uri(address);
        }

        public HttpClient HttpClient { get; }

        public Uri Url { get; }

        ResolvedServiceEndpoint ICommunicationClient.Endpoint { get; set; }

        string ICommunicationClient.ListenerName { get; set; }

        ResolvedServicePartition ICommunicationClient.ResolvedServicePartition { get; set; }
    }

    public class HttpCommunicationClientFactory : CommunicationClientFactoryBase<HttpCommunicationClient>
    {
        private HttpClient httpClient = new HttpClient();

        public HttpCommunicationClientFactory(IServicePartitionResolver resolver = null, IEnumerable<IExceptionHandler> exceptionHandlers = null)
            : base(resolver, CreateExceptionHandlers(exceptionHandlers))
        {
        }

        protected override void AbortClient(HttpCommunicationClient client)
        {
            // client with persistent connections should be abort their connections here.
            // HTTP clients don't hold persistent connections, so no action is taken.
        }

        protected override Task<HttpCommunicationClient> CreateClientAsync(string endpoint, CancellationToken cancellationToken)
        {
            // clients that maintain persistent connections to a service should 
            // create that connection here.
            // an HTTP client doesn't maintain a persistent connection.
            return Task.FromResult(new HttpCommunicationClient(this.httpClient, endpoint));
        }

        protected override bool ValidateClient(HttpCommunicationClient client)
        {
            // client with persistent connections should be validated here.
            // HTTP clients don't hold persistent connections, so no validation needs to be done.
            return true;
        }

        protected override bool ValidateClient(string endpoint, HttpCommunicationClient client)
        {
            // client with persistent connections should be validated here.
            // HTTP clients don't hold persistent connections, so no validation needs to be done.
            return true;
        }

        private static IEnumerable<IExceptionHandler> CreateExceptionHandlers(IEnumerable<IExceptionHandler> additionalHandlers)
        {
            return new[] { new HttpExceptionHandler() }.Union(additionalHandlers ?? Enumerable.Empty<IExceptionHandler>());
        }
    }

    public class HttpExceptionHandler : IExceptionHandler
    {
        public bool TryHandleException(ExceptionInformation exceptionInformation, OperationRetrySettings retrySettings, out ExceptionHandlingResult result)
        {
            if (exceptionInformation.Exception is TimeoutException)
            {
                result = new ExceptionHandlingRetryResult(exceptionInformation.Exception, false, retrySettings, retrySettings.DefaultMaxRetryCount);
                return true;
            }
            else if (exceptionInformation.Exception is ProtocolViolationException)
            {
                result = new ExceptionHandlingThrowResult();
                return true;
            }
            else if (exceptionInformation.Exception is SocketException)
            {
                result = new ExceptionHandlingRetryResult(exceptionInformation.Exception, false, retrySettings, retrySettings.DefaultMaxRetryCount);
                return true;
            }

            WebException we = exceptionInformation.Exception as WebException;

            if (we == null)
            {
                we = exceptionInformation.Exception.InnerException as WebException;
            }

            if (we != null)
            {
                HttpWebResponse errorResponse = we.Response as HttpWebResponse;

                if (we.Status == WebExceptionStatus.ProtocolError)
                {
                    if (errorResponse.StatusCode == HttpStatusCode.NotFound)
                    {
                        // This could either mean we requested an endpoint that does not exist in the service API (a user error)
                        // or the address that was resolved by fabric client is stale (transient runtime error) in which we should re-resolve.
                        result = new ExceptionHandlingRetryResult(exceptionInformation.Exception, false, retrySettings, retrySettings.DefaultMaxRetryCount);
                        return true;
                    }

                    if (errorResponse.StatusCode == HttpStatusCode.InternalServerError)
                    {
                        // The address is correct, but the server processing failed.
                        // This could be due to conflicts when writing the word to the dictionary.
                        // Retry the operation without re-resolving the address.
                        result = new ExceptionHandlingRetryResult(exceptionInformation.Exception, true, retrySettings, retrySettings.DefaultMaxRetryCount);
                        return true;
                    }
                }

                if (we.Status == WebExceptionStatus.Timeout ||
                    we.Status == WebExceptionStatus.RequestCanceled ||
                    we.Status == WebExceptionStatus.ConnectionClosed ||
                    we.Status == WebExceptionStatus.ConnectFailure)
                {
                    result = new ExceptionHandlingRetryResult(exceptionInformation.Exception, false, retrySettings, retrySettings.DefaultMaxRetryCount);
                    return true;
                }
            }

            result = null;
            return false;
        }
    }
}
