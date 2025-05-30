using SistemaPedidos.Models;

namespace SistemaPedidos.Infra.Interface
{
    public interface IPedidosRepository
    {
        bool AddPedidos(Pedidos pedidos);
        List<Pedidos> GetPedidosByUsuario(int idUsuario);
        Pedidos? GetPedidosById(int id);
        bool DeletePedidos(int id);
    }
}