using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Channels;
using System.Threading.Tasks;

namespace SistemaUser.Infra.Messaging
{
    public class PublisherCadastro
    {
        public static void Publisher(string email, string status)
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
                exchange: exchangeName,
                type: ExchangeType.Direct,
                durable: true,
                autoDelete: false
            );

            var mensagem = new
            {
                Email = email,
                StatusPedido = status
            };

            string mensagemJson = JsonSerializer.Serialize(mensagem);
            var body = Encoding.UTF8.GetBytes(mensagemJson);

            channel.BasicPublish(
                exchange: exchangeName,
                routingKey: routingKey,
                basicProperties: null,
                body: body
            );

            Console.WriteLine($"[✓] Mensagem enviada para {email}");
        }


    }
}
