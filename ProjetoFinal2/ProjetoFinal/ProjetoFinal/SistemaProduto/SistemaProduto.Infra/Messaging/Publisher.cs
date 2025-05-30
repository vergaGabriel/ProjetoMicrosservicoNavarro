using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using SistemaProduto.Domain.DTO;
using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Channels;

namespace SistemaProduto.Infra
{
    public class Publisher
    {
        public static void EnviarPedidoCriado(Guid pedidoId, string usuarioId, string email, List<ItemPedidoDTO> itens)
        {
            var factory = new ConnectionFactory()
            {
                Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
            };

            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            string exchangeName = "LojaExchange";
            string routingKey = "carrinho.update";
            channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Direct);

            var carrinho = new
            {
                PedidoId = pedidoId,
                UsuarioId = usuarioId,
                Email = email,
                Itens = itens,
                DataCriacao = DateTime.UtcNow
            };

            string mensagemJson = JsonSerializer.Serialize(carrinho);
            var body = Encoding.UTF8.GetBytes(mensagemJson);

            channel.BasicPublish(
                exchange: exchangeName,
                routingKey: routingKey,
                basicProperties: null,
                body: body
            );

            // Manter o app rodando
            while (true)
            {
                Thread.Sleep(1000);
            }
        }
    }
}




