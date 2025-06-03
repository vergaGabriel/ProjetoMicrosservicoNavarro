using SistemaProduto.Models;
using System.Collections.Generic;

namespace SistemaProduto.Infra.Interface
{
    public interface IProdutoRepository
    {
        bool AddProduto(Produto produto);
        Produto? GetById(int id);
        List<Produto> GetAll();
        bool AtualizaEstoque(int produtoId, int quantidade);

        bool UpdateProduto(Produto produto);
    }
}
