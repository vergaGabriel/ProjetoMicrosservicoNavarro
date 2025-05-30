using Microsoft.AspNetCore.Connections;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using System.Text;
using Domain;
using RabbitMQ.Client;

[ApiController]
[Route("api")]
public class CarrinhoController : ControllerBase
{
    private readonly RedisCarrinhoService _carrinhoService;
    private readonly ConnectionFactory _factory;

    public CarrinhoController(RedisCarrinhoService carrinhoService)
    {
        _carrinhoService = carrinhoService;
        _factory = new ConnectionFactory
        {
            Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
        };
    }

    [HttpPost("{id}/carrinho/adicionar")]
    public async Task<IActionResult> AdicionarItem(string id, [FromBody] ItemCarrinho dto)
    {
        var item = new ItemCarrinho
        {
            ProdutoId = dto.ProdutoId,
            Quantidade = dto.Quantidade
        };

        await _carrinhoService.AdicionarItemAsync(id, item);
        return Ok(new { mensagem = "Item adicionado ao carrinho." });
    }

    [HttpPost("{usuarioId}/carrinho/finalizar")]
    public async Task<IActionResult> FinalizarPedido(string usuarioId)
    {
        var itens = await _carrinhoService.ObterItensAsync(usuarioId);
        if (itens == null || itens.Count == 0)
            return BadRequest(new { mensagem = "Carrinho vazio." });

        using var connection = _factory.CreateConnection();
        using var channel = connection.CreateModel();

        string exchangeName = "LojaExchange";
        string routingKey = "carrinho.criado";

        channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Direct);

        var pedidoId = Guid.NewGuid();

        var mensagem = JsonSerializer.Serialize(new
        {
            PedidoId = pedidoId,
            UsuarioId = usuarioId,
            Email = "teste@gmail.com",
            Itens = itens
        });

        var body = Encoding.UTF8.GetBytes(mensagem);
        channel.BasicPublish(exchange: exchangeName,
                             routingKey: routingKey,
                             basicProperties: null,
                             body: body);

        await _carrinhoService.LimparCarrinhoAsync(usuarioId);

        return Ok(new { mensagem = "Pedido finalizado e enviado para processamento." });
    } 
}
