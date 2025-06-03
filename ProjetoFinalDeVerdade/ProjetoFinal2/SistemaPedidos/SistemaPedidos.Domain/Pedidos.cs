using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SistemaPedidos.Domain
{
    public class Pedido
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int UsuarioId { get; set; }

        public string? FormaPagamento { get; set; }

        public string Status { get; set; } = "Cart";

        public decimal ValorTotal { get; set; }

        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;

        public ICollection<ItemPedido> Itens { get; set; } = new List<ItemPedido>();
    }
}