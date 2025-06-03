namespace SistemaPedidos.Domain.DTO
{
    public class CriarPedidoDTO
    {
        public int UsuarioId { get; set; }
        public string FormaPagamento { get; set; } = "";
        public List<ItemPedidoDTO> Itens { get; set; } = new();
    }
}
