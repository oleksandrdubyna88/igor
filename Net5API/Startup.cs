using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;

namespace Net5API
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {

            services.AddControllers();
        }

        public void Configure(IApplicationBuilder app)
        {
            app.UseRouting();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapGet("/", async context =>
                {
                    await context.Response.WriteAsJsonAsync(new Rootobject { id = Guid.NewGuid(), name = "testName", datetimestamp = DateTime.UtcNow });
                });

                endpoints.MapPost("/", async context =>
                {
                    var authorization = context.Request.Headers["Authorization"].ToString();
                    var model = await context.Request.ReadFromJsonAsync<Rootobject>();
                    await context.Response.WriteAsJsonAsync(model);
                });

                endpoints.MapPut("/", async context =>
                {
                    var model = await context.Request.ReadFromJsonAsync<Rootobject>();
                    await context.Response.WriteAsJsonAsync(model);
                });

                endpoints.MapDelete("/{id}", async context =>
                {
                    var id = context.Request.RouteValues["id"] as string;
                    await context.Response.WriteAsJsonAsync($"Deleted record with ID: {id}");
                });
            });
        }
    }

    public class Rootobject
    {
        public Guid id { get; set; }
        public string name { get; set; }
        public DateTime datetimestamp { get; set; }
    }
}
