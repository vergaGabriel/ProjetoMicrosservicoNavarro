using SistemaProduto.Data;
using SistemaProduto.Infra.Interface;
using SistemaProduto.Models;
using System.Collections.Generic;
using System.Linq;

namespace SistemaUser.Repositories
{
    public class ProdutoRepository : IProdutoRepository
    {
        private readonly SqlContext _context;

        public ProdutoRepository(SqlContext context)
        {
            _context = context;
        }

        public bool AddProduto(Produto produto)
        {
            _context.Produtos.Add(produto);
            return _context.SaveChanges() > 0;
        }

        public Produto? GetById(int id)
        {
            return _context.Produtos.FirstOrDefault(p => p.Id == id);
        }

        public List<Produto> GetAll()
        {
            return _context.Produtos.ToList();
        }

        public bool AtualizaEstoque(int produtoId, int quantidade)
        {
            var produto = _context.Produtos.FirstOrDefault(p => p.Id == produtoId);
            if (produto == null) return false;

            if (!produto.PodeDiminuirEstoque(quantidade)) return false;

            produto.DiminuirEstoque(quantidade);

            _context.SaveChanges();
            return true;
        }

        public bool UpdateProduto(Produto produtoAtualizado)
        {
            var produtoExistente = _context.Produtos.FirstOrDefault(p => p.Id == produtoAtualizado.Id);
            if (produtoExistente == null) return false;

            produtoExistente.Nome = produtoAtualizado.Nome;
            produtoExistente.Descricao = produtoAtualizado.Descricao;
            produtoExistente.Preco_Unidade = produtoAtualizado.Preco_Unidade;
            produtoExistente.Estoque = produtoAtualizado.Estoque;
            produtoExistente.Imagem = produtoAtualizado.Imagem;

            _context.Produtos.Update(produtoExistente);
            return _context.SaveChanges() > 0;
        }
    }
}
