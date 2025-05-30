using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Net.Http;
using System.Runtime.ConstrainedExecution;
using System.Text;
using System.Text.Json;
using System.Threading;

class EstoqueSubscriber
{
    static void Main(string[] args)
    {
        var factory = new ConnectionFactory()
        {
            Uri = new Uri("amqps://afzjlqla:y3cJwytvxhdvHyACG-MDgdEuCcGyUl2i@jaragua.lmq.cloudamqp.com/afzjlqla")
        };

        using var connection = factory.CreateConnection();
        using var channel = connection.CreateModel();

        string exchangeName = "LojaExchange";
        string queueName = "fila.produto.estoque.atualizar";
        string routingKey = "produto.estoque.atualizar";

        channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Direct);
        channel.QueueDeclare(queue: queueName, durable: false, exclusive: false, autoDelete: false, arguments: null);
        channel.QueueBind(queue: queueName, exchange: exchangeName, routingKey: routingKey);


        Console.WriteLine("[*] Aguardando mensagens para atualizar estoque...");

        var consumer = new EventingBasicConsumer(channel);
        consumer.Received += async (model, ea) =>
        {
            var body = ea.Body.ToArray();
            var mensagem = Encoding.UTF8.GetString(body);

            try
            {
                var dados = JsonSerializer.Deserialize<JsonElement>(mensagem);

                int produtoId = dados.GetProperty("ProdutoId").GetInt32();
                int estoque = dados.GetProperty("Estoque").GetInt32();

                Console.WriteLine($"\n[✓] Atualizando estoque do produto ID {produtoId}");

                


            }
            catch (Exception ex)
            {
                Console.WriteLine($"\n[ERRO] Falha ao processar a mensagem:\n{mensagem}");
                Console.WriteLine($"Erro: {ex.Message}");
            }
        };

        channel.BasicConsume(queue: queueName, autoAck: true, consumer: consumer);

        // Manter o app rodando
        while (true)
        {
            Thread.Sleep(1000);
        }
    }
}


