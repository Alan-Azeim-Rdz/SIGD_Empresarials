using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Gestion_de_Documentos.Models;
using Gestion_de_Documentos.Services;

namespace Gestion_de_Documentos.Controllers
{
    public class AuthController : Controller
    {
        private readonly DirContext _context;
        private readonly ReportesIntegrationService _reportesService;
        private readonly IEmailService _emailService;

        public AuthController(
            DirContext context,
            ReportesIntegrationService reportesService,
            IEmailService emailService)
        {
            _context = context;
            _reportesService = reportesService;
            _emailService = emailService;
        }

        [HttpGet]
        public IActionResult Login()
        {
            if (User.Identity.IsAuthenticated) return RedirectToAction("Index", "Home");
            return View("Login_fixed");
        }

        [HttpPost]
        public async Task<IActionResult> Login(string username, string contrasena, bool recordarme = false)
        {
            var user = await _context.Usuarios
                .Include(u => u.UsuarioRolIdUsuarioNavigations.Where(ur => ur.Estatus == true))
                    .ThenInclude(ur => ur.IdRolNavigation)
                .FirstOrDefaultAsync(u => u.Correo == username && u.Estatus == true);

            var passwordHash = HashPassword(contrasena);

            if (user != null && string.Equals(user.Contrasena.Trim(), passwordHash.Trim(), StringComparison.OrdinalIgnoreCase))
            {

                if (user.IdEmpresa.HasValue)
                {
                    var company = await _context.Empresas.FirstOrDefaultAsync(e => e.Id == user.IdEmpresa.Value);
                    if (company != null && company.Estatus == false)
                    {
                        ViewBag.Error = "La empresa no ha sido validada. Por favor, revisa tu correo electrónico para activarla.";
                        return View("Login_fixed");
                    }
                }

                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Name, user.Correo),
                    new Claim(ClaimTypes.GivenName, user.Nombre),
                };

                if (user.IdEmpresa.HasValue)
                {
                    claims.Add(new Claim("IdEmpresa", user.IdEmpresa.Value.ToString()));
                }

                var activeRoles = user.UsuarioRolIdUsuarioNavigations
                    ?.Select(ur => ur.IdRolNavigation?.Nombre)
                    .Where(r => !string.IsNullOrEmpty(r))
                    .ToList() ?? new List<string>();

                if (activeRoles.Any())
                {
                    foreach (var rol in activeRoles)
                        claims.Add(new Claim(ClaimTypes.Role, rol));
                }
                else
                {
                    claims.Add(new Claim(ClaimTypes.Role, "Usuario"));
                }

                var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                var principal = new ClaimsPrincipal(identity);

                var authProperties = new AuthenticationProperties
                {
                    IsPersistent = recordarme,
                    ExpiresUtc = recordarme
                        ? DateTimeOffset.UtcNow.AddDays(30)
                        : DateTimeOffset.UtcNow.AddHours(2),
                    AllowRefresh = true
                };

                await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal, authProperties);

                try
                {
                    RegistrarBitacora(user.Id, "EXITOSO");
                    await _context.SaveChangesAsync();
                }
                catch { }

                return RedirectToAction("Index", "Home");
            }

            if (user != null)
            {
                try
                {
                    RegistrarBitacora(user.Id, "FALLIDO");
                    await _context.SaveChangesAsync();
                }
                catch { }
            }

            ViewBag.Error = "Credenciales incorrectas. Verifica tu contraseña, o asegúrate de haber validado tu cuenta y correo electrónico.";
            return View("Login_fixed");
        }

        // --- REGISTRO (Protegido por Rol) ---
        [HttpGet]
        [Authorize(Roles = "Administrador,Superior")]
        public IActionResult Registro()
        {
            var empresaId = int.TryParse(User.FindFirst("IdEmpresa")?.Value, out var empId) ? empId : 0;
            ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == empresaId).ToList();
            // Excluir roles restringidos del selector
            ViewBag.Roles = _context.Rols.Where(r => r.Estatus == true
                && r.Nombre != "Super Administrador").ToList();
            return View();
        }

        [HttpPost]
        [Authorize(Roles = "Administrador,Superior")]
        public async Task<IActionResult> Registro(Usuario newUser, int roleId)
        {
            var companyId = int.TryParse(User.FindFirst("IdEmpresa")?.Value, out var empId) ? empId : 0;

            // Evitar errores de ModelState en propiedades de navegación asignadas por el controlador
            ModelState.Remove("IdDepartamentoNavigation");
            ModelState.Remove("IdEmpresaNavigation");
            ModelState.Remove("IdUsuarioCreacionNavigation");
            ModelState.Remove("IdUsuarioModificacionNavigation");
            ModelState.Remove("IdUsuarioEliminacionNavigation");
            ModelState.Remove("IdEmpresa");
            ModelState.Remove("Estatus");
            ModelState.Remove("FechaCreacion");
            ModelState.Remove("IdUsuarioCreacion");

            if (ModelState.IsValid)
            {
                bool exists = await _context.Usuarios.AnyAsync(u => u.Correo == newUser.Correo);
                if (exists)
                {
                    ViewBag.Error = "Este correo electrónico ya está registrado.";
                    ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == companyId).ToList();
                    ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
                    return View(newUser);
                }

                var departmentExists = await _context.Departamentos.AnyAsync(d => d.Id == newUser.IdDepartamento && d.Estatus == true && d.IdEmpresa == companyId);
                if (!departmentExists)
                {
                    ViewBag.Error = "El departamento seleccionado no es válido.";
                    ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == companyId).ToList();
                    ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
                    return View(newUser);
                }

                var roleExists = await _context.Rols.AnyAsync(r => r.Id == roleId && r.Estatus == true);
                if (!roleExists)
                {
                    ViewBag.Error = "El rol seleccionado no es válido.";
                    ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == companyId).ToList();
                    ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
                    return View(newUser);
                }

                newUser.Estatus = true;
                newUser.FechaCreacion = DateTime.Now;
                newUser.IdUsuarioCreacion = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
                newUser.IdEmpresa = companyId;

                newUser.Contrasena = HashPassword(newUser.Contrasena);

                using (var transaction = await _context.Database.BeginTransactionAsync())
                {
                    try
                    {
                        _context.Usuarios.Add(newUser);
                        await _context.SaveChangesAsync();

                        var userRole = new UsuarioRol
                        {
                            IdUsuario = newUser.Id,
                            IdRol = roleId,
                            FechaAsignacion = DateTime.Now,
                            FechaCreacion = DateTime.Now,
                            Estatus = true,
                            IdUsuarioCreacion = newUser.IdUsuarioCreacion
                        };
                        _context.UsuarioRols.Add(userRole);
                        await _context.SaveChangesAsync();

                        await transaction.CommitAsync();

                        // Sincronizar usuario espejo en módulo de reportes
                        await _reportesService.SincronizarUsuarioAsync(newUser.Id);
                    }
                    catch (Exception ex)
                    {
                        await transaction.RollbackAsync();
                        ViewBag.Error = "Ocurrió un error al registrar el usuario y su rol: " + ex.Message;
                        ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == companyId).ToList();
                        ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
                        return View(newUser);
                    }
                }

                ViewBag.Exito = "Usuario creado exitosamente. Deberá cambiar su contraseña en el primer acceso.";
                ModelState.Clear();
                ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == companyId).ToList();
                ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
                return View(new Usuario()); // Limpia el formulario
            }

            // Debug: ModelState errors
            var errors = ModelState.Where(x => x.Value.Errors.Count > 0)
                .ToDictionary(k => k.Key, v => v.Value.Errors.Select(e => e.ErrorMessage).ToList());
            if (errors.Any())
            {
                ViewBag.Error = "Datos inválidos: " + string.Join("; ", errors.SelectMany(e => e.Value));
            }

            ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == companyId).ToList();
            ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
            return View(newUser);
        }
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> Usuarios()
        {
            var empresaId = int.TryParse(User.FindFirst("IdEmpresa")?.Value, out var empId) ? empId : 0;
            ViewBag.Departamentos = await _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == empresaId).ToListAsync();
            var usuarios = await _context.Usuarios
                .Include(u => u.IdDepartamentoNavigation)
                .Include(u => u.UsuarioRolIdUsuarioNavigations)
                    .ThenInclude(ur => ur.IdRolNavigation)
                .Where(u => u.Estatus == true && u.IdEmpresa == empresaId)
                .ToListAsync();
            return View(usuarios);
        }

        [HttpGet]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> EditarUsuario(int id)
        {
            var empresaId = int.TryParse(User.FindFirst("IdEmpresa")?.Value, out var empId) ? empId : 0;
            var usuario = await _context.Usuarios
                .Include(u => u.UsuarioRolIdUsuarioNavigations)
                .FirstOrDefaultAsync(u => u.Id == id && u.IdEmpresa == empresaId);
            if (usuario == null) return NotFound();
            
            ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == empresaId).ToList();
            // Excluir roles restringidos del selector
            ViewBag.Roles = _context.Rols.Where(r => r.Estatus == true
                && r.Nombre != "Super Administrador").ToList();

            var rolAsignado = usuario.UsuarioRolIdUsuarioNavigations.FirstOrDefault(ur => ur.Estatus == true);
            ViewBag.IdRolAsignado = rolAsignado?.IdRol ?? 0;

            return View(usuario);
        }

        [HttpPost]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> EditarUsuario(int id, string nombre, string apellidoP, string? apellidoM, string correo, int idDepartamento, int idRol, string? nuevaContrasena)
        {
            var empresaId = int.TryParse(User.FindFirst("IdEmpresa")?.Value, out var empId) ? empId : 0;
            var usuario = await _context.Usuarios
                .Include(u => u.UsuarioRolIdUsuarioNavigations)
                .FirstOrDefaultAsync(u => u.Id == id && u.IdEmpresa == empresaId);
            if (usuario == null) return NotFound();

            // Verificar correo único
            bool correoEnUso = await _context.Usuarios.AnyAsync(u => u.Correo == correo && u.Id != id);
            if (correoEnUso)
            {
                ViewBag.Error = "El correo electrónico ya está en uso por otro usuario.";
                ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == empresaId).ToList();
                ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
                ViewBag.IdRolAsignado = idRol;
                return View(usuario);
            }

            var deptoValido = await _context.Departamentos.AnyAsync(d => d.Id == idDepartamento && d.Estatus == true && d.IdEmpresa == empresaId);
            if (!deptoValido)
            {
                ViewBag.Error = "El departamento seleccionado no es válido.";
                ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == empresaId).ToList();
                ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
                ViewBag.IdRolAsignado = idRol;
                return View(usuario);
            }

            var rolValido = await _context.Rols.AnyAsync(r => r.Id == idRol && r.Estatus == true);
            if (!rolValido)
            {
                ViewBag.Error = "El rol seleccionado no es válido.";
                ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == empresaId).ToList();
                ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
                ViewBag.IdRolAsignado = idRol;
                return View(usuario);
            }

            using (var transaction = await _context.Database.BeginTransactionAsync())
            {
                try
                {
                    usuario.Nombre = nombre;
                    usuario.ApellidoP = apellidoP;
                    usuario.ApellidoM = apellidoM;
                    usuario.Correo = correo;
                    usuario.IdDepartamento = idDepartamento;
                    usuario.FechaModificacion = DateTime.Now;
                    usuario.IdUsuarioModificacion = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");

                    if (!string.IsNullOrWhiteSpace(nuevaContrasena))
                    {
                        usuario.Contrasena = HashPassword(nuevaContrasena);
                    }

                    await _context.SaveChangesAsync();

                    var rolesActuales = await _context.UsuarioRols
                        .Where(ur => ur.IdUsuario == id && ur.Estatus == true)
                        .ToListAsync();

                    bool rolYaAsignado = false;
                    foreach (var ur in rolesActuales)
                    {
                        if (ur.IdRol == idRol)
                        {
                            rolYaAsignado = true;
                        }
                        else
                        {
                            ur.Estatus = false;
                            ur.FechaEliminacion = DateTime.Now;
                            ur.IdUsuarioEliminacion = usuario.IdUsuarioModificacion;
                            _context.Update(ur);
                        }
                    }

                    if (!rolYaAsignado)
                    {
                        var nuevoUsuarioRol = new UsuarioRol
                        {
                            IdUsuario = usuario.Id,
                            IdRol = idRol,
                            FechaAsignacion = DateTime.Now,
                            FechaCreacion = DateTime.Now,
                            Estatus = true,
                            IdUsuarioCreacion = usuario.IdUsuarioModificacion
                        };
                        _context.UsuarioRols.Add(nuevoUsuarioRol);
                    }

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();

                    await _reportesService.SincronizarUsuarioAsync(usuario.Id);
                }
                catch (Exception ex)
                {
                    await transaction.RollbackAsync();
                    ViewBag.Error = "Ocurrió un error al actualizar el usuario y su rol: " + ex.Message;
                    ViewBag.Departamentos = _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == empresaId).ToList();
                    ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true).ToListAsync();
                    ViewBag.IdRolAsignado = idRol;
                    return View(usuario);
                }
            }

            TempData["Exito"] = "Usuario actualizado correctamente.";
            return RedirectToAction("Usuarios");
        }

        [HttpPost]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> EliminarUsuario(int id)
        {
            var empresaId = int.TryParse(User.FindFirst("IdEmpresa")?.Value, out var empId) ? empId : 0;
            var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.Id == id && u.IdEmpresa == empresaId);
            if (usuario != null)
            {
                usuario.Estatus = false;
                usuario.FechaEliminacion = DateTime.Now;
                usuario.IdUsuarioEliminacion = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
                await _context.SaveChangesAsync();

                await _reportesService.SincronizarUsuarioAsync(usuario.Id);

                TempData["Exito"] = $"Usuario '{usuario.Nombre} {usuario.ApellidoP}' eliminado correctamente.";
            }
            return RedirectToAction("Usuarios");
        }

        [HttpGet]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> UsuariosEliminados()
        {
            var empresaId = int.TryParse(User.FindFirst("IdEmpresa")?.Value, out var empId) ? empId : 0;
            ViewBag.Departamentos = await _context.Departamentos.Where(d => d.Estatus == true && d.IdEmpresa == empresaId).ToListAsync();
            var usuarios = await _context.Usuarios
                .Include(u => u.IdDepartamentoNavigation)
                .Include(u => u.UsuarioRolIdUsuarioNavigations)
                    .ThenInclude(ur => ur.IdRolNavigation)
                .Where(u => (u.Estatus == false || u.Estatus == null) && u.IdEmpresa == empresaId)
                .ToListAsync();
            return View(usuarios);
        }

        [HttpPost]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> ReactivarUsuario(int id)
        {
            var empresaId = int.TryParse(User.FindFirst("IdEmpresa")?.Value, out var empId) ? empId : 0;
            var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.Id == id && u.IdEmpresa == empresaId);
            if (usuario != null)
            {
                usuario.Estatus = true;
                usuario.FechaEliminacion = null;
                usuario.IdUsuarioEliminacion = null;
                usuario.FechaModificacion = DateTime.Now;
                usuario.IdUsuarioModificacion = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
                await _context.SaveChangesAsync();

                // Sincronizar usuario espejo en módulo de reportes
                await _reportesService.SincronizarUsuarioAsync(usuario.Id);

                TempData["Exito"] = $"Usuario '{usuario.Nombre} {usuario.ApellidoP}' reactivado correctamente.";
            }
            return RedirectToAction("Usuarios");
        }

        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login");
        }

        [HttpGet]
        public async Task<IActionResult> ValidarRegistro(string token)
        {
            if (string.IsNullOrEmpty(token))
            {
                ViewBag.Error = "Token de validación no proporcionado.";
                return View();
            }

            var empresa = await _context.Empresas.FirstOrDefaultAsync(e => e.TokenValidacion == token);

            if (empresa == null)
            {
                ViewBag.Error = "El enlace de validación es inválido o ya ha sido utilizado.";
                return View();
            }

            empresa.Estatus = true;
            empresa.TokenValidacion = null;

            await _context.SaveChangesAsync();

            // Sincronizar al módulo de reportes
            try
            {
                var deptoAdm = await _context.Departamentos.FirstOrDefaultAsync(d => d.IdEmpresa == empresa.Id);
                if (deptoAdm != null)
                {
                    await _reportesService.SincronizarDepartamentoAsync(deptoAdm.Id);
                    var usuarioAdm = await _context.Usuarios.FirstOrDefaultAsync(u => u.IdDepartamento == deptoAdm.Id);
                    if (usuarioAdm != null)
                    {
                        await _reportesService.SincronizarUsuarioAsync(usuarioAdm.Id);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al sincronizar con Reportes: {ex.Message}");
            }

            ViewBag.Exito = "¡Cuenta validada con éxito! Ya puedes iniciar sesión en la plataforma.";
            return View();
        }

        public IActionResult AccesoDenegado()
        {
            return View();
        }

        private string HashPassword(string password)
        {
            if (string.IsNullOrEmpty(password)) return string.Empty;
            using var sha256 = SHA256.Create();
            // UTF-16LE para coincidir con HASHBYTES('SHA2_256', N'...') en SQL Server
            var bytes = sha256.ComputeHash(Encoding.Unicode.GetBytes(password));
            var builder = new StringBuilder();
            foreach (var b in bytes)
                builder.Append(b.ToString("X2"));
            return builder.ToString();
        }

        private void RegistrarBitacora(int idUsuario, string estado)
        {
            _context.BitacoraAccesos.Add(new BitacoraAcceso
            {
                IdUsuario = idUsuario,
                FechaHoraIntento = DateTime.Now,
                DireccionIp = GetClientIpAddress(),
                EstadoIntento = estado,
                Estatus = true,
                IdUsuarioCreacion = idUsuario
            });
        }

        private string GetClientIpAddress()
        {
            var ip = HttpContext.Request.Headers["X-Forwarded-For"].FirstOrDefault();
            if (string.IsNullOrEmpty(ip))
                ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
            else
                ip = ip.Split(',').FirstOrDefault()?.Trim();

            if (ip == "::1") ip = "127.0.0.1";
            if (!string.IsNullOrEmpty(ip) && ip.StartsWith("::ffff:"))
                ip = ip.Substring(7);

            return ip ?? "127.0.0.1";
        }

        [HttpGet]
        public IActionResult RegistroEmpresa()
        {
            if (User.Identity.IsAuthenticated) return RedirectToAction("Index", "Home");
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> RegistroEmpresa(RegistroEmpresaViewModel model)
        {
            if (string.IsNullOrEmpty(model.SlugEmpresa))
            {
                model.SlugEmpresa = await GenerateUniqueSlugAsync(model.NombreEmpresa);
            }
            else
            {
                string baseSlug = model.SlugEmpresa.ToLowerInvariant().Replace(" ", "-");
                string finalSlug = baseSlug;
                int count = 1;
                while (await _context.Empresas.AnyAsync(e => e.Slug == finalSlug))
                {
                    finalSlug = $"{baseSlug}-{count}";
                    count++;
                }
                model.SlugEmpresa = finalSlug;
            }

            ModelState.Remove("SlugEmpresa");

            if (ModelState.IsValid)
            {
                bool correoExiste = await _context.Usuarios.AnyAsync(u => u.Correo == model.CorreoAdmin);
                if (correoExiste)
                {
                    ViewBag.Error = "El correo electrónico del administrador ya está registrado.";
                    return View(model);
                }

                using (var transaction = await _context.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var token = Guid.NewGuid().ToString();
                        var nuevaEmpresa = new Empresa
                        {
                            Nombre = model.NombreEmpresa,
                            Slug = model.SlugEmpresa,
                            RFC = model.RFC,
                            CorreoContacto = model.CorreoContacto,
                            FechaRegistro = DateTime.Now,
                            Estatus = false,
                            TokenValidacion = token
                        };
                        _context.Empresas.Add(nuevaEmpresa);
                        await _context.SaveChangesAsync();

                        var deptoAdm = new Departamento
                        {
                            Nombre = "Administración",
                            Abreviatura = "ADM",
                            Estatus = true,
                            FechaCreacion = DateTime.Now,
                            IdEmpresa = nuevaEmpresa.Id
                        };
                        _context.Departamentos.Add(deptoAdm);
                        await _context.SaveChangesAsync();

                        var nuevoUsuario = new Usuario
                        {
                            IdDepartamento = deptoAdm.Id,
                            IdEmpresa = nuevaEmpresa.Id,
                            Nombre = model.NombreAdmin,
                            ApellidoP = model.ApellidoAdminP,
                            ApellidoM = model.ApellidoAdminM,
                            Correo = model.CorreoAdmin,
                            Contrasena = HashPassword(model.ContrasenaAdmin),
                            FechaCreacion = DateTime.Now,
                            Estatus = true
                        };
                        _context.Usuarios.Add(nuevoUsuario);
                        await _context.SaveChangesAsync();

                        var rolAdmin = await _context.Rols.FirstOrDefaultAsync(r => r.Nombre == "Administrador" && r.Estatus == true);
                        if (rolAdmin == null)
                        {
                            rolAdmin = new Rol
                            {
                                Nombre = "Administrador",
                                Descripcion = "Administrador de la Empresa",
                                Estatus = true,
                                FechaCreacion = DateTime.Now
                            };
                            _context.Rols.Add(rolAdmin);
                            await _context.SaveChangesAsync();
                        }


                        var usuarioRol = new UsuarioRol
                        {
                            IdUsuario = nuevoUsuario.Id,
                            IdRol = rolAdmin.Id,
                            FechaAsignacion = DateTime.Now,
                            FechaCreacion = DateTime.Now,
                            Estatus = true,
                            IdUsuarioCreacion = nuevoUsuario.Id
                        };
                        _context.UsuarioRols.Add(usuarioRol);
                        await _context.SaveChangesAsync();

                        deptoAdm.IdUsuarioCreacion = nuevoUsuario.Id;
                        _context.Update(deptoAdm);
                        await _context.SaveChangesAsync();

                        await transaction.CommitAsync();

                        // Enviar correo de validación
                        var callbackUrl = Url.Action("ValidarRegistro", "Auth", new { token }, protocol: Request.Scheme);
                        var emailBody = $@"
                            <h2>¡Bienvenido a SIGD Empresarial!</h2>
                            <p>Hola {model.NombreAdmin},</p>
                            <p>Tu empresa <strong>{model.NombreEmpresa}</strong> ha sido registrada con éxito.</p>
                            <p>Para activar tu cuenta y poder iniciar sesión, por favor valida tu correo electrónico haciendo clic en el siguiente enlace:</p>
                            <p><a href='{callbackUrl}'>Validar mi cuenta</a></p>
                            <br>
                            <p>Si no has sido tú quien solicitó el registro, ignora este mensaje.</p>
                        ";
                        
                        await _emailService.SendEmailAsync(model.CorreoAdmin, "Validación de Registro - SIGD Empresarial", emailBody);

                        TempData["Exito"] = "Registro exitoso. Se ha enviado un correo al administrador para validar la cuenta.";
                        return RedirectToAction(nameof(Login));
                    }
                    catch (Exception ex)
                    {
                        await transaction.RollbackAsync();
                        ViewBag.Error = "Ocurrió un error al registrar la empresa: " + ex.Message;
                        return View(model);
                    }
                }
            }

            return View(model);
        }

        private async Task<string> GenerateUniqueSlugAsync(string name)
        {
            if (string.IsNullOrEmpty(name)) return "empresa";

            string normalized = name.Normalize(NormalizationForm.FormD);
            var sb = new StringBuilder();
            foreach (char c in normalized)
            {
                if (System.Globalization.CharUnicodeInfo.GetUnicodeCategory(c) != System.Globalization.UnicodeCategory.NonSpacingMark)
                    sb.Append(c);
            }

            string slug = sb.ToString().Normalize(NormalizationForm.FormC).ToLowerInvariant();
            
            slug = System.Text.RegularExpressions.Regex.Replace(slug, @"[^a-z0-9\s-]", "");
            slug = System.Text.RegularExpressions.Regex.Replace(slug, @"\s+", " ").Trim();
            slug = System.Text.RegularExpressions.Regex.Replace(slug, @"\s", "-");
            
            if (string.IsNullOrEmpty(slug)) slug = "empresa";

            string finalSlug = slug;
            int count = 1;
            while (await _context.Empresas.AnyAsync(e => e.Slug == finalSlug))
            {
                finalSlug = $"{slug}-{count}";
                count++;
            }
            return finalSlug;
        }
    }

    public class RegistroEmpresaViewModel
    {
        [Required(ErrorMessage = "El nombre de la empresa es obligatorio.")]
        [StringLength(100, ErrorMessage = "El nombre de la empresa no puede exceder los 100 caracteres.")]
        public string NombreEmpresa { get; set; } = null!;

        public string? SlugEmpresa { get; set; }

        [Required(ErrorMessage = "El RFC es obligatorio.")]
        [StringLength(20, ErrorMessage = "El RFC no puede exceder los 20 caracteres.")]
        [RegularExpression(@"^[A-Z&Ññ]{3,4}[0-9]{6}[A-Z0-9]{3}$", ErrorMessage = "El formato de RFC no es válido (Ej: AME123456XX9).")]
        public string RFC { get; set; } = null!;

        [Required(ErrorMessage = "El correo de contacto es obligatorio.")]
        [EmailAddress(ErrorMessage = "El correo de contacto no tiene un formato válido.")]
        [StringLength(150, ErrorMessage = "El correo de contacto no puede exceder los 150 caracteres.")]
        public string CorreoContacto { get; set; } = null!;

        [Required(ErrorMessage = "El nombre del administrador es obligatorio.")]
        [StringLength(100, ErrorMessage = "El nombre del administrador no puede exceder los 100 caracteres.")]
        public string NombreAdmin { get; set; } = null!;

        [Required(ErrorMessage = "El primer apellido es obligatorio.")]
        [StringLength(100, ErrorMessage = "El primer apellido no puede exceder los 100 caracteres.")]
        public string ApellidoAdminP { get; set; } = null!;

        [StringLength(100, ErrorMessage = "El segundo apellido no puede exceder los 100 caracteres.")]
        public string? ApellidoAdminM { get; set; }

        [Required(ErrorMessage = "El correo del administrador es obligatorio.")]
        [EmailAddress(ErrorMessage = "El correo del administrador no tiene un formato válido.")]
        [StringLength(150, ErrorMessage = "El correo del administrador no puede exceder los 150 caracteres.")]
        public string CorreoAdmin { get; set; } = null!;

        [Required(ErrorMessage = "La contraseña es obligatoria.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener entre 8 y 100 caracteres.")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$", ErrorMessage = "La contraseña debe tener al menos una letra mayúscula, una minúscula y un número.")]
        public string ContrasenaAdmin { get; set; } = null!;
    }
}