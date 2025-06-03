using Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain
{
    public class Pedido
    {
        public int PedidoId { get; set; }
        public List<ItemCarrinho> Itens { get; set; } = new();
    }
}
