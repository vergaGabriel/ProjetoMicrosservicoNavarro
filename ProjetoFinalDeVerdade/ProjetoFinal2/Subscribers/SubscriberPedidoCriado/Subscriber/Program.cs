using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        var factory = new ConnectionFactory()
        {
            Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
        };

        using var connection = factory.CreateConnection();
        using var channel = connection.CreateModel();

        string exchangeName = "LojaExchange";
        string queueName = "fila.pedido.criado";
        string routingKey = "pedido.criado";

        channel.ExchangeDeclare(
            exchange: exchangeName,
            type: ExchangeType.Direct,
            durable: true,
            autoDelete: false
        );

        channel.QueueDeclare(queue: queueName, durable: false, exclusive: false, autoDelete: false, arguments: null);
        channel.QueueBind(queue: queueName, exchange: exchangeName, routingKey: routingKey);

        Console.WriteLine("[*] Aguardando mensagens de pedido criado...");

        var consumer = new EventingBasicConsumer(channel);
        consumer.Received += async (model, ea) =>
        {
            var body = ea.Body.ToArray();
            var mensagem = Encoding.UTF8.GetString(body);

            try
            {
                Console.WriteLine($"[x] Pedido recebido: {mensagem}");

                using var httpClient = new HttpClient();

                // Faz um POST para o endpoint /api/pedido
                var content = new StringContent(mensagem, Encoding.UTF8, "application/json");
                var response = await httpClient.PostAsync("http://api_pedido:5000/api/Pedidos", content);

                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[ERRO] Falha ao enviar pedido. Status: {response.StatusCode}");
                }
                else
                {
                    Console.WriteLine($"[✓] Pedido enviado com sucesso!");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERRO] Erro ao processar mensagem: {ex.Message}");
                Console.WriteLine(mensagem);
            }
        };

        channel.BasicConsume(queue: queueName, autoAck: true, consumer: consumer);

        // Mantém o app rodando
        while (true)
        {
            Thread.Sleep(1000);
        }
    }
}
