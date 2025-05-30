using Microsoft.EntityFrameworkCore.Design;
using Microsoft.EntityFrameworkCore;
using SistemaProduto.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SistemaProduto.Infra
{
    public class SqlContextFactory : IDesignTimeDbContextFactory<SqlContext>
    {
        public SqlContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<SqlContext>();
            optionsBuilder.UseSqlServer("Server=projetofinal-db.cl4484q408hn.us-east-2.rds.amazonaws.com,1433;Database=ProjetoFinalDB;User Id=admin;Password=admin123;Encrypt=False;");

            return new SqlContext(optionsBuilder.Options);
        }
    }
}
