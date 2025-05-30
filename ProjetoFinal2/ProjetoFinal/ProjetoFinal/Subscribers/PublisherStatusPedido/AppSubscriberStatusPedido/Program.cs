using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Text;
using System.Text.Json;

class Program
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
        string queueName = "fila.statusPedido";
        string routingKey = "pedido.statusAtualizado";

        channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Direct);
        channel.QueueDeclare(queue: queueName, durable: false, exclusive: false, autoDelete: false, arguments: null);
        channel.QueueBind(queue: queueName, exchange: exchangeName, routingKey: routingKey);

        Console.WriteLine("[*] Aguardando atualizações de status de pedido. Pressione CTRL+C para sair.");

        var consumer = new EventingBasicConsumer(channel);
        consumer.Received += (model, ea) =>
        {
            var body = ea.Body.ToArray();
            var mensagem = Encoding.UTF8.GetString(body);

            try
            {
                var dados = JsonSerializer.Deserialize<JsonElement>(mensagem);

                Console.WriteLine("\n[✓] Status de pedido recebido:");
                Console.WriteLine($"→ ID Pedido:        {dados.GetProperty("IdPedido").GetInt32()}");
                Console.WriteLine($"→ Novo Status:      {dados.GetProperty("NovoStatus").GetString()}");
                Console.WriteLine($"→ Data Atualização: {dados.GetProperty("DataAtualizacao").GetDateTime()}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"\n[ERRO] Falha ao processar a mensagem:\n{mensagem}");
                Console.WriteLine($"Erro: {ex.Message}");
            }
        };

        channel.BasicConsume(queue: queueName, autoAck: true, consumer: consumer);
        Console.ReadLine();
    }
}
