using Microsoft.AspNetCore.Mvc;
using SistemaPedidos.Domain;
using SistemaPedidos.Domain.DTO;
using SistemaPedidos.Infra.Interface;
using SistemaPedidos.Infra.Messaging;

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

        [HttpPost]
        public IActionResult AddPedido([FromBody] CriarPedidoDTO pedidoDTO)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var status = "Finalizado";

            if (pedidoDTO.FormaPagamento == "") status = "Pendente";

            var pedido = new Pedido
            {
                UsuarioId = pedidoDTO.UsuarioId,
                FormaPagamento = pedidoDTO.FormaPagamento,
                Status = status,
                DataCriacao = DateTime.UtcNow,
                Itens = pedidoDTO.Itens.Select(i => new ItemPedido
                {
                    ProdutoId = i.ProdutoId,
                    Quantidade = i.Quantidade
                }).ToList()
            };

            var result = _pedidoRepository.AddPedido(pedido);
            if (!result) return BadRequest("Erro ao criar pedido.");

            Publisher.EnviarStatusPedido(pedidoDTO.UsuarioId, status);

            return Ok(new { mensagem = "Pedido criado com sucesso!" });
        }

        [HttpGet("usuario/{idUsuario}")]
        public IActionResult GetPedidosByUsuario(string idUsuario)
        {
            var pedidos = _pedidoRepository.GetPedidosByUsuario(idUsuario);
            return Ok(pedidos);
        }

        [HttpGet("{id}")]
        public IActionResult GetPedidoById(int id)
        {
            var pedido = _pedidoRepository.GetPedidoById(id);
            if (pedido == null)
                return NotFound("Pedido não encontrado.");

            return Ok(pedido);
        }

        [HttpDelete("{id}")]
        public IActionResult DeletePedido(int id)
        {
            var deleted = _pedidoRepository.DeletePedido(id);
            if (!deleted)
                return BadRequest("Não é possível cancelar este pedido.");

            return Ok(new { mensagem = "Pedido cancelado com sucesso!" });
        }
    }
}
