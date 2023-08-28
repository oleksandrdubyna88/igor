using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Reflection.PortableExecutable;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

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
            app.Use(next => context =>
            {
                context.Request.EnableBuffering();
                return next(context);
            });
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
                    await context.Response.WriteAsJsonAsync(new Rootobject 
                    { 
                        guid = Guid.NewGuid(), 
                        senderId = "TGOPS",
                        recipientId = "SGL",
                        shipmentType = "HOUSE", 
                        modeOfTransport = "ROAD",
                        localShipmentNumber = "22234",
                        globalShipmentNumber = "NORAM-99884"
                    });
                });

                endpoints.MapPost("/", async context =>
                {
                    var authorization = context.Request.Headers["Authorization"].ToString();

                    var jsonString = await new StreamReader(context.Request.Body).ReadToEndAsync();
                    var model = JsonConvert.DeserializeObject<List<Rootobject>>(jsonString);

                    if(model == null)
                    {
                        context.Response.StatusCode = 400;
                        await context.Response.WriteAsync("Invalid input data");
                        return;
                    }

                    await context.Response.WriteAsJsonAsync(new Response()
                    {
                        header = new Header()
                        {
                            messages = "All records failed"
                        },

                        data = new Data()
                        {
                            totalData = 1,
                            successData = 0,
                            failData = 1,
                            successRowsData = new List<SuccessRowsDatum>()
                            {
                            },
                            failRowsData = new List<FailRowsDatum>()
                            {
                                new FailRowsDatum()
                                {
                                    globalShipmentNumber = "39C313010",
                                    errorMessage = "globalShipmentNumber 39C313010 already exists"
                                }
                            }
                        }
                    });
                });

                endpoints.MapPut("/", async context =>
                {
                    var authorization = context.Request.Headers["Authorization"].ToString();

                    var jsonString = await new StreamReader(context.Request.Body).ReadToEndAsync();
                    var model = JsonConvert.DeserializeObject<List<Rootobject>>(jsonString);

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
        public string modeOfTransport { get; set; }
        public string localShipmentNumber { get; set; }
        public string globalShipmentNumber { get; set; }
    }

    public class Response
    {
        public Header header { get; set; }
        public Data data { get; set; }
    }

    public class Header
    {
        public string messages { get; set; }
    }

    public class Data
    {
        public int totalData { get; set; }
        public int successData { get; set; }
        public int failData { get; set; }
        public List<SuccessRowsDatum> successRowsData { get; set; }
        public List<FailRowsDatum> failRowsData { get; set; }
    }

    public class FailRowsDatum
    {
        public string globalShipmentNumber { get; set; }
        public string errorMessage { get; set; }
    }

    public class SuccessRowsDatum
    {
        public string globalShipmentNumber { get; set; }
        public string successMessage { get; set; }
    }
}
