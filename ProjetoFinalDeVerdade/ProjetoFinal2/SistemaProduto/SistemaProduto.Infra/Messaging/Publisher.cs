using RabbitMQ.Client;
using SistemaProduto.Domain.DTO;
using System;
using System.Text;
using System.Text.Json;
using System.Collections.Generic;

namespace SistemaProduto.Infra
{
    public class Publisher
    {
        public static void EnviarPedidoCriado(string usuarioId, string formaPgto, List<ItemPedidoDTO> itens)
        {
            var factory = new ConnectionFactory()
            {
                Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
            };

            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            string exchangeName = "LojaExchange";
            string routingKey = "pedido.criado";

            // Garante que a exchange exista
            channel.ExchangeDeclare(
                exchange: "LojaExchange",
                type: ExchangeType.Direct,
                durable: true,
                autoDelete: false
            );

            var carrinho = new
            {
                UsuarioId = usuarioId,
                FormaPagamento = formaPgto,
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

            Console.WriteLine($"[x] Pedido enviado: {mensagemJson}");
        }
    }
}
