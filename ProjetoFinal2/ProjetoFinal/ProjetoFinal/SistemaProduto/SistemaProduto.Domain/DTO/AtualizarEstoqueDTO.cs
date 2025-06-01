using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SistemaProduto.Domain.DTO
{
    public class AtualizarEstoqueDTO
    {
        public Guid PedidoId { get; set; }
        public string UsuarioId { get; set; }
        public string FormaPgto { get; set; }
        public List<ItemPedidoDTO> Itens { get; set; }
    }
}
