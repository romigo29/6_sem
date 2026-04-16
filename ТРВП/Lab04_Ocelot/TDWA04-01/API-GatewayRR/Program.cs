using Ocelot.DependencyInjection;
using Ocelot.LoadBalancer.Interfaces;
using Ocelot.Middleware;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddJsonFile("ocelot.json", false, true);
builder.Services.AddOcelot();

var app = builder.Build();

//Custom Load Balancer
var random = new Random();

app.Map("/lb", async context =>
{
	int value = random.Next(100);

	string target;

	if (value < 50)
		target = "http://localhost:5001/A"; // X
	else if (value < 80)
		target = "http://localhost:5002/A"; // Y
	else
		target = "http://localhost:5003/A"; // Z

	var client = new HttpClient();

	var method = new HttpMethod(context.Request.Method);
	var request = new HttpRequestMessage(method, target);

	var response = await client.SendAsync(request);

	var content = await response.Content.ReadAsStringAsync();

	context.Response.StatusCode = (int)response.StatusCode;
	context.Response.ContentType = "application/json";

	await context.Response.WriteAsync(content);
});

await app.UseOcelot();

app.Run();