using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SistemaProduto.Infra.Migrations
{
    /// <inheritdoc />
    public partial class AtualizarProduto : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Criado_Por_Id",
                table: "Produtos",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "Variacoes",
                table: "Produtos",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Criado_Por_Id",
                table: "Produtos");

            migrationBuilder.DropColumn(
                name: "Variacoes",
                table: "Produtos");
        }
    }
}
