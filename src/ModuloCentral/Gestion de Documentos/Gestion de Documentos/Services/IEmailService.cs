using System.Threading.Tasks;

namespace Gestion_de_Documentos.Services
{
    public interface IEmailService
    {
        Task SendEmailAsync(string toEmail, string subject, string htmlMessage);
    }
}
