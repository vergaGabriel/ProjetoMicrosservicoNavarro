using Domain;
using Infra.Interface;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmailController : ControllerBase
    {
        private readonly IEmailService _emailService;

        public EmailController(IEmailService emailService)
        {
            _emailService = emailService;
        }

        /// <summary>
        /// Envia um email simples.
        /// </summary>
        [HttpPost("enviar")]
        public IActionResult SendEmail([FromBody] NotificaEmail emailRequest)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = _emailService.SendEmail(emailRequest.ToEmail, emailRequest.Subject, emailRequest.Body);
            if (!result)
                return BadRequest("Erro ao enviar o email.");

            return Ok(new { mensagem = "Email enviado com sucesso!" });
        }
    }
}
