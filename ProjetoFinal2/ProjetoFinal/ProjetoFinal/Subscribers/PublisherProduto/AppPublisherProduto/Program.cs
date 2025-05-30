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

        Console.Write("Nome do produto: ");
        string nome = Console.ReadLine();

        Console.Write("Descrição: ");
        string descricao = Console.ReadLine();

        Console.Write("Preço unitário (use vírgula se for necessário): ");
        decimal preco = decimal.Parse(Console.ReadLine());

        Console.Write("Estoque disponível: ");
        int estoque = int.Parse(Console.ReadLine());


        var produto = new
        {
            Nome = nome,
            Descricao = descricao,
            PrecoUnidade = preco,
            Estoque = estoque
        };

        string mensagemJson = JsonSerializer.Serialize(produto);
        var body = Encoding.UTF8.GetBytes(mensagemJson);

        string routingKey = "produto.create";

        channel.BasicPublish(
            exchange: exchangeName,
            routingKey: routingKey,
            basicProperties: null,
            body: body
        );

        Console.WriteLine($"\n[✓] Produto enviado com sucesso:\n{mensagemJson}");
    }
}
