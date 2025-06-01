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
    class SubscriberNotificacao
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
            string queueName = "fila.pedido.status";
            string routingKey = "pedido.notificacao";

            channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Direct);
            channel.QueueDeclare(queue: queueName, durable: false, exclusive: false, autoDelete: false, arguments: null);
            channel.QueueBind(queue: queueName, exchange: exchangeName, routingKey: routingKey);

            Console.WriteLine("[*] Aguardando status de pedidos...");

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += async (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var mensagem = Encoding.UTF8.GetString(body);

                try
                {
                    var pedidoStatusJson = JsonDocument.Parse(mensagem);
                    var usuarioId = pedidoStatusJson.RootElement.GetProperty("UsuarioId").GetString();
                    var status = pedidoStatusJson.RootElement.GetProperty("Status").GetString();

                    Console.WriteLine($"[✓] Recebido status: {status} para usuário {usuarioId}");

                    using var httpClient = new HttpClient();

                    // Consulta a API de usuários
                    var usuarioResponse = await httpClient.GetAsync($"http://api_usuario:5000/api/Usuario/{usuarioId}");

                    if (!usuarioResponse.IsSuccessStatusCode)
                    {
                        Console.WriteLine($"[ERRO] Falha ao buscar usuário. Status: {usuarioResponse.StatusCode}");
                        return;
                    }

                    var usuarioJson = await usuarioResponse.Content.ReadAsStringAsync();
                    var usuario = JsonDocument.Parse(usuarioJson);
                    var email = usuario.RootElement.GetProperty("email").GetString();

                    Console.WriteLine($"[✓] Usuário {usuarioId} tem e-mail: {email}");

                    Publisher.EnviarNotificacaoEmail(email, status);

                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[ERRO] Erro ao processar mensagem: {ex.Message}");
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

