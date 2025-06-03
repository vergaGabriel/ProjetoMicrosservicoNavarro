using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Threading;

class SubscriberCarrinhoFeito
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
        string queueName = "fila.carrinho.criado";
        string routingKey = "carrinho.criado";

        channel.ExchangeDeclare(
            exchange: exchangeName,
            type: ExchangeType.Direct,
            durable: true,
            autoDelete: false
        );
        channel.QueueDeclare(queue: queueName, durable: false, exclusive: false, autoDelete: false, arguments: null);

        channel.QueueBind(queue: queueName, exchange: exchangeName, routingKey: routingKey);

        Console.WriteLine("[*] Aguardando mensagens de pedido criado...");

        var consumer = new EventingBasicConsumer(channel);
        consumer.Received += async (model, ea) =>
        {
            var body = ea.Body.ToArray();
            var mensagem = Encoding.UTF8.GetString(body);

            try
            {
                using var httpClient = new HttpClient();
                var content = new StringContent(mensagem, Encoding.UTF8, "application/json");

                // Atualiza o estoque
                var estoqueResponse = await httpClient.PutAsync("http://api_produto:5000/api/Produto/estoque", content);
                if (!estoqueResponse.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[ERRO] Falha ao atualizar estoque. Status: {estoqueResponse.StatusCode}");
                }
                else
                {
                    Console.WriteLine("[✓] Estoque atualizado!");
                }

                // Cria o pedido
                var pedidoResponse = await httpClient.PostAsync("http://api_pedido:5000/api/pedidos", content);
                if (!pedidoResponse.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[ERRO] Falha ao criar pedido. Status: {pedidoResponse.StatusCode}");
                }
                else
                {
                    Console.WriteLine("[✓] Pedido criado com sucesso!");
                }
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
