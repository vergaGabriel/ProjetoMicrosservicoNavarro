using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using RabbitMQ.Client;

namespace SistemaPedidos.Infra.Messaging
{
    public class Publisher
    {
        public static void EnviarStatusPedido(int usuarioId, string status)
        {
            var factory = new ConnectionFactory()
            {
                Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
            };

            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            string exchangeName = "LojaExchange";
            string routingKey = "pedido.notificacao";

            channel.ExchangeDeclare(
                exchange: "LojaExchange",
                type: ExchangeType.Direct,
                durable: true,
                autoDelete: false
            );


            var mensagem = new
            {
                UsuarioId = usuarioId,
                Status = status,
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

            Console.WriteLine($"[✓] Status do pedido enviado para fila: {status}");
        }
    }
}
