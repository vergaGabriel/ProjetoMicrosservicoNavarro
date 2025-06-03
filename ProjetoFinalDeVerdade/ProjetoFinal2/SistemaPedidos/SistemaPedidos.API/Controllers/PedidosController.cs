using Microsoft.AspNetCore.Mvc;
using SistemaPedidos.Domain;
using SistemaPedidos.Domain.DTO;
using SistemaPedidos.Infra.Interfaces;
using SistemaPedidos.Infra.Messaging;
using System.Text.Json;
using System.Text;

namespace SistemaPedidos.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PedidosController : ControllerBase
    {
        private readonly IPedidosRepository _pedidoRepository;

        public PedidosController(IPedidosRepository pedidoRepository)
        {
            _pedidoRepository = pedidoRepository;
        }

        [HttpPost("iniciar")]
        public IActionResult IniciarOuAtualizarPedidoCart([FromBody] CriarPedidoDTO pedidoDTO)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var pedidoExistente = _pedidoRepository.ObterPedidoAbertoPorUsuario(pedidoDTO.UsuarioId);

            if (pedidoExistente != null)
            {
                pedidoExistente.Itens = pedidoDTO.Itens.Select(i => new ItemPedido
                {
                    ProdutoId = i.ProdutoId,
                    Quantidade = i.Quantidade,
                    PrecoUnitario = i.PrecoUnitario
                }).ToList();

                pedidoExistente.ValorTotal = pedidoExistente.Itens.Sum(i => i.Quantidade * i.PrecoUnitario);

                if (!_pedidoRepository.UpdatePedido(pedidoExistente))
                    return BadRequest("Erro ao atualizar o pedido aberto.");
            }
            else
            {
                var pedido = new Pedido
                {
                    UsuarioId = pedidoDTO.UsuarioId,
                    FormaPagamento = "",
                    Status = "cart",
                    DataCriacao = DateTime.UtcNow,
                    Itens = pedidoDTO.Itens.Select(i => new ItemPedido
                    {
                        ProdutoId = i.ProdutoId,
                        Quantidade = i.Quantidade,
                        PrecoUnitario = i.PrecoUnitario
                    }).ToList()
                };

                pedido.ValorTotal = pedido.Itens.Sum(i => i.Quantidade * i.PrecoUnitario);
                if (!_pedidoRepository.AddPedido(pedido))
                    return BadRequest("Erro ao criar pedido com status cart.");
            }

            return Ok(new { mensagem = "Pedido salvo como carrinho." });
        }

        [HttpPost("/api/{usuarioId}/carrinho/finalizar")]
        public IActionResult FinalizarCarrinho(int usuarioId)
        {
            var pedido = _pedidoRepository.ObterPedidoAbertoPorUsuario(usuarioId);
            if (pedido == null || pedido.Status.ToLower() != "cart")
                return NotFound("Carrinho não encontrado.");

            pedido.Status = "Pendente";
            if (!_pedidoRepository.UpdatePedido(pedido))
                return StatusCode(500, "Erro ao atualizar status do pedido.");

            Publisher.EnviarStatusPedido(pedido.UsuarioId, "Pendente");

            return Ok(new { mensagem = "Pedido finalizado com sucesso!", pedidoId = pedido.Id });
        }

        [HttpPut("checkout/{pedidoId}")]
        public async Task<IActionResult> ConcluirCheckout(int pedidoId, [FromBody] Dictionary<string, string> body)

        {
            if (!body.TryGetValue("formaPgto", out var formaPgto) || string.IsNullOrWhiteSpace(formaPgto))
                return BadRequest("Forma de pagamento ausente ou inválida.");

            var pedido = _pedidoRepository.GetPedidoDetalhadoById(pedidoId);
            if (pedido == null)
                return NotFound("Pedido não encontrado.");

            if (pedido.Status.ToLower() != "pendente" && pedido.Status.ToLower() != "cart")
                return BadRequest("Pedido já finalizado ou em estado inválido.");

            pedido.Status = "Finalizado";
            pedido.FormaPagamento = formaPgto;

            if (!_pedidoRepository.UpdatePedido(pedido))
                return StatusCode(500, "Erro ao finalizar pedido.");

            var estoqueDTO = new
            {
                pedidoId = pedido.Id,
                usuarioId = pedido.UsuarioId.ToString(),
                formaPgto = formaPgto,
                itens = pedido.Itens.Select(i => new
                {
                    produtoId = i.ProdutoId,
                    quantidade = i.Quantidade
                }).ToList()
            };

            using var client = new HttpClient();
            var jsonEstoque = JsonSerializer.Serialize(estoqueDTO);
            var content = new StringContent(jsonEstoque, Encoding.UTF8, "application/json");

            var response = await client.PutAsync("http://sistemaproduto_api:5000/api/produto/estoque", content);
            if (!response.IsSuccessStatusCode)
                return StatusCode(500, "Pedido finalizado, mas houve erro ao atualizar o estoque.");

            return Ok(new { mensagem = "Checkout finalizado com sucesso!" });
        }

        [HttpPost("checkout/{usuarioId}")]
        public async Task<IActionResult> CheckoutPedidoUsuario(int usuarioId, [FromBody] Dictionary<string, string> body)
        {
            if (!body.TryGetValue("formaPgto", out var formaPgto) || string.IsNullOrWhiteSpace(formaPgto))
                return BadRequest("Forma de pagamento ausente ou inválida.");

            var pedido = _pedidoRepository.ObterPedidoPendentePorUsuario(usuarioId);
            if (pedido == null)
                return NotFound("Pedido pendente não encontrado.");

            pedido.Status = "Finalizado";
            pedido.FormaPagamento = formaPgto;

            if (!_pedidoRepository.UpdatePedido(pedido))
                return StatusCode(500, "Erro ao finalizar pedido.");

            var estoqueDTO = new
            {
                pedidoId = pedido.Id,
                usuarioId = pedido.UsuarioId.ToString(),
                formaPgto = formaPgto,
                itens = pedido.Itens.Select(i => new
                {
                    produtoId = i.ProdutoId,
                    quantidade = i.Quantidade
                }).ToList()
            };

            using var client = new HttpClient();
            var jsonEstoque = JsonSerializer.Serialize(estoqueDTO);
            var content = new StringContent(jsonEstoque, Encoding.UTF8, "application/json");

            var response = await client.PutAsync("http://sistemaproduto_api:5000/api/produto/estoque", content);
            if (!response.IsSuccessStatusCode)
                return StatusCode(500, "Pedido finalizado, mas houve erro ao atualizar o estoque.");

            return Ok(new { mensagem = "Checkout finalizado com sucesso!", pedidoId = pedido.Id });
        }

        [HttpGet]
        public IActionResult GetAllPedidos()
        {
            var pedidos = _pedidoRepository.GetAllPedidos();

            var resumo = pedidos.Select(p => new PedidoResumoDto
            {
                Id = p.Id,
                UsuarioId = p.UsuarioId,
                Status = p.Status,
                FormaPagamento = p.FormaPagamento,
                ValorTotal = p.ValorTotal
            }).ToList();

            return Ok(resumo);
        }

        [HttpGet("{id}")]
        public IActionResult GetPedidoById(int id)
        {
            var pedido = _pedidoRepository.GetPedidoDetalhadoById(id);
            if (pedido == null)
                return NotFound("Pedido não encontrado.");

            foreach (var item in pedido.Itens)
                item.Pedido = null;

            return Ok(pedido);
        }

        [HttpGet("usuario/{idUsuario}")]
        public IActionResult GetPedidosByUsuario(int idUsuario)
        {
            var pedidos = _pedidoRepository.GetPedidosByUsuario(idUsuario);

            var resumo = pedidos.Select(p => new PedidoResumoDto
            {
                Id = p.Id,
                UsuarioId = p.UsuarioId,
                Status = p.Status,
                FormaPagamento = p.FormaPagamento,
                ValorTotal = p.ValorTotal
            }).ToList();

            return Ok(resumo);
        }

        [HttpDelete("{id}")]
        public IActionResult DeletePedido(int id)
        {
            if (!_pedidoRepository.DeletePedido(id))
                return BadRequest("Não é possível cancelar este pedido.");

            return Ok(new { mensagem = "Pedido cancelado com sucesso!" });
        }
    }
}
