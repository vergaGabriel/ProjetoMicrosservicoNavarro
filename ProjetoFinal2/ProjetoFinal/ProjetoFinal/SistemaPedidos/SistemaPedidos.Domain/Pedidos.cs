using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SistemaPedidos.Domain
{
    public class Pedido
    {
        public int Id { get; set; }
        public string UsuarioId { get; set; } = null!;
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
        public string Status { get; set; } = "Pendente";
        public string FormaPagamento {  get; set; }
        public List<ItemPedido> Itens { get; set; } = new();
    }
}