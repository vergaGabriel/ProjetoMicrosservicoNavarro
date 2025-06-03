using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaProduto.Models
{
    public class Produto
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "O nome é obrigatório.")]
        public string Nome { get; set; }

        [Required(ErrorMessage = "A descrição é obrigatória.")]
        public string Descricao { get; set; }

        [Required(ErrorMessage = "O preço é obrigatório.")]
        [Column(TypeName = "decimal(18,2)")]
        public decimal Preco_Unidade { get; set; }

        [Required(ErrorMessage = "O estoque é obrigatório.")]
        public int Estoque { get; set; }

        public string? Variacoes { get; set; }

        public string? Imagem { get; set; }

        public int Criado_Por_Id { get; set; }

        public DateTime Data_Criacao { get; set; } = DateTime.Now;

        public bool PodeDiminuirEstoque(int quantidade)
        {
            return quantidade > 0 && Estoque >= quantidade;
        }

        public void DiminuirEstoque(int quantidade)
        {
            if (!PodeDiminuirEstoque(quantidade))
                throw new InvalidOperationException("Estoque insuficiente");

            Estoque -= quantidade;
        }
    }
}
