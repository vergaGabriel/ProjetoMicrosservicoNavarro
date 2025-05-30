using SistemaPedidos.Data;
using SistemaPedidos.Infra.Interface;
using SistemaPedidos.Models;

namespace SistemaPedidos.Repositories
{
    public class PedidosRepository : IPedidosRepository
    {
        private readonly SqlContext _context;

        public PedidosRepository(SqlContext context)
        {
            _context = context;
        }

        public bool AddPedidos(Pedidos pedidos)
        {
            _context.Pedidos.Add(pedidos);
            return _context.SaveChanges() > 0;
        }

        public List<Pedidos> GetPedidosByUsuario(int idUsuario)
        {
            return _context.Pedidos.Where(p => p.Id_User == idUsuario).ToList();
        }

        public Pedidos? GetPedidosById(int id)
        {
            return _context.Pedidos.FirstOrDefault(p => p.Id == id);
        }

        public bool DeletePedidos(int id)
        {
            var pedidos = _context.Pedidos.Find(id);
            if (pedidos == null || pedidos.Status.ToLower() != "pendente") return false;

            _context.Pedidos.Remove(pedidos);
            return _context.SaveChanges() > 0;
        }
    }
}