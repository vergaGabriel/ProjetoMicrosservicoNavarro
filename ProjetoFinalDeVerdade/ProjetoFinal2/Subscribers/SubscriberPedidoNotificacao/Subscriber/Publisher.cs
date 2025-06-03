using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using RabbitMQ.Client;

namespace Subscriber
{
    public class Publisher
    {
        public static void EnviarNotificacaoEmail(string email, string status)
        {
            var factory = new ConnectionFactory()
            {
                Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
            };

            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            string exchangeName = "LojaExchange";
            string routingKey = "notificacao.email";

            channel.ExchangeDeclare(
                 exchange: "LojaExchange",
                 type: ExchangeType.Direct,
                 durable: true,
                 autoDelete: false
             );

            var mensagem = new
            {
                Email = email,
                StatusPedido = status,
                Data = DateTime.UtcNow
            };

            var mensagemJson = JsonSerializer.Serialize(mensagem);
            var body = Encoding.UTF8.GetBytes(mensagemJson);

            channel.BasicPublish(
                exchange: exchangeName,
                routingKey: routingKey,
                basicProperties: null,
                body: body
            );

            Console.WriteLine($"[✓] Notificação de e-mail enviada para {email}");
        }
    }
}
