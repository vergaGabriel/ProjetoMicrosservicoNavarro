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

        Console.Write("ID do pedido: ");
        int idPedido = int.Parse(Console.ReadLine());

        Console.Write("Novo status (ex: confirmado, cancelado, entregue): ");
        string novoStatus = Console.ReadLine();

        var status = new
        {
            IdPedido = idPedido,
            NovoStatus = novoStatus,
            DataAtualizacao = DateTime.Now
        };

        string mensagemJson = JsonSerializer.Serialize(status);
        var body = Encoding.UTF8.GetBytes(mensagemJson);

        string routingKey = "pedido.statusAtualizado";

        channel.BasicPublish(
            exchange: exchangeName,
            routingKey: routingKey,
            basicProperties: null,
            body: body
        );

        Console.WriteLine($"\n[✓] Status do pedido enviado com sucesso:\n{mensagemJson}");
    }
}
