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
        int idUser = int.Parse(Console.ReadLine());

        Console.Write("ID do endereço de entrega: ");
        int idEndereco = int.Parse(Console.ReadLine());

        Console.Write("Status do pedido (ex: pendente, confirmado, cancelado): ");
        string status = Console.ReadLine();

        Console.Write("Valor total do pedido (use vírgula se for necessário): ");
        decimal valorTotal = decimal.Parse(Console.ReadLine());

        Console.Write("Observações (opcional): ");
        string observacoes = Console.ReadLine();

        var pedido = new
        {
            IdUser = idUser,
            IdEndereco = idEndereco,
            Status = status,
            ValorTotal = valorTotal,
            Observacoes = observacoes,
            DataCriacao = DateTime.Now
        };

        string mensagemJson = JsonSerializer.Serialize(pedido);
        var body = Encoding.UTF8.GetBytes(mensagemJson);

        string routingKey = "pedido.create";

        channel.BasicPublish(
            exchange: exchangeName,
            routingKey: routingKey,
            basicProperties: null,
            body: body
        );

        Console.WriteLine($"\n[✓] Pedido enviado com sucesso:\n{mensagemJson}");
    }
}
