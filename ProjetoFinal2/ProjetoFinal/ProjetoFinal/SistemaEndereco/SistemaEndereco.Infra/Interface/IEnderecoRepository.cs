using SistemaEnderecos.Models;

namespace SistemaEnderecos.Infra.Interface
{
    public interface IEnderecoRepository
    {
        bool AddEnderecos(EnderecoEntrega endereco);
        List<EnderecoEntrega> GetEnderecosByUsuario(int idUsuario);
        EnderecoEntrega? GetEnderecosById(int id);
        bool UpdateEnderecos(int id, EnderecoEntrega endereco);
        bool DeleteEnderecos(int id);
    }
}