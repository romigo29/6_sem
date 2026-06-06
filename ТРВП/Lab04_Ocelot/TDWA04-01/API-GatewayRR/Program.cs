using API_GatewayRR.LoadBalancers;
using Ocelot.Configuration;
using Ocelot.DependencyInjection;
using Ocelot.Middleware;
using Ocelot.ServiceDiscovery.Providers;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddJsonFile("ocelot-rr.json", optional: false, reloadOnChange: true);
builder.Services
	.AddOcelot(builder.Configuration);
	//.AddCustomLoadBalancer((DownstreamRoute _, IServiceDiscoveryProvider discoveryProvider) => new RandomLoadBalancer(discoveryProvider.GetAsync));

var app = builder.Build();

await app.UseOcelot();

app.Run();
