using SistemaPedidos.Domain;
using System.Collections.Generic;

namespace SistemaPedidos.Infra.Interfaces
{
    public interface IPedidosRepository
    {
        bool AddPedido(Pedido pedido);
        bool UpdatePedido(Pedido pedido);
        bool DeletePedido(int id);
        Pedido? GetPedidoDetalhadoById(int id);
        List<Pedido> GetAllPedidos();
        List<Pedido> GetPedidosByUsuario(int usuarioId);
        Pedido? ObterPedidoAbertoPorUsuario(int usuarioId);
        Pedido? ObterPedidoPendentePorUsuario(int usuarioId); // ← novo método
    }
}
