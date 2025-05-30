using Microsoft.EntityFrameworkCore;
using SistemaEnderecos.Models;
using System.Collections.Generic;


namespace SistemaEnderecos.Data
{
    public class SqlContext : DbContext
    {
        public SqlContext(DbContextOptions<SqlContext> options) : base(options) { }

        public DbSet<EnderecoEntrega> EnderecoEntregas { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=SistemaEnderecos;Trusted_Connection=True;TrustServerCertificate=True;");
            }
        }
    }
}
