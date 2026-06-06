using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Ocelot.LoadBalancer.Interfaces;
using Ocelot.Responses;
using Ocelot.Values;

namespace API_GatewayRR.LoadBalancers
{
	public class RandomLoadBalancer : ILoadBalancer
	{
		private readonly Func<Task<List<Service>>> _services;

		public string Type { get; }

		// Public parameterless constructor required by AddCustomLoadBalancer<T>()
		public RandomLoadBalancer() : this(() => Task.FromResult(new List<Service>()))
		{
		}

		// Optional constructor to supply services provider
		public RandomLoadBalancer(Func<Task<List<Service>>> services)
		{
			_services = services ?? throw new ArgumentNullException(nameof(services));
			Type = nameof(RandomLoadBalancer);
		}

		public void Release(ServiceHostAndPort hostAndPort)
		{
		}

		public async Task<Response<ServiceHostAndPort>> LeaseAsync(HttpContext context)
		{
			var services = await _services();

			if (services.Count == 0)
			{
				throw new InvalidOperationException("No downstream services are configured.");
			}

			int value = Random.Shared.Next(100);

			Service selected;

			if (value < 50)
			{
				selected = FindService(services, 5001) ?? services[0];
			}
			else if (value < 80)
			{
				selected = FindService(services, 5002) ?? services[Math.Min(1, services.Count - 1)];
			}
			else
			{
				selected = FindService(services, 5003) ?? services[services.Count - 1];
			}

			return new OkResponse<ServiceHostAndPort>(selected.HostAndPort);
		}

		private static Service? FindService(List<Service> services, int port)
		{
			return services.FirstOrDefault(service => service.HostAndPort.DownstreamPort == port);
		}
	}
}
