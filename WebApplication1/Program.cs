using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () =>

    new { time = 21 }
);

app.MapPost("/", ([FromHeader(Name = "Authorization")] string authorization, [FromBody] Rootobject id) =>

    new { time = 22 }
);

app.MapPut("/", ([FromBody] Rootobject id) =>

    new { time = 23 }
);
app.Run();

public class Rootobject
{
    public int id { get; set; }
}