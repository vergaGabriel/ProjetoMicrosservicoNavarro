using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Domain;
using RabbitMQ.Client;

namespace Infra.Messaging
{
    public class Publisher
    {
        public static void EnviarPedidoCriado(string usuarioId, string formaPgto, List<ItemCarrinho> itens)
        {
            var factory = new ConnectionFactory()
            {
                Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
            };

            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            string exchangeName = "LojaExchange";
            string routingKey = "carrinho.criado";

            channel.ExchangeDeclare(
                exchange: "LojaExchange",
                type: ExchangeType.Direct,
                durable: true,
                autoDelete: false
            );

            var mensagem = new
            {
                UsuarioId = usuarioId,
                FormaPgto = formaPgto,
                Itens = itens,
                DataCriacao = DateTime.UtcNow
            };

            var mensagemJson = JsonSerializer.Serialize(mensagem);
            var body = Encoding.UTF8.GetBytes(mensagemJson);

            channel.BasicPublish(
                exchange: exchangeName,
                routingKey: routingKey,
                basicProperties: null,
                body: body
            );
        }
    }
}
