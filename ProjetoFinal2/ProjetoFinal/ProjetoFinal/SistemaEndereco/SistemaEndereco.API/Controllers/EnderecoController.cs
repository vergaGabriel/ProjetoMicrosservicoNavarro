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
            if (!_repository.AddEnderecos(endereco)) return BadRequest("Erro ao adicionar endereço");
            return Ok("Endereço adicionado com sucesso");
        }

        [HttpGet("usuario/{idUsuario}")]
        public IActionResult GetByUsuario(int idUsuario)
        {
            var lista = _repository.GetEnderecosByUsuario(idUsuario);
            if (lista == null || !lista.Any()) return NotFound("Nenhum endereço encontrado");
            return Ok(lista);
        }

        [HttpGet("{id}")]
        public IActionResult GetById(int id)
        {
            var endereco = _repository.GetEnderecosById(id);
            if (endereco == null) return NotFound("Endereço não encontrado");
            return Ok(endereco);
        }

        [HttpPut("{id}")]
        public IActionResult Put(int id, [FromBody] EnderecoEntrega endereco)
        {
            if (!_repository.UpdateEnderecos(id, endereco)) return BadRequest("Erro ao atualizar endereço");
            return Ok("Endereço atualizado com sucesso");
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            if (!_repository.DeleteEnderecos(id)) return BadRequest("Erro ao remover endereço");
            return Ok("Endereço removido com sucesso");
        }
    }
}
