var builder = WebApplication.CreateBuilder(args);

string nick = args.FirstOrDefault(a => a.StartsWith("Nick="))?.Split("=")[1] ?? "Unknown";
int port = int.Parse(args.FirstOrDefault(a => a.StartsWith("Port="))?.Split("=")[1] ?? "5000");
int delay = int.Parse(args.FirstOrDefault(a => a.StartsWith("Delay="))?.Split("=")[1] ?? "1000");

builder.WebHost.UseUrls($"http://localhost:{port}");

var app = builder.Build();

async Task ApplyDelay(string method)
{
	int actualDelay = method switch
	{
		"GET" => delay / 3,
		"POST" => (2 * delay) / 3,
		"PUT" => delay,
		"DELETE" => delay / 4,
		_ => 0
	};

	await Task.Delay(actualDelay);
}

app.MapGet("/A", async context =>
{
	await ApplyDelay("GET");

	await context.Response.WriteAsJsonAsync(new
	{
		Nick = nick,
		Method = "GET",
		Delay = delay
	});
});

app.MapPost("/A", async context =>
{
	await ApplyDelay("POST");

	await context.Response.WriteAsJsonAsync(new
	{
		Nick = nick,
		Method = "POST",
		Delay = delay
	});
});

app.MapPut("/A", async context =>
{
	await ApplyDelay("PUT");

	await context.Response.WriteAsJsonAsync(new
	{
		Nick = nick,
		Method = "PUT",
		Delay = delay
	});
});

app.MapDelete("/A", async context =>
{
	await ApplyDelay("DELETE");

	await context.Response.WriteAsJsonAsync(new
	{
		Nick = nick,
		Method = "DELETE",
		Delay = delay
	});
});

app.Run();