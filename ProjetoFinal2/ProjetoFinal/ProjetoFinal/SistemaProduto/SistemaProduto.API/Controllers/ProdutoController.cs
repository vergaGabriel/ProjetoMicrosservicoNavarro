using Microsoft.AspNetCore.Mvc;
using SistemaProduto.Models;
using SistemaProduto.Infra.Interface;
using Microsoft.EntityFrameworkCore;
using SistemaProduto.Domain.DTO;
using System.Text.Json;
using System.Text;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using SistemaProduto.Infra;

namespace SistemaProduto.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProdutoController : ControllerBase
    {
        private readonly IProdutoRepository _produtoRepository;

        public ProdutoController(IProdutoRepository produtoRepository)
        {
            _produtoRepository = produtoRepository;
        }

        // POST: api/produto
        [HttpPost]
        public IActionResult AddProduto([FromBody] Produto produto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var success = _produtoRepository.AddProduto(produto);
            if (!success)
                return BadRequest("Erro ao cadastrar o produto.");

            return Ok(new { mensagem = "Produto cadastrado com sucesso!" });
        }


        // GET: api/produto
        [HttpGet]
        public IActionResult GetAll()
        {
            var produtos = _produtoRepository.GetAll();
            return Ok(produtos);
        }

        // GET: api/produto/{id}
        [HttpGet("{id}")]
        public IActionResult GetById(int id)
        {
            var produto = _produtoRepository.GetById(id);
            if (produto == null)
                return NotFound();

            return Ok(produto);
        }

        // PUT : api/Produto/estoque
        [HttpPut("estoque")]
        public IActionResult AtualizarEstoque([FromBody] AtualizarEstoqueDTO request)
        {
            foreach (var item in request.Itens)
            {
                bool sucesso = _produtoRepository.AtualizaEstoque(item.ProdutoId, item.Quantidade);
                if (!sucesso)
                    return BadRequest(new { mensagem = $"Erro ao atualizar o estoque do produto {item.ProdutoId}." });
            }

            Publisher.EnviarPedidoCriado(request.UsuarioId, request.FormaPgto, request.Itens);

            return Ok(new { mensagem = "Estoque atualizado e evento enviado com sucesso." });
        }

    }
}
