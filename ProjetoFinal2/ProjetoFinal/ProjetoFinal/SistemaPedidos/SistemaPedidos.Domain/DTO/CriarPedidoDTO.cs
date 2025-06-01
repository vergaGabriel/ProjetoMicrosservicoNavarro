using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SistemaPedidos.Domain.DTO
{
    public class CriarPedidoDTO
    {
        public string UsuarioId { get; set; } = null!;
        public string FormaPagamento { get; set; } = null!;
        public List<ItemPedidoDTO> Itens { get; set; } = new();
    }
}
