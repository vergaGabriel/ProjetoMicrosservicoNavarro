using SistemaUser.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SistemaUser.Infra.Interface
{
    public interface IUserRepository
    {
        bool AddUser(User user);
        User? Login(string emailOrCpf, string senha);
        User? GetUserById(int id);
        List<User> GetAll();
        bool UpdateUser(int id, User user);
        bool DeleteUser(int id);
    }

}
