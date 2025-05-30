using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaEnderecos.Models
{
    [Table("enderecos")]
    public class EnderecoEntrega
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [Column("id_usuario")]
        public int IdUsuario { get; set; }

        [Required]
        public string Apelido { get; set; }

        [Required]
        public string Destinatario { get; set; }

        [Required]
        public string Telefone { get; set; }

        [Required]
        public string Rua { get; set; }

        [Required]
        public string Numero { get; set; }

        public string? Complemento { get; set; }

        [Required]
        public string Cidade { get; set; }

        [Required]
        public string Estado { get; set; }

        [Required]
        public string Cep { get; set; }
    }
}