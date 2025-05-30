using RabbitMQ.Client;
using System;
using System.Text;
using System.Text.Json;

class Program
{
    static void Main(string[] args)
    {
        var factory = new ConnectionFactory()
        {
            Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
        };

        using var connection = factory.CreateConnection();
        using var channel = connection.CreateModel();

        string exchangeName = "LojaExchange";
        channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Direct);

        Console.Write("ID do usuário: ");
        int idUsuario = int.Parse(Console.ReadLine());

        Console.Write("ID do produto: ");
        int produtoId = int.Parse(Console.ReadLine());

        Console.Write("Ação (adicionar/remover/alterar): ");
        string acao = Console.ReadLine();

        Console.Write("Quantidade: ");
        int quantidade = int.Parse(Console.ReadLine());

        var carrinho = new
        {
            IdUsuario = idUsuario,
            ProdutoId = produtoId,
            Acao = acao,
            Quantidade = quantidade,
            DataAtualizacao = DateTime.Now
        };

        string mensagemJson = JsonSerializer.Serialize(carrinho);
        var body = Encoding.UTF8.GetBytes(mensagemJson);

        string routingKey = "carrinho.update";

        channel.BasicPublish(
            exchange: exchangeName,
            routingKey: routingKey,
            basicProperties: null,
            body: body
        );

        Console.WriteLine($"\n[✓] Atualização de carrinho enviada com sucesso:\n{mensagemJson}");
    }
}
