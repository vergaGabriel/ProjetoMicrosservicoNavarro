using SistemaUser.Data;
using SistemaUser.Infra.Interface;
using SistemaUser.Models;
using System.Collections.Generic;
using System.Linq;

namespace SistemaUser.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly SqlContext _context;

        public UserRepository(SqlContext context)
        {
            _context = context;
        }

        public bool AddUser(User user)
        {
            _context.Users.Add(user);
            return _context.SaveChanges() > 0;
        }

        public User? Login(string emailOrCpf, string senha)
        {
            return _context.Users
                .FirstOrDefault(u =>
                    (u.Email == emailOrCpf || u.CPF == emailOrCpf) &&
                    u.Senha == senha);
        }

        public User? GetUserById(int id)
        {
            return _context.Users.FirstOrDefault(u => u.Id == id);
        }

        public List<User> GetAll()
        {
            return _context.Users.ToList();
        }

        public bool UpdateUser(int id, User user)
        {
            var existingUser = _context.Users.Find(id);
            if (existingUser == null) return false;

            existingUser.Nome = user.Nome;
            existingUser.DataNascimento = user.DataNascimento;
            existingUser.CPF = user.CPF;
            existingUser.Email = user.Email;
            existingUser.Senha = user.Senha;
            existingUser.Cargo = user.Cargo;

            _context.Users.Update(existingUser);
            return _context.SaveChanges() > 0;
        }

        public bool DeleteUser(int id)
        {
            var user = _context.Users.Find(id);
            if (user == null) return false;

            _context.Users.Remove(user);
            return _context.SaveChanges() > 0;
        }
    }
}
