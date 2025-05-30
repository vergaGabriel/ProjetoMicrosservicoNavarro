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
        public static void Publisher(string message, string type)
        {
            var factory = new ConnectionFactory()
            {
                Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
            };

            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            string exchangeName = "LojaExchange";
            channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Direct);

            var retorno = new
            {
                Type = type,
                Message = message
            };

            string mensagemJson = JsonSerializer.Serialize(retorno);
            var body = Encoding.UTF8.GetBytes(mensagemJson);

            string routingKey = "cadastroReturn.createReturn";

            channel.BasicPublish(
                exchange: exchangeName,
                routingKey: routingKey,
                basicProperties: null,
                body: body
            );

            Console.WriteLine("Cadastro realizado com sucesso!");
            
        }

    }
}
