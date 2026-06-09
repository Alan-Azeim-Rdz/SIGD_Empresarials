using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Gestion_de_Documentos.Models;
using System.Security.Cryptography;
using System.Text.Json;
using System.Collections.Generic;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace Gestion_de_Documentos.Controllers
{
    [Authorize(Roles = "Super Administrador")]
    public class SuperAdminController : Controller
    {
        private readonly DirContext _context;
        private readonly Gestion_de_Documentos.Services.ReportesIntegrationService _reportesService;
        private readonly Gestion_de_Documentos.Services.BusquedaIntegrationService _busquedaService;

        public SuperAdminController(
            DirContext context,
            Gestion_de_Documentos.Services.ReportesIntegrationService reportesService,
            Gestion_de_Documentos.Services.BusquedaIntegrationService busquedaService)
        {
            _context = context;
            _reportesService = reportesService;
            _busquedaService = busquedaService;
        }

        private int GetCurrentUserId()
        {
            return int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "0");
        }

        private string HashPassword(string password)
        {
            using (var sha256 = SHA256.Create())
            {
                var bytes = sha256.ComputeHash(System.Text.Encoding.Unicode.GetBytes(password));
                var builder = new System.Text.StringBuilder();
                foreach (var b in bytes)
                {
                    builder.Append(b.ToString("X2"));
                }
                return builder.ToString();
            }
        }

        #region PANEL DE CONTROL
        public async Task<IActionResult> Index()
        {
            var empresas = await _context.Empresas
                .Include(e => e.Usuarios)
                .Include(e => e.Documentos)
                .OrderByDescending(e => e.FechaRegistro)
                .ToListAsync();

            var stats = new SuperAdminStatsViewModel
            {
                TotalEmpresas = empresas.Count,
                EmpresasActivas = empresas.Count(e => e.Estatus),
                EmpresasInactivas = empresas.Count(e => !e.Estatus),
                TotalDocumentosGlobal = await _context.Documentos.CountAsync(),
                TotalUsuariosGlobal = await _context.Usuarios.CountAsync(),
                Empresas = empresas
            };

            return View(stats);
        }
        #endregion

        #region CONFIGURACIÓN DE EMPRESAS
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ToggleEstatus(int id)
        {
            var empresa = await _context.Empresas.FindAsync(id);
            if (empresa == null)
                return NotFound();

            // Evitar desactivar una empresa demo si es necesario, o permitir todo
            empresa.Estatus = !empresa.Estatus;
            
            // También desactivar/activar usuarios correspondientes para coherencia de seguridad
            var usuarios = await _context.Usuarios.Where(u => u.IdEmpresa == id).ToListAsync();
            foreach (var u in usuarios)
            {
                u.Estatus = empresa.Estatus; // Alinear estatus del usuario con el de la empresa
            }

            _context.Update(empresa);
            await _context.SaveChangesAsync();

            // Sincronizar espejo de usuarios afectados en módulo de reportes
            foreach (var u in usuarios)
            {
                await _reportesService.SincronizarUsuarioAsync(u.Id);
            }

            TempData["SuccessMessage"] = $"Estatus de la empresa '{empresa.Nombre}' actualizado con éxito.";
            return RedirectToAction(nameof(Index));
        }

        [HttpGet]
        public IActionResult CrearEmpresa()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CrearEmpresa(CrearEmpresaViewModel model)
        {
            if (string.IsNullOrEmpty(model.Slug))
            {
                model.Slug = await GenerateUniqueSlugAsync(model.Nombre);
            }
            else
            {
                string baseSlug = model.Slug.ToLowerInvariant().Replace(" ", "-");
                string finalSlug = baseSlug;
                int count = 1;
                while (await _context.Empresas.AnyAsync(e => e.Slug == finalSlug))
                {
                    finalSlug = $"{baseSlug}-{count}";
                    count++;
                }
                model.Slug = finalSlug;
            }

            ModelState.Remove("Slug");

            if (ModelState.IsValid)
            {

                bool correoExiste = await _context.Usuarios.AnyAsync(u => u.Correo == model.CorreoAdmin);
                if (correoExiste)
                {
                    ModelState.AddModelError("CorreoAdmin", "El correo electrónico del administrador ya está registrado.");
                    return View(model);
                }

                using (var transaction = await _context.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var nuevaEmpresa = new Empresa
                        {
                            Nombre = model.Nombre,
                            Slug = model.Slug,
                            RFC = model.RFC,
                            CorreoContacto = model.CorreoContacto,
                            FechaRegistro = DateTime.Now,
                            Estatus = true
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

                        // Sincronizar departamento y usuario espejo en módulo de reportes
                        await _reportesService.SincronizarDepartamentoAsync(deptoAdm.Id);
                        await _reportesService.SincronizarUsuarioAsync(nuevoUsuario.Id);

                        TempData["SuccessMessage"] = $"Empresa '{nuevaEmpresa.Nombre}' creada correctamente. El administrador '{model.NombreAdmin} {model.ApellidoAdminP}' puede iniciar sesión y crear los usuarios de su empresa desde el panel administrativo.";
                        return RedirectToAction(nameof(Index));
                    }
                    catch (Exception ex)
                    {
                        await transaction.RollbackAsync();
                        ModelState.AddModelError("", "Ocurrió un error al crear la empresa: " + ex.Message);
                        return View(model);
                    }
                }
            }

            return View(model);
        }

        private async Task<string> GenerateUniqueSlugAsync(string name)
        {
            if (string.IsNullOrEmpty(name)) return "empresa";
            
            // Normalizar a FormD para separar los caracteres base de sus acentos/diacríticos
            string normalized = name.Normalize(System.Text.NormalizationForm.FormD);
            var sb = new System.Text.StringBuilder();
            foreach (char c in normalized)
            {
                var uc = System.Globalization.CharUnicodeInfo.GetUnicodeCategory(c);
                if (uc != System.Globalization.UnicodeCategory.NonSpacingMark)
                    sb.Append(c);
            }
            string slug = sb.ToString().Normalize(System.Text.NormalizationForm.FormC).ToLowerInvariant();
            
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
        #endregion

        #region GESTIÓN GLOBAL DE USUARIOS
        [HttpGet]
        public async Task<IActionResult> Usuarios(int? idEmpresa, int? idRol, bool? estatus)
        {
            var query = _context.Usuarios
                .Include(u => u.IdEmpresaNavigation)
                .Include(u => u.IdDepartamentoNavigation)
                .Include(u => u.UsuarioRolIdUsuarioNavigations)
                    .ThenInclude(ur => ur.IdRolNavigation)
                .AsQueryable();

            if (idEmpresa.HasValue)
            {
                query = query.Where(u => u.IdEmpresa == idEmpresa.Value);
            }

            if (idRol.HasValue)
            {
                query = query.Where(u => u.UsuarioRolIdUsuarioNavigations.Any(ur => ur.IdRol == idRol.Value && ur.Estatus == true));
            }

            if (estatus.HasValue)
            {
                query = query.Where(u => u.Estatus == estatus.Value);
            }

            var usuarios = await query.OrderBy(u => u.Nombre).ToListAsync();

            ViewBag.Empresas = await _context.Empresas.Where(e => e.Estatus == true).ToListAsync();
            ViewBag.Roles = await _context.Rols.Where(r => r.Estatus == true && r.Nombre != "Super Administrador").ToListAsync();
            
            ViewBag.FiltroEmpresa = idEmpresa;
            ViewBag.FiltroRol = idRol;
            ViewBag.FiltroEstatus = estatus;

            return View(usuarios);
        }
        #endregion

        #region GESTIÓN GLOBAL DE DOCUMENTOS
        [HttpGet]
        public async Task<IActionResult> Documentos(int? idEmpresa, string? estadoActual, int? idTipoDocumento, int page = 1)
        {
            if (page < 1) page = 1;
            int pageSize = 6;

            var query = _context.Documentos
                .Include(d => d.IdEmpresaNavigation)
                .Include(d => d.IdDepartamentoNavigation)
                .Include(d => d.IdTipoDocumentoNavigation)
                .Include(d => d.IdUsuarioCreacionNavigation)
                .Where(d => d.Estatus == true)
                .AsQueryable();

            if (idEmpresa.HasValue)
            {
                query = query.Where(d => d.IdEmpresa == idEmpresa.Value);
            }

            if (!string.IsNullOrEmpty(estadoActual))
            {
                query = query.Where(d => d.EstadoActual == estadoActual);
            }

            if (idTipoDocumento.HasValue)
            {
                query = query.Where(d => d.IdTipoDocumento == idTipoDocumento.Value);
            }

            int totalDocs = await query.CountAsync();
            var documentos = await query
                .OrderByDescending(d => d.FechaCreacion)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            ViewBag.Empresas = await _context.Empresas.Where(e => e.Estatus == true).ToListAsync();
            ViewBag.TiposDocumento = await _context.TipoDocumentos.Where(t => t.Estatus == true).ToListAsync();

            ViewBag.FiltroEmpresa = idEmpresa;
            ViewBag.FiltroEstado = estadoActual;
            ViewBag.FiltroTipo = idTipoDocumento;

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = (int)Math.Ceiling((double)totalDocs / pageSize);
            ViewBag.TotalItems = totalDocs;
            ViewBag.PageSize = pageSize;

            return View(documentos);
        }
        #endregion

        #region INSPECCIÓN DE METADATOS
        [HttpGet]
        public async Task<IActionResult> VerMetadataDocumento(int id)
        {
            var doc = await _context.Documentos
                .Include(d => d.IdEmpresaNavigation)
                .Include(d => d.IdDepartamentoNavigation)
                .Include(d => d.IdTipoDocumentoNavigation)
                .Include(d => d.IdUsuarioCreacionNavigation)
                .Include(d => d.DocumentoVersions.Where(v => v.Estatus == true))
                .FirstOrDefaultAsync(d => d.Id == id && d.Estatus == true);

            if (doc == null)
            {
                return NotFound("Documento no encontrado o inactivo.");
            }

            // Ordenamos versiones descendentemente
            doc.DocumentoVersions = doc.DocumentoVersions.OrderByDescending(v => v.NumeroVersion).ThenByDescending(v => v.VersionMinor).ToList();

            // Metadatos MongoDB
            string? rawMongoJson = null;
            if (doc.IdEmpresa.HasValue)
            {
                rawMongoJson = await _busquedaService.ObtenerMetadatosMongoDBAsync(doc.Id, doc.IdEmpresa.Value);
            }
            
            ViewBag.RawMongoJson = rawMongoJson;

            return View(doc);
        }
        #endregion

        #region ELIMINACIÓN DE DOCUMENTOS
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EliminarDocumento(int id)
        {
            var userId = GetCurrentUserId();
            var doc = await _context.Documentos
                .Include(d => d.DocumentoVersions)
                .FirstOrDefaultAsync(d => d.Id == id && d.Estatus == true);

            if (doc == null) return NotFound();

            // Borrado lógico del documento
            doc.Estatus = false;
            doc.EstadoActual = "Eliminado";
            doc.FechaModificacion = DateTime.Now;
            doc.IdUsuarioModificacion = userId;

            // Borrado lógico de todas sus versiones
            foreach (var v in doc.DocumentoVersions)
            {
                v.Estatus = false;
                v.FechaModificacion = DateTime.Now;
                v.IdUsuarioModificacion = userId;
            }

            await _context.SaveChangesAsync();

            // Desindexar de búsqueda y reportes
            try
            {
                await _busquedaService.DesindexarDocumentoAsync(doc.Id);
                await _reportesService.EliminarDocumentoAsync(doc.Id);
            }
            catch (Exception)
            {
                // Ignorar o registrar errores de comunicación con microservicios
            }

            TempData["SuccessMessage"] = $"El documento '{doc.Titulo}' ha sido eliminado correctamente.";
            return RedirectToAction(nameof(Documentos));
        }
        #endregion
    }

    // ViewModels para Super Administrador
    public class SuperAdminStatsViewModel
    {
        public int TotalEmpresas { get; set; }
        public int EmpresasActivas { get; set; }
        public int EmpresasInactivas { get; set; }
        public int TotalDocumentosGlobal { get; set; }
        public int TotalUsuariosGlobal { get; set; }
        public List<Empresa> Empresas { get; set; } = new List<Empresa>();
    }

    public class CrearEmpresaViewModel
    {
        [Required(ErrorMessage = "El nombre de la empresa es obligatorio.")]
        [StringLength(100, ErrorMessage = "El nombre de la empresa no puede exceder los 100 caracteres.")]
        public string Nombre { get; set; } = null!;

        public string? Slug { get; set; }

        [StringLength(20, ErrorMessage = "El RFC no puede exceder los 20 caracteres.")]
        [RegularExpression(@"^[A-Z&Ññ]{3,4}[0-9]{6}[A-Z0-9]{3}$", ErrorMessage = "El formato de RFC no es válido (Ej: AME123456XX9).")]
        public string? RFC { get; set; }

        [EmailAddress(ErrorMessage = "El correo de contacto no tiene un formato válido.")]
        [StringLength(150, ErrorMessage = "El correo de contacto no puede exceder los 150 caracteres.")]
        public string? CorreoContacto { get; set; }

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
