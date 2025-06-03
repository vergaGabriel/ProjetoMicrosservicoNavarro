using Microsoft.AspNetCore.Mvc;
using SistemaUser.Domain;
using SistemaUser.Infra.Interface;
using SistemaUser.Infra.Messaging;
using SistemaUser.Models;

namespace Projetao.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserRepository _userRepository;

        public UserController(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        /// Cria um novo usuário.
 
        [HttpPost]
        public IActionResult AddUser([FromBody] User user)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = _userRepository.AddUser(user);
            if (!result)
            {
                PublisherCadastro.Publisher("Erro ao realizar cadastro", "nok");
                return BadRequest("Erro ao adicionar usuário.");
            }

            PublisherCadastro.Publisher(user.Email, "Cadastro realizado com sucesso!");


            return Ok(new { mensagem = "Usuário criado com sucesso!" });
        }

       
        /// Realiza login com email ou CPF e senha.
       
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginDTO login)
        {
            var user = _userRepository.Login(login.EmailOrCpf, login.Senha);
            if (user == null)
                return Unauthorized("Credenciais inválidas.");

            return Ok(user);
        }


        /// Retorna os dados de um usuário específico.

        [HttpGet("{id}")]
        public IActionResult GetUserById(int id)
        {
            var user = _userRepository.GetUserById(id);
            if (user == null)
                return NotFound("Usuário não encontrado.");

            return Ok(user);
        }

      
        /// Atualiza os dados de um usuário existente.
   
        [HttpPut("{id}")]
        public IActionResult UpdateUser(int id, [FromBody] User user)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = _userRepository.UpdateUser(id, user);
            if (!updated)
                return NotFound("Usuário não encontrado para atualização.");

            return Ok(new { mensagem = "Usuário atualizado com sucesso!" });
        }

   
        /// Exclui um usuário do sistema.
     
        [HttpDelete("{id}")]
        public IActionResult DeleteUser(int id)
        {
            var deleted = _userRepository.DeleteUser(id);
            if (!deleted)
                return NotFound("Usuário não encontrado para exclusão.");

            return Ok(new { mensagem = "Usuário excluído com sucesso!" });
        }
    }
}
