using SistemaPedidos.Data;
using SistemaPedidos.Domain;
using SistemaPedidos.Infra.Interface;
using Microsoft.EntityFrameworkCore;

namespace SistemaPedidos.Repositories
{
    public class PedidosRepository : IPedidosRepository
    {
        private readonly SqlContext _context;

        public PedidosRepository(SqlContext context)
        {
            _context = context;
        }

        public bool AddPedido(Pedido pedido)
        {
            // Adiciona o pedido e seus itens (caso existam)
            _context.Pedidos.Add(pedido);
            return _context.SaveChanges() > 0;
        }

        public List<Pedido> GetPedidosByUsuario(string idUsuario)
        {
            // Inclui os itens do pedido
            return _context.Pedidos
                .Include(p => p.Itens)
                .Where(p => p.UsuarioId == idUsuario)
                .ToList();
        }

        public Pedido? GetPedidoById(int id)
        {
            // Inclui os itens do pedido
            return _context.Pedidos
                .Include(p => p.Itens)
                .FirstOrDefault(p => p.Id == id);
        }

        public bool DeletePedido(int id)
        {
            var pedido = _context.Pedidos
                .Include(p => p.Itens)
                .FirstOrDefault(p => p.Id == id);

            if (pedido == null || pedido.Status.ToLower() != "pendente")
                return false;

            _context.Pedidos.Remove(pedido);
            return _context.SaveChanges() > 0;
        }
    }
}
