using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaUser.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Nome { get; set; }

        [Required]
        [DataType(DataType.Date)]
        public DateTime DataNascimento { get; set; }

        [Required]
        [RegularExpression(@"^\d{11}$", ErrorMessage = "CPF deve ter 11 dígitos")]
        public string CPF { get; set; }

        [Required]
        [EmailAddress]
        public string Email { get; set; }

        [Required]
        [MinLength(6)]
        public string Senha { get; set; }

        [Required]
        [CargoValido]
        public string Cargo { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public DateTime DataCriacao { get; set; } = DateTime.Now;
    }

    public class CargoValidoAttribute : ValidationAttribute
    {
        private readonly string[] _validos = new[] { "boss", "staff", "client" };
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            if (value == null || !_validos.Contains(value.ToString().ToLower()))
                return new ValidationResult("Cargo deve ser boss, staff ou client");
            return ValidationResult.Success;
        }
    }
}
