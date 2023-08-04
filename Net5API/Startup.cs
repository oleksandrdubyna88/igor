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
                    await context.Response.WriteAsJsonAsync(new { time = 21 });
                });

                endpoints.MapPost("/", async context =>
                {
                    var authorization = context.Request.Headers["Authorization"].ToString();
                    var id = await context.Request.ReadFromJsonAsync<Rootobject>();
                    await context.Response.WriteAsJsonAsync(new { time = 22 });
                });

                endpoints.MapPut("/", async context =>
                {
                    var id = await context.Request.ReadFromJsonAsync<Rootobject>();
                    await context.Response.WriteAsJsonAsync(new { time = 23 });
                });
            });
        }
    }

    public class Rootobject
    {
        public int id { get; set; }
    }
}
