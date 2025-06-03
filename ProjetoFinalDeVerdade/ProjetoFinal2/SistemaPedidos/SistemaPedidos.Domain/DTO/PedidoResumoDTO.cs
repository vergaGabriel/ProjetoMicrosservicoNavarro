
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SistemaPedidos.Domain.DTO
{
    public class PedidoResumoDto
    {
        public int Id { get; set; }
        public int UsuarioId { get; set; }
        public string Status { get; set; }
        public string FormaPagamento { get; set; }
        public Decimal ValorTotal { get; set; }
    }

}