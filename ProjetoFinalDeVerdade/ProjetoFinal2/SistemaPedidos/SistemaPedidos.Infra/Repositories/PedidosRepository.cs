using Microsoft.EntityFrameworkCore;
using SistemaPedidos.Data;
using SistemaPedidos.Domain;
using SistemaPedidos.Infra.Interfaces;

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
            _context.Add(pedido);
            return _context.SaveChanges() > 0;
        }

        public bool UpdatePedido(Pedido pedido)
        {
            _context.Update(pedido);
            return _context.SaveChanges() > 0;
        }

        public Pedido? GetPedidoDetalhadoById(int id)
        {
            return _context.Set<Pedido>()
                .Include(p => p.Itens)
                .FirstOrDefault(p => p.Id == id);
        }

        public List<Pedido> GetAllPedidos()
        {
            return _context.Set<Pedido>().Include(p => p.Itens).ToList();
        }

        public List<Pedido> GetPedidosByUsuario(int usuarioId)
        {
            return _context.Set<Pedido>()
                .Include(p => p.Itens)
                .Where(p => p.UsuarioId == usuarioId)
                .ToList();
        }

        public Pedido? ObterPedidoAbertoPorUsuario(int usuarioId)
        {
            return _context.Set<Pedido>()
                .Include(p => p.Itens)
                .FirstOrDefault(p => p.UsuarioId == usuarioId && p.Status == "Cart");
        }

        public Pedido? ObterPedidoPendentePorUsuario(int usuarioId)
        {
            return _context.Set<Pedido>()
                .Include(p => p.Itens)
                .FirstOrDefault(p => p.UsuarioId == usuarioId && p.Status == "Pendente");
        }

        public bool DeletePedido(int id)
        {
            var pedido = _context.Set<Pedido>().Find(id);
            if (pedido == null) return false;

            _context.Remove(pedido);
            return _context.SaveChanges() > 0;
        }
    }
}
