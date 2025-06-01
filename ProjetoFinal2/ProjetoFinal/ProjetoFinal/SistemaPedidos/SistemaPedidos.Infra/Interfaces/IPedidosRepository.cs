using SistemaPedidos.Domain;

namespace SistemaPedidos.Infra.Interface
{
    public interface IPedidosRepository
    {
        bool AddPedido(Pedido pedido);
        List<Pedido> GetPedidosByUsuario(string idUsuario);
        Pedido? GetPedidoById(int id);
        bool DeletePedido(int id);
    }
}
