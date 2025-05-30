using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using SistemaEnderecos.Data;

namespace SistemaEnderecos.Factories
{
    public class SqlContextFactory : IDesignTimeDbContextFactory<SqlContext>
    {
        public SqlContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<SqlContext>();
            optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=SistemaEndereco;Trusted_Connection=True;TrustServerCertificate=True;");

            return new SqlContext(optionsBuilder.Options);
        }
    }
}