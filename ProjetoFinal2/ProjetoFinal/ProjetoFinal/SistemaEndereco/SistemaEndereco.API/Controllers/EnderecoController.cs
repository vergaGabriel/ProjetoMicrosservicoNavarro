using Microsoft.AspNetCore.Mvc;
using SistemaEnderecos.Infra.Interface;
using SistemaEnderecos.Models;

namespace SistemaEnderecos.Controllers
{
    [ApiController]
    [Route("api/enderecos")]
    public class EnderecosController : ControllerBase
    {
        private readonly IEnderecoRepository _repository;

        public EnderecosController(IEnderecoRepository repository)
        {
            _repository = repository;
        }

        [HttpPost]
        public IActionResult Post([FromBody] EnderecoEntrega endereco)
        {
            if (!_repository.AddEnderecos(endereco)) return BadRequest("Erro ao adicionar endere�o");
            return Ok("Endere�o adicionado com sucesso");
        }

        [HttpGet("usuario/{idUsuario}")]
        public IActionResult GetByUsuario(int idUsuario)
        {
            var lista = _repository.GetEnderecosByUsuario(idUsuario);
            if (lista == null || !lista.Any()) return NotFound("Nenhum endere�o encontrado");
            return Ok(lista);
        }

        [HttpGet("{id}")]
        public IActionResult GetById(int id)
        {
            var endereco = _repository.GetEnderecosById(id);
            if (endereco == null) return NotFound("Endere�o n�o encontrado");
            return Ok(endereco);
        }

        [HttpPut("{id}")]
        public IActionResult Put(int id, [FromBody] EnderecoEntrega endereco)
        {
            if (!_repository.UpdateEnderecos(id, endereco)) return BadRequest("Erro ao atualizar endere�o");
            return Ok("Endere�o atualizado com sucesso");
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            if (!_repository.DeleteEnderecos(id)) return BadRequest("Erro ao remover endere�o");
            return Ok("Endere�o removido com sucesso");
        }
    }
}
