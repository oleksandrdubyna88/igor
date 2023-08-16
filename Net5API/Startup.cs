using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Security.Claims;
using System.Text;

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
                endpoints.MapPost("/{id}/oauth2/v2.0/token", async context =>
                {
                    var id = context.Request.RouteValues["id"] as string;
                    var body = await new StreamReader(context.Request.Body).ReadToEndAsync();

                    string secretKey = "your-secret-key";
                    byte[] keyBytes = Encoding.UTF8.GetBytes(secretKey);

                    if (keyBytes.Length < 256 / 8)
                    {
                        Array.Resize(ref keyBytes, 256 / 8);
                    }

                    var securityKey = new SymmetricSecurityKey(keyBytes);

                    var claims = new[]
                    {
                        new Claim("id", id),
                        new Claim("body", body) 
                    };

                    var tokenDescriptor = new SecurityTokenDescriptor
                    {
                        Subject = new ClaimsIdentity(claims),
                        Expires = DateTime.UtcNow.AddHours(1),
                        SigningCredentials = new SigningCredentials(
                            securityKey, SecurityAlgorithms.HmacSha256Signature
                        )
                    };

                    var tokenHandler = new JwtSecurityTokenHandler();

                    var token = tokenHandler.CreateToken(tokenDescriptor);
                    var tokenString = tokenHandler.WriteToken(token);

                    await context.Response.WriteAsJsonAsync(tokenString);
                });

                endpoints.MapGet("/", async context =>
                {
                    var authorization = context.Request.Headers["Authorization"].ToString();
                    await context.Response.WriteAsJsonAsync(new Rootobject { guid = Guid.NewGuid(), senderId = "testSenderId", recipientId = "testRecipientId", shipmentType = "HOUSE", globalShipmentNumber = "00001" });
                });

                endpoints.MapPost("/", async context =>
                {
                    var authorization = context.Request.Headers["Authorization"].ToString();
                    var model = await context.Request.ReadFromJsonAsync<List<Rootobject>>();
                    await context.Response.WriteAsJsonAsync(model);
                });

                endpoints.MapPut("/", async context =>
                {
                    var authorization = context.Request.Headers["Authorization"].ToString();
                    var model = await context.Request.ReadFromJsonAsync<List<Rootobject>>();
                    await context.Response.WriteAsJsonAsync(model);
                });

                endpoints.MapDelete("/{id}", async context =>
                {
                    var authorization = context.Request.Headers["Authorization"].ToString();
                    var id = context.Request.RouteValues["id"] as string;
                    await context.Response.WriteAsJsonAsync($"Deleted record with ID: {id}");
                });
            });
        }
    }

    public class Rootobject
    {
        public Guid guid { get; set; }
        public string senderId { get; set; }
        public string recipientId { get; set; }
        public string shipmentType { get; set; }
        public string globalShipmentNumber { get; set; }
    }
}
