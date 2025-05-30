using Microsoft.EntityFrameworkCore;
using SistemaPedidos.Models;
using System.Collections.Generic;

namespace SistemaPedidos.Data
{
    public class SqlContext : DbContext
    {
        public SqlContext(DbContextOptions<SqlContext> options) : base(options) { }

        public DbSet<Pedidos> Pedidos { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=SistemaPedidos;Trusted_Connection=True;TrustServerCertificate=True;");
            }
        }
    }
}