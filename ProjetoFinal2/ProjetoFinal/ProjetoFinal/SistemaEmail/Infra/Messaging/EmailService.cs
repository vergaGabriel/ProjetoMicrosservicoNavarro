using System.Net;
using System.Net.Mail;
using Infra.Interface;

namespace Infra
{
    public class EmailService : IEmailService
    {
        private readonly string _smtpServer = "smtp.gmail.com";
        private readonly int _smtpPort = 587;
        private readonly string _smtpUser = "gabvergasiq@gmail.com";
        private readonly string _smtpPass = "cgpu spii ivrf fxnc";

        public bool SendEmail(string to, string subject, string body)
        {
            try
            {
                var client = new SmtpClient(_smtpServer, _smtpPort)
                {
                    Credentials = new NetworkCredential(_smtpUser, _smtpPass),
                    EnableSsl = true
                };

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(_smtpUser),
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = true
                };

                mailMessage.To.Add(to);

                client.Send(mailMessage);
                return true;
            }
            catch (Exception ex)
            {
                // Aqui você pode logar o erro.
                Console.WriteLine($"Erro ao enviar email: {ex.Message}");
                return false;
            }
        }
    }
}
