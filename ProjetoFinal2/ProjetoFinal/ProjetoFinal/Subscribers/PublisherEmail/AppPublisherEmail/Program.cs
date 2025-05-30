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

        Console.Write("Destinatário (email): ");
        string para = Console.ReadLine();

        Console.Write("Assunto: ");
        string assunto = Console.ReadLine();

        Console.Write("Mensagem: ");
        string mensagemTexto = Console.ReadLine();

        var email = new
        {
            Para = para,
            Assunto = assunto,
            Mensagem = mensagemTexto,
            DataEnvio = DateTime.Now
        };

        string mensagemJson = JsonSerializer.Serialize(email);
        var body = Encoding.UTF8.GetBytes(mensagemJson);

        string routingKey = "email.send";

        channel.BasicPublish(
            exchange: exchangeName,
            routingKey: routingKey,
            basicProperties: null,
            body: body
        );

        Console.WriteLine($"\n[✓] E-mail enviado com sucesso:\n{mensagemJson}");
    }
}
