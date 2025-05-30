using Microsoft.EntityFrameworkCore.Design;
using Microsoft.EntityFrameworkCore;
using SistemaPedidos.Data;

namespace SistemaPedidos.Infra
{
    public class SqlContextFactory : IDesignTimeDbContextFactory<SqlContext>
    {
        public SqlContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<SqlContext>();
            optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=SistemaPedidos;Trusted_Connection=True;TrustServerCertificate=True;");

            return new SqlContext(optionsBuilder.Options);
        }
    }
}