using Microsoft.AspNetCore.Mvc;
using Domain;
using Infra;
using Infra.Messaging;
using System.Text.Json;
namespace CarrinhoAPI.Controllers
{
    [ApiController]
    [Route("api")]
    public class CarrinhoController : ControllerBase
    {
        private readonly RedisCarrinhoService _carrinhoService;

        public CarrinhoController(RedisCarrinhoService carrinhoService)
        {
            _carrinhoService = carrinhoService;
        }

        [HttpPost("{usuarioId}/carrinho/adicionar")]
        public async Task<IActionResult> AdicionarItem(string usuarioId, [FromBody] ItemCarrinho item)
        {
            await _carrinhoService.AdicionarItemAsync(usuarioId, item);
            return Ok(new { mensagem = "Item adicionado ao carrinho." });
        }

        [HttpGet("{usuarioId}/carrinho")]
        public async Task<IActionResult> ObterCarrinho(string usuarioId)
        {
            var itens = await _carrinhoService.ObterItensAsync(usuarioId);
            return Ok(itens);
        }

        [HttpDelete("{usuarioId}/carrinho/limpar")]
        public async Task<IActionResult> LimparCarrinho(string usuarioId)
        {
            await _carrinhoService.LimparCarrinhoAsync(usuarioId);
            return Ok(new { mensagem = "Carrinho limpo." });
        }

        [HttpPost("{usuarioId}/carrinho/finalizar")]
        public async Task<IActionResult> FinalizarPedido(string usuarioId, [FromBody] JsonElement json)
        {
            string formaPgto = json.TryGetProperty("formaPgto", out var pgto) && pgto.ValueKind == JsonValueKind.String
                ? pgto.GetString()
                : string.Empty;

            var itens = await _carrinhoService.ObterItensAsync(usuarioId);
            if (itens == null || itens.Count == 0)
                return BadRequest(new { mensagem = "Carrinho vazio." });

            Publisher.EnviarPedidoCriado(usuarioId, formaPgto, itens);
            await _carrinhoService.LimparCarrinhoAsync(usuarioId);
            return Ok(new { mensagem = "Pedido finalizado e enviado para processamento." });
        }
    }
}
