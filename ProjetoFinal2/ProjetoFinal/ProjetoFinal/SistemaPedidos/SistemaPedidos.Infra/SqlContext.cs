using Microsoft.EntityFrameworkCore;
using SistemaPedidos.Domain;
using System.Collections.Generic;

namespace SistemaPedidos.Data
{
    public class SqlContext : DbContext
    {
        public SqlContext(DbContextOptions<SqlContext> options) : base(options) { }

        public DbSet<Pedido> Pedidos { get; set; }
        public DbSet<ItemPedido> TensPedidos { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Pedido>(entity =>
            {
                entity.HasKey(p => p.Id);
                entity.Property(p => p.UsuarioId).IsRequired();

                entity.HasMany(p => p.Itens)
                      .WithOne(i => i.Pedido)
                      .HasForeignKey(i => i.PedidoId);
            });

            modelBuilder.Entity<ItemPedido>(entity =>
            {
                entity.HasKey(i => i.Id);
                entity.Property(i => i.ProdutoId).IsRequired();
                entity.Property(i => i.Quantidade).IsRequired();
            });
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("Server=projetofinal-db.cl4484q408hn.us-east-2.rds.amazonaws.com,1433;Database=ProjetoFinalDB;User Id=admin;Password=admin123;Encrypt=False;");
            }
        }
    }
}