using Microsoft.EntityFrameworkCore;
using SistemaUser.Models;
using System.Collections.Generic;


namespace SistemaUser.Data
{
    public class SqlContext : DbContext
    {
        public SqlContext(DbContextOptions<SqlContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer(
                    "Server=projetofinal-db.cl4484q408hn.us-east-2.rds.amazonaws.com,1433;Database=ProjetoFinalDB;User Id=admin;Password=admin123;Encrypt=False;");
            }
        }
    }
}
