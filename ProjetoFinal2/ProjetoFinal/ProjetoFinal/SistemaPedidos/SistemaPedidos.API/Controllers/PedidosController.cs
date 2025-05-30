using Microsoft.AspNetCore.Mvc;
using SistemaPedidos.Infra.Interface;
using SistemaPedidos.Models;

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
        public IActionResult AddPedidos([FromBody] Pedidos pedido)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var result = _pedidoRepository.AddPedidos(pedido);
            if (!result) return BadRequest("Erro ao criar pedido.");

            return Ok(new { mensagem = "Pedido criado com sucesso!" });
        }

        [HttpGet("usuario/{idUsuario}")]
        public IActionResult GetPedidosByUsuario(int idUsuario)
        {
            var pedidos = _pedidoRepository.GetPedidosByUsuario(idUsuario);
            return Ok(pedidos);
        }

        [HttpGet("{id}")]
        public IActionResult GetPedidosById(int id)
        {
            var pedido = _pedidoRepository.GetPedidosById(id);
            if (pedido == null) return NotFound("Pedido não encontrado.");

            return Ok(pedido);
        }

        [HttpDelete("{id}")]
        public IActionResult DeletePedidos(int id)
        {
            var deleted = _pedidoRepository.DeletePedidos(id);
            if (!deleted) return BadRequest("Não é possível cancelar este pedido.");

            return Ok(new { mensagem = "Pedido cancelado com sucesso!" });
        }
    }
}