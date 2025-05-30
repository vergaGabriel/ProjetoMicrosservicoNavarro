using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaPedidos.Models
{
    public class Pedidos
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int Id_User { get; set; }

        [Required]
        public int Id_Endereco { get; set; }

        [Required]
        public string Status { get; set; }

        [Required]
        public decimal Valor_Total { get; set; }

        public string? Observacoes { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public DateTime Data_Criacao { get; set; } = DateTime.Now;
    }
}