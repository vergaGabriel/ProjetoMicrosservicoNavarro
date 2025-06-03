using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SistemaUser.Domain
{
        public class LoginDTO
        {
            public string EmailOrCpf { get; set; } = string.Empty;
            public string Senha { get; set; } = string.Empty;
        }
}
