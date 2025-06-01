using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace Subscriber
{
    class SubscriberEnvioEmail
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
            string queueName = "fila.notificacao.email";
            string routingKey = "notificacao.email";

            channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Direct);
            channel.QueueDeclare(queue: queueName, durable: false, exclusive: false, autoDelete: false, arguments: null);
            channel.QueueBind(queue: queueName, exchange: exchangeName, routingKey: routingKey);

            Console.WriteLine("[*] Aguardando mensagens de notificação de e-mail...");

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += async (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var mensagem = Encoding.UTF8.GetString(body);

                try
                {
                    var notificacaoJson = JsonDocument.Parse(mensagem);
                    var email = notificacaoJson.RootElement.GetProperty("Email").GetString();
                    var status = notificacaoJson.RootElement.GetProperty("StatusPedido").GetString();

                    Console.WriteLine($"[✓] Recebida notificação para {email} com status: {status}");

                    using var httpClient = new HttpClient();

                    // Requisição para a API de envio de e-mail
                    var emailRequest = new
                    {
                        ToEmail = email,
                        Subject = "Atualização do Pedido",
                        Body = $"Seu pedido está com status: {status}"
                    };

                    var jsonContent = new StringContent(JsonSerializer.Serialize(emailRequest), Encoding.UTF8, "application/json");

                    var response = await httpClient.PostAsync("http://api_email:5000/api/Email/enviar", jsonContent);

                    if (response.IsSuccessStatusCode)
                    {
                        Console.WriteLine($"[✓] E-mail enviado via API para {email}");
                    }
                    else
                    {
                        Console.WriteLine($"[ERRO] Falha ao chamar API de envio de e-mail. Status: {response.StatusCode}");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[ERRO] Erro ao processar notificação: {ex.Message}");
                    Console.WriteLine(mensagem);
                }
            };

            channel.BasicConsume(queue: queueName, autoAck: true, consumer: consumer);

            // Mantém o app ativo
            while (true)
            {
                Thread.Sleep(1000);
            }
        }
    }
}
