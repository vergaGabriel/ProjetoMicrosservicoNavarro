using Microsoft.OpenApi.Models;
using Infra;
using Domain;
using CarrinhoAPI.Controllers;


var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<RedisCarrinhoService>(provider =>
{
    var redisConnection = builder.Configuration.GetConnectionString("Redis")
                          ?? "localhost:6379";
    return new RedisCarrinhoService(redisConnection);
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "SistemaCarrinho", Version = "v1" });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();