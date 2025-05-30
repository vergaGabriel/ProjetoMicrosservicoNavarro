namespace Domain
{
    public class Pedido
    {
        public int Id { get; set; }
        public string UsuarioId { get; set; } = null!;
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
        public string Status { get; set; } = "Pendente";
        public List<ItemPedido> Itens { get; set; } = new();
    }
}
