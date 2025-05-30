using Domain;
using StackExchange.Redis;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;

public class RedisCarrinhoService
{
    private readonly IDatabase _db;

    public RedisCarrinhoService(string redisConnectionString)
    {
        var redis = ConnectionMultiplexer.Connect(redisConnectionString);
        _db = redis.GetDatabase();
    }

    private string GetCarrinhoKey(string usuarioId) => $"carrinho:{usuarioId}";

    public async Task AdicionarItemAsync(string usuarioId, ItemCarrinho item)
    {
        var itens = await ObterItensAsync(usuarioId) ?? new List<ItemCarrinho>();

        var itemExistente = itens.Find(i => i.ProdutoId == item.ProdutoId);
        if (itemExistente != null)
        {
            itemExistente.Quantidade += item.Quantidade;
        }
        else
        {
            itens.Add(item);
        }

        var json = JsonSerializer.Serialize(itens);
        await _db.StringSetAsync(GetCarrinhoKey(usuarioId), json);
    }

    public async Task<List<ItemCarrinho>> ObterItensAsync(string usuarioId)
    {
        var json = await _db.StringGetAsync(GetCarrinhoKey(usuarioId));
        if (json.IsNullOrEmpty) return new List<ItemCarrinho>();

        return JsonSerializer.Deserialize<List<ItemCarrinho>>(json);
    }

    public async Task LimparCarrinhoAsync(string usuarioId)
    {
        await _db.KeyDeleteAsync(GetCarrinhoKey(usuarioId));
    }
}
