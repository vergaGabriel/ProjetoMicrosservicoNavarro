using SistemaProduto.Domain.DTO;

public class AtualizarEstoqueDTO
{
    public int PedidoId { get; set; }  
    public string UsuarioId { get; set; }
    public string FormaPgto { get; set; }
    public List<ItemPedidoDTO> Itens { get; set; }
}
