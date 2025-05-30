using SistemaEnderecos.Infra;
using SistemaEnderecos.Infra.Interface;
using SistemaEnderecos.Models;
using SistemaEnderecos.Data;

namespace SistemaEnderecos.Repositories
{
    public class EnderecoRepository : IEnderecoRepository
    {
        private readonly SqlContext _context;

        public EnderecoRepository(SqlContext context)
        {
            _context = context;
        }

        public bool AddEnderecos(EnderecoEntrega endereco)
        {
            _context.EnderecoEntregas.Add(endereco);
            return _context.SaveChanges() > 0;
        }

        public List<EnderecoEntrega> GetEnderecosByUsuario(int idUsuario)
        {
            return _context.EnderecoEntregas.Where(e => e.IdUsuario == idUsuario).ToList();
        }

        public EnderecoEntrega? GetEnderecosById(int id)
        {
            return _context.EnderecoEntregas.FirstOrDefault(e => e.Id == id);
        }

        public bool UpdateEnderecos(int id, EnderecoEntrega endereco)
        {
            var existente = _context.EnderecoEntregas.Find(id);
            if (existente == null) return false;

            _context.Entry(existente).CurrentValues.SetValues(endereco);
            return _context.SaveChanges() > 0;
        }

        public bool DeleteEnderecos(int id)
        {
            var endereco = _context.EnderecoEntregas.Find(id);
            if (endereco == null) return false;

            _context.EnderecoEntregas.Remove(endereco);
            return _context.SaveChanges() > 0;
        }
    }
}
