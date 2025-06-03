using Microsoft.AspNetCore.Mvc;
using SistemaProduto.Models;
using SistemaProduto.Infra.Interface;
using SistemaProduto.Domain.DTO;
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
                return BadRequest(new { mensagem = "Erro ao cadastrar o produto." });

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
                return NotFound(new { mensagem = "Produto não encontrado." });

            return Ok(produto);
        }

        // PUT: api/produto/{id}
        [HttpPut("{id}")]
        public IActionResult AtualizarProduto(int id, [FromBody] Produto produto)
        {
            if (id != produto.Id)
                return BadRequest(new { mensagem = "ID do produto não corresponde ao corpo da requisição." });

            var produtoExistente = _produtoRepository.GetById(id);
            if (produtoExistente == null)
                return NotFound(new { mensagem = "Produto não encontrado." });

            // Atualiza os campos permitidos
            produtoExistente.Nome = produto.Nome;
            produtoExistente.Descricao = produto.Descricao;
            produtoExistente.Preco_Unidade = produto.Preco_Unidade;
            produtoExistente.Estoque = produto.Estoque;
            produtoExistente.Imagem = string.IsNullOrWhiteSpace(produto.Imagem) ? null : produto.Imagem;
            produtoExistente.Variacoes = string.IsNullOrWhiteSpace(produto.Variacoes) ? null : produto.Variacoes;

            var sucesso = _produtoRepository.UpdateProduto(produtoExistente);
            if (!sucesso)
                return BadRequest(new { mensagem = "Erro ao atualizar o produto." });

            return Ok(new { mensagem = "Produto atualizado com sucesso!" });
        }

        // PUT: api/produto/estoque
        [HttpPut("estoque")]
        public IActionResult AtualizarEstoque([FromBody] AtualizarEstoqueDTO request)
        {
            foreach (var item in request.Itens)
            {
                bool sucesso = _produtoRepository.AtualizaEstoque(item.ProdutoId, item.Quantidade);
                if (!sucesso)
                    return BadRequest(new { mensagem = $"Erro ao atualizar o estoque do produto {item.ProdutoId}." });
            }

            // REMOVIDO: Publisher.EnviarPedidoCriado(...);

            return Ok(new { mensagem = "Estoque atualizado com sucesso (sem uso de fila)." });
        }


    }
}
