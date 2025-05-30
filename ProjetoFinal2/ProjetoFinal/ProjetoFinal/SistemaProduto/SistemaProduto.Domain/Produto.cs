using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;

namespace SistemaProduto.Models
{
    public class Produto
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Nome { get; set; }

        [Required]
        public string Descricao { get; set; }

        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal Preco_Unidade { get; set; }

        [Required]
        public int Estoque { get; set; }

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