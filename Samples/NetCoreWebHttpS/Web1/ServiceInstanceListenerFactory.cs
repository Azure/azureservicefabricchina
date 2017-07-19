using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.ServiceFabric.Services.Communication.AspNetCore;
using Microsoft.ServiceFabric.Services.Communication.Runtime;
using System;
using System.Fabric;
using System.IO;

namespace Web1
{
    public static class ServiceInstanceListenerFactory
    {
        public static ServiceInstanceListener CreateExternalListener(Type startupType, Action<StatelessServiceContext, string> loggingCallback)
        {
            return new ServiceInstanceListener(serviceContext =>
            {
                return new WebListenerCommunicationListener(serviceContext, "ServiceEndpoint", (url, listener) =>
                {
                    loggingCallback(serviceContext, $"Starting WebListener on {url}");

                    return new WebHostBuilder().UseWebListener()
                                .ConfigureServices(
                                    services => services
                                        .AddSingleton<StatelessServiceContext>(serviceContext))
                                .UseContentRoot(Directory.GetCurrentDirectory())
                                .UseServiceFabricIntegration(listener, ServiceFabricIntegrationOptions.None)
                                .UseStartup(startupType)
                                .UseUrls(url)
                                .Build();
                });
            });
        }
    }
}
