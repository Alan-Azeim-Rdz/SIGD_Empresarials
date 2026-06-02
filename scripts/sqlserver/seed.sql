USE [SIGD_Central];
GO
SET NOCOUNT ON;

-- ==========================================================================================
-- SEED CONSOLIDADO REFACTORIZADO: USUARIOS REALES Y LOGICA DE NEGOCIO
-- ==========================================================================================

-- ============================================================
-- SECCIÓN 1: ROLES GLOBALES (Idempotente)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol] WHERE Nombre = 'Administrador')
    INSERT INTO [dbo].[Rol] (Nombre, Descripcion, IdUsuarioCreacion, FechaCreacion, Estatus)
    VALUES (N'Administrador', N'Administrador de la empresa. Gestiona usuarios, roles, departamentos y documentos.', 1, GETDATE(), 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol] WHERE Nombre = 'Usuario')
    INSERT INTO [dbo].[Rol] (Nombre, Descripcion, IdUsuarioCreacion, FechaCreacion, Estatus)
    VALUES (N'Usuario', N'Usuario de área. Permisos de consulta y creación de borradores.', 1, GETDATE(), 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol] WHERE Nombre = 'Auditor')
    INSERT INTO [dbo].[Rol] (Nombre, Descripcion, IdUsuarioCreacion, FechaCreacion, Estatus)
    VALUES (N'Auditor', N'Solo lectura global dentro de su empresa.', 1, GETDATE(), 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol] WHERE Nombre = 'Superior')
    INSERT INTO [dbo].[Rol] (Nombre, Descripcion, IdUsuarioCreacion, FechaCreacion, Estatus)
    VALUES (N'Superior', N'Permite autorizar flujos de aprobación.', 1, GETDATE(), 1);
GO

-- ============================================================
-- SECCIÓN 2: EMPRESAS (TechCorp Solutions e Innovar)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Empresa] ON;
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[Empresa] WHERE Id = 2)
    INSERT INTO [dbo].[Empresa] (Id, Nombre, Slug, RFC, CorreoContacto, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (2, N'TechCorp Solutions', N'techcorp', N'TCS123456789', N'contacto@techcorp.local', GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Empresa] WHERE Id = 3)
    INSERT INTO [dbo].[Empresa] (Id, Nombre, Slug, RFC, CorreoContacto, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (3, N'Grupo Innovar', N'grupoinnovar', N'GIN654321XYZ', N'info@grupoinnovar.local', GETDATE(), 1, 1);
GO
SET IDENTITY_INSERT [dbo].[Empresa] OFF;
GO

-- ============================================================
-- SECCIÓN 3: DEPARTAMENTOS
-- ============================================================
SET IDENTITY_INSERT [dbo].[Departamento] ON;
GO

-- Departamentos de TechCorp Solutions (Id = 2)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Id = 7)
    INSERT INTO [dbo].[Departamento] (Id, Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (7, N'Administración', N'ADM', 1, GETDATE(), 2, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Id = 8)
    INSERT INTO [dbo].[Departamento] (Id, Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (8, N'Tecnología de Información', N'TI', 1, GETDATE(), 2, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Id = 9)
    INSERT INTO [dbo].[Departamento] (Id, Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (9, N'Recursos Humanos', N'RRHH', 1, GETDATE(), 2, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Id = 10)
    INSERT INTO [dbo].[Departamento] (Id, Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (10, N'Legal y Cumplimiento', N'LEG', 1, GETDATE(), 2, 1);

-- Departamentos de Grupo Innovar (Id = 3)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Id = 11)
    INSERT INTO [dbo].[Departamento] (Id, Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (11, N'Administración', N'ADM', 1, GETDATE(), 3, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Id = 12)
    INSERT INTO [dbo].[Departamento] (Id, Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (12, N'Finanzas', N'FIN', 1, GETDATE(), 3, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Id = 13)
    INSERT INTO [dbo].[Departamento] (Id, Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (13, N'Operaciones', N'OPS', 1, GETDATE(), 3, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Id = 14)
    INSERT INTO [dbo].[Departamento] (Id, Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (14, N'Comercial', N'COM', 1, GETDATE(), 3, 1);
GO
SET IDENTITY_INSERT [dbo].[Departamento] OFF;
GO

-- ============================================================
-- SECCIÓN 4: TIPOS DE DOCUMENTO
-- ============================================================
SET IDENTITY_INSERT [dbo].[TipoDocumento] ON;
GO

-- Tipos de TechCorp (Id = 2)
IF NOT EXISTS (SELECT 1 FROM [dbo].[TipoDocumento] WHERE Id = 8)
    INSERT INTO [dbo].[TipoDocumento] (Id, Nombre, Abreviatura, TiempoRetencionMeses, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (8, N'Contrato', N'CON', 84, 1, GETDATE(), 2, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[TipoDocumento] WHERE Id = 12)
    INSERT INTO [dbo].[TipoDocumento] (Id, Nombre, Abreviatura, TiempoRetencionMeses, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (12, N'Manual Técnico', N'MT', 60, 1, GETDATE(), 2, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[TipoDocumento] WHERE Id = 13)
    INSERT INTO [dbo].[TipoDocumento] (Id, Nombre, Abreviatura, TiempoRetencionMeses, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (13, N'Política Interna', N'PI', 36, 1, GETDATE(), 2, 1);

-- Tipos de Grupo Innovar (Id = 3)
IF NOT EXISTS (SELECT 1 FROM [dbo].[TipoDocumento] WHERE Id = 9)
    INSERT INTO [dbo].[TipoDocumento] (Id, Nombre, Abreviatura, TiempoRetencionMeses, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (9, N'Reporte Financiero', N'RF', 60, 1, GETDATE(), 3, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[TipoDocumento] WHERE Id = 10)
    INSERT INTO [dbo].[TipoDocumento] (Id, Nombre, Abreviatura, TiempoRetencionMeses, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (10, N'Acta de Reunión', N'AR', 24, 1, GETDATE(), 3, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[TipoDocumento] WHERE Id = 11)
    INSERT INTO [dbo].[TipoDocumento] (Id, Nombre, Abreviatura, TiempoRetencionMeses, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (11, N'Procedimiento Operativo', N'PO', 48, 1, GETDATE(), 3, 1);
GO
SET IDENTITY_INSERT [dbo].[TipoDocumento] OFF;
GO

-- ============================================================
-- SECCIÓN 5: USUARIOS REALES (Exactamente 8: 1 Admin, 1 User, 1 Auditor, 1 Superior por Empresa)
-- ============================================================
SET IDENTITY_INSERT [dbo].[Usuario] ON;
GO

-- Contraseña compartida: Test@2026!
DECLARE @PwdHash VARCHAR(255) = CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', N'Test@2026!'), 2);

-- Usuarios de TechCorp (Id = 2)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Id = 7)
    INSERT INTO [dbo].[Usuario] (Id, IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (7, 7, 2, N'Ana', N'García', N'Martínez', N'admin.tech@techcorp.local', @PwdHash, GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Id = 8)
    INSERT INTO [dbo].[Usuario] (Id, IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (8, 8, 2, N'Tomás', N'López', N'Gómez', N'user.tech@techcorp.local', @PwdHash, GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Id = 9)
    INSERT INTO [dbo].[Usuario] (Id, IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (9, 7, 2, N'Silvia', N'Mendoza', N'Torres', N'auditor.tech@techcorp.local', @PwdHash, GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Id = 10)
    INSERT INTO [dbo].[Usuario] (Id, IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (10, 8, 2, N'Roberto', N'Vargas', N'Soto', N'superior.tech@techcorp.local', @PwdHash, GETDATE(), 1, 1);

-- Usuarios de Grupo Innovar (Id = 3)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Id = 11)
    INSERT INTO [dbo].[Usuario] (Id, IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (11, 11, 3, N'Carlos', N'López', N'Hernández', N'admin@grupoinnovar.local', @PwdHash, GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Id = 12)
    INSERT INTO [dbo].[Usuario] (Id, IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (12, 13, 3, N'Patricia', N'Luna', N'Ortega', N'user@grupoinnovar.local', @PwdHash, GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Id = 13)
    INSERT INTO [dbo].[Usuario] (Id, IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (13, 11, 3, N'Ernesto', N'Medina', N'Reyes', N'auditor@grupoinnovar.local', @PwdHash, GETDATE(), 1, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Id = 14)
    INSERT INTO [dbo].[Usuario] (Id, IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (14, 13, 3, N'Elena', N'Ruiz', N'Navarro', N'superior@grupoinnovar.local', @PwdHash, GETDATE(), 1, 1);
GO
SET IDENTITY_INSERT [dbo].[Usuario] OFF;
GO

-- ============================================================
-- SECCIÓN 6: ASIGNACIONES DE ROL
-- ============================================================
DECLARE @RolAdmin INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Administrador');
DECLARE @RolUser INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Usuario');
DECLARE @RolAuditor INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Auditor');
DECLARE @RolSuper INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Superior');

-- TechCorp
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario_Rol] WHERE IdUsuario = 7)
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion) VALUES (7, @RolAdmin, GETDATE(), GETDATE(), 1, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario_Rol] WHERE IdUsuario = 8)
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion) VALUES (8, @RolUser, GETDATE(), GETDATE(), 1, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario_Rol] WHERE IdUsuario = 9)
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion) VALUES (9, @RolAuditor, GETDATE(), GETDATE(), 1, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario_Rol] WHERE IdUsuario = 10)
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion) VALUES (10, @RolSuper, GETDATE(), GETDATE(), 1, 1);

-- Grupo Innovar
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario_Rol] WHERE IdUsuario = 11)
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion) VALUES (11, @RolAdmin, GETDATE(), GETDATE(), 1, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario_Rol] WHERE IdUsuario = 12)
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion) VALUES (12, @RolUser, GETDATE(), GETDATE(), 1, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario_Rol] WHERE IdUsuario = 13)
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion) VALUES (13, @RolAuditor, GETDATE(), GETDATE(), 1, 1);
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario_Rol] WHERE IdUsuario = 14)
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion) VALUES (14, @RolSuper, GETDATE(), GETDATE(), 1, 1);
GO

-- ============================================================
-- SECCIÓN 7: PERMISOS DEL SISTEMA Y ASIGNACIONES
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[Permiso] WHERE Codigo = 'DOC.CREAR')
BEGIN
    INSERT INTO [dbo].[Permiso] (Codigo, Descripcion, Modulo, Estatus, FechaCreacion, IdUsuarioCreacion) VALUES
    ('DOC.CREAR',    'Crear nuevos documentos',               'Documentos',    1, GETDATE(), 1),
    ('DOC.EDITAR',   'Editar documentos existentes',           'Documentos',    1, GETDATE(), 1),
    ('DOC.ELIMINAR', 'Eliminar documentos',                    'Documentos',    1, GETDATE(), 1),
    ('DOC.VER',      'Ver y descargar documentos',             'Documentos',    1, GETDATE(), 1),
    ('DOC.APROBAR',  'Aprobar o rechazar documentos en flujo', 'Documentos',    1, GETDATE(), 1),
    ('DOC.FIRMAR',   'Firmar digitalmente documentos',         'Documentos',    1, GETDATE(), 1),
    ('USR.CREAR',    'Crear nuevos usuarios',                  'Usuarios',      1, GETDATE(), 1),
    ('USR.EDITAR',   'Editar usuarios existentes',             'Usuarios',      1, GETDATE(), 1),
    ('USR.ELIMINAR', 'Desactivar usuarios',                    'Usuarios',      1, GETDATE(), 1),
    ('RPT.VER',      'Ver reportes y dashboards',              'Reportes',      1, GETDATE(), 1),
    ('RPT.EXPORTAR', 'Exportar reportes a PDF/Excel',          'Reportes',      1, GETDATE(), 1),
    ('AUD.BITACORA', 'Ver bitácoras de auditoría',             'Auditoria',     1, GETDATE(), 1),
    ('CONF.ROLES',   'Gestionar roles y permisos',             'Configuracion', 1, GETDATE(), 1),
    ('CONF.DEPTOS',  'Gestionar departamentos',                'Configuracion', 1, GETDATE(), 1);
END
GO

DECLARE @RolAdmin2   INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Administrador');
DECLARE @RolSuper2   INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Superior');
DECLARE @RolAuditor2 INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Auditor');

-- Administrador -> Todos
IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol_Permiso] WHERE IdRol = @RolAdmin2 AND IdPermiso = (SELECT Id FROM [dbo].[Permiso] WHERE Codigo='DOC.CREAR'))
    INSERT INTO [dbo].[Rol_Permiso] (IdRol, IdPermiso, Estatus, FechaCreacion, IdUsuarioCreacion)
    SELECT @RolAdmin2, Id, 1, GETDATE(), 1 FROM [dbo].[Permiso] WHERE Estatus = 1;

-- Superior -> Aprobar y ver
IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol_Permiso] WHERE IdRol = @RolSuper2 AND IdPermiso = (SELECT Id FROM [dbo].[Permiso] WHERE Codigo='DOC.APROBAR'))
    INSERT INTO [dbo].[Rol_Permiso] (IdRol, IdPermiso, Estatus, FechaCreacion, IdUsuarioCreacion)
    SELECT @RolSuper2, Id, 1, GETDATE(), 1 FROM [dbo].[Permiso] WHERE Codigo IN ('DOC.APROBAR','DOC.VER');

-- Auditor -> Leer, reportes y bitácoras
IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol_Permiso] WHERE IdRol = @RolAuditor2 AND IdPermiso = (SELECT Id FROM [dbo].[Permiso] WHERE Codigo='DOC.VER'))
    INSERT INTO [dbo].[Rol_Permiso] (IdRol, IdPermiso, Estatus, FechaCreacion, IdUsuarioCreacion)
    SELECT @RolAuditor2, Id, 1, GETDATE(), 1 FROM [dbo].[Permiso] WHERE Codigo IN ('DOC.VER','RPT.VER','RPT.EXPORTAR','AUD.BITACORA');
GO

-- ============================================================
-- SECCIÓN 8: DOCUMENTOS, VERSIONES Y FLUJOS DE APROBACIÓN
-- ============================================================
SET IDENTITY_INSERT [dbo].[Documento] ON;
GO

-- Documentos de TechCorp (Id 19 a 26)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 19)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (19, 'TC-MT-001', N'Manual de Configuración de Servidores Linux', 8, 'Vigente', 8, DATEADD(DAY,-85,GETDATE()), 1, 8, 12, 2);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 20)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (20, 'TC-PI-001', N'Política de Seguridad de la Información', 8, 'Vigente', 8, DATEADD(DAY,-70,GETDATE()), 1, 8, 13, 2);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 21)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (21, 'TC-PI-002', N'Política de Vacaciones y Permisos', 8, 'En Revisión', 8, DATEADD(DAY,-30,GETDATE()), 1, 8, 13, 2);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 22)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (22, 'TC-CON-001', N'Contrato de Servicios Cloud – Proveedor AWS', 8, 'Vigente', 8, DATEADD(DAY,-60,GETDATE()), 1, 8, 8, 2);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 23)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (23, 'TC-MT-002', N'Guía de Implementación de DevOps con GitLab CI/CD', 8, 'Borrador', 8, DATEADD(DAY,-10,GETDATE()), 1, 8, 12, 2);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 24)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (24, 'TC-LEG-001', N'Política de Protección de Datos Personales (LGPDP)', 8, 'Pendiente Firma', 8, DATEADD(DAY,-20,GETDATE()), 1, 8, 13, 2);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 25)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (25, 'TC-CON-002', N'Contrato Colectivo de Trabajo 2026', 8, 'Vigente', 8, DATEADD(DAY,-45,GETDATE()), 1, 8, 8, 2);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 26)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (26, 'TC-ADM-001', N'Manual de Procesos Administrativos v1.0', 8, 'Rechazado', 7, DATEADD(DAY,-50,GETDATE()), 1, 7, 12, 2);

-- Documentos de Grupo Innovar (Id 27 a 34)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 27)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (27, 'GI-RF-001', N'Reporte Financiero Q1 2026', 13, 'Vigente', 12, DATEADD(DAY,-80,GETDATE()), 1, 12, 9, 3);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 28)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (28, 'GI-RF-002', N'Reporte Financiero Q2 2026', 13, 'En Revisión', 12, DATEADD(DAY,-15,GETDATE()), 1, 12, 9, 3);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 29)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (29, 'GI-AR-001', N'Acta Reunión Consejo Directivo – Enero 2026', 13, 'Vigente', 11, DATEADD(DAY,-75,GETDATE()), 1, 11, 10, 3);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 30)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (30, 'GI-PO-001', N'Procedimiento de Control de Calidad en Línea', 13, 'Vigente', 12, DATEADD(DAY,-65,GETDATE()), 1, 12, 11, 3);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 31)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (31, 'GI-PO-002', N'Procedimiento de Gestión de Proveedores', 13, 'Borrador', 12, DATEADD(DAY,-8,GETDATE()), 1, 12, 11, 3);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 32)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (32, 'GI-AR-002', N'Acta Reunión Comercial – Plan de Ventas 2026', 13, 'Pendiente Firma', 12, DATEADD(DAY,-25,GETDATE()), 1, 12, 10, 3);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 33)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (33, 'GI-RF-003', N'Presupuesto Anual 2026 – Proyección vs Real', 13, 'Vigente', 12, DATEADD(DAY,-50,GETDATE()), 1, 12, 9, 3);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE Id = 34)
    INSERT INTO [dbo].[Documento] (Id, CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES (34, 'GI-PO-003', N'Procedimiento de Atención a Quejas y Reclamaciones', 13, 'Vigente', 12, DATEADD(DAY,-40,GETDATE()), 1, 12, 11, 3);
GO
SET IDENTITY_INSERT [dbo].[Documento] OFF;
GO

-- ============================================================
-- SECCIÓN 9: VERSIONES DE DOCUMENTOS
-- ============================================================
SET IDENTITY_INSERT [dbo].[Documento_Version] ON;
GO

-- Versiones TechCorp (Id 1 a 9)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 1)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (1, 19, 1, '/archivos/techcorp/TC-MT-001_v1.pdf', 'a1b2c3d4e5f6789012345678901234567890123456789012345678901234abcd', N'Versión inicial', 8, DATEADD(DAY,-85,GETDATE()), 1, 8, '.pdf', 'application/pdf', 1024000);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 2)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (2, 19, 2, '/archivos/techcorp/TC-MT-001_v2.pdf', 'b2c3d4e5f6789012345678901234567890123456789012345678901234abcde', N'Corrección de comandos de red sección 4', 8, DATEADD(DAY,-60,GETDATE()), 1, 8, '.pdf', 'application/pdf', 1048576);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 3)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (3, 20, 1, '/archivos/techcorp/TC-PI-001_v1.pdf', 'c3d4e5f6789012345678901234567890123456789012345678901234abcdef01', N'Publicación inicial', 8, DATEADD(DAY,-70,GETDATE()), 1, 8, '.pdf', 'application/pdf', 512000);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 4)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (4, 21, 1, '/archivos/techcorp/TC-PI-002_v1.docx', 'd4e5f6789012345678901234567890123456789012345678901234abcdef0102', N'Borrador revisión legal', 8, DATEADD(DAY,-30,GETDATE()), 1, 8, '.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 245760);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 5)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (5, 22, 1, '/archivos/techcorp/TC-CON-001_v1.pdf', 'e5f6789012345678901234567890123456789012345678901234abcdef010203', N'Contrato firmado y escaneado', 8, DATEADD(DAY,-60,GETDATE()), 1, 8, '.pdf', 'application/pdf', 2097152);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 6)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (6, 23, 1, '/archivos/techcorp/TC-MT-002_v1.md', 'f6789012345678901234567890123456789012345678901234abcdef01020304', N'Primer borrador', 8, DATEADD(DAY,-10,GETDATE()), 1, 8, '.md', 'text/markdown', 51200);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 7)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (7, 24, 1, '/archivos/techcorp/TC-LEG-001_v1.pdf', 'a6789012345678901234567890123456789012345678901234abcdef01020305', N'Versión final para firma', 8, DATEADD(DAY,-20,GETDATE()), 1, 8, '.pdf', 'application/pdf', 768000);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 8)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (8, 25, 1, '/archivos/techcorp/TC-CON-002_v1.pdf', 'b6789012345678901234567890123456789012345678901234abcdef01020306', N'Contrato colectivo 2026 firmado', 8, DATEADD(DAY,-45,GETDATE()), 1, 8, '.pdf', 'application/pdf', 3145728);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 9)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (9, 26, 1, '/archivos/techcorp/TC-ADM-001_v1.pdf', 'c6789012345678901234567890123456789012345678901234abcdef01020307', N'Primera versión para aprobación', 7, DATEADD(DAY,-50,GETDATE()), 1, 7, '.pdf', 'application/pdf', 409600);

-- Versiones Grupo Innovar (Id 10 a 18)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 10)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (10, 27, 1, '/archivos/innovar/GI-RF-001_v1.xlsx', 'a7891012345678901234567890123456789012345678901234abcdef01020308', N'Reporte Q1 definitivo', 12, DATEADD(DAY,-80,GETDATE()), 1, 12, '.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 2621440);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 11)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (11, 28, 1, '/archivos/innovar/GI-RF-002_v1.xlsx', 'b7891012345678901234567890123456789012345678901234abcdef01020309', N'Primer borrador Q2', 12, DATEADD(DAY,-15,GETDATE()), 1, 12, '.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 2883584);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 12)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (12, 29, 1, '/archivos/innovar/GI-AR-001_v1.pdf', 'c7891012345678901234567890123456789012345678901234abcdef01020310', N'Acta firmada en sesión', 11, DATEADD(DAY,-75,GETDATE()), 1, 11, '.pdf', 'application/pdf', 614400);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 13)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (13, 30, 1, '/archivos/innovar/GI-PO-001_v1.pdf', 'd7891012345678901234567890123456789012345678901234abcdef01020311', N'Procedimiento inicial', 12, DATEADD(DAY,-65,GETDATE()), 1, 12, '.pdf', 'application/pdf', 819200);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 14)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (14, 30, 2, '/archivos/innovar/GI-PO-001_v2.pdf', 'e7891012345678901234567890123456789012345678901234abcdef01020312', N'Ajuste de tolerancias según auditoría interna', 12, DATEADD(DAY,-40,GETDATE()), 1, 12, '.pdf', 'application/pdf', 860160);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 15)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (15, 31, 1, '/archivos/innovar/GI-PO-002_v1.docx', 'f7891012345678901234567890123456789012345678901234abcdef01020313', N'Borrador inicial', 12, DATEADD(DAY,-8,GETDATE()), 1, 12, '.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 163840);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 16)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (16, 32, 1, '/archivos/innovar/GI-AR-002_v1.pdf', 'a8891012345678901234567890123456789012345678901234abcdef01020314', N'Acta de reunión comercial', 12, DATEADD(DAY,-25,GETDATE()), 1, 12, '.pdf', 'application/pdf', 307200);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 17)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (17, 33, 1, '/archivos/innovar/GI-RF-003_v1.xlsx', 'b8891012345678901234567890123456789012345678901234abcdef01020315', N'Proyección anual vs. gastos reales', 12, DATEADD(DAY,-50,GETDATE()), 1, 12, '.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 3670016);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE Id = 18)
    INSERT INTO [dbo].[Documento_Version] (Id, IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (18, 34, 1, '/archivos/innovar/GI-PO-003_v1.pdf', 'c8891012345678901234567890123456789012345678901234abcdef01020316', N'Procedimiento de atención al cliente', 12, DATEADD(DAY,-40,GETDATE()), 1, 12, '.pdf', 'application/pdf', 512000);
GO
SET IDENTITY_INSERT [dbo].[Documento_Version] OFF;
GO

-- ============================================================
-- SECCIÓN 10: FLUJOS DE APROBACIÓN
-- ============================================================
-- TechCorp (IdVersionDocumento 2, 3, 4, 7, 9)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 2)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES
    (2, 10, 'Revisión', 'Aprobado', 1, N'Revisado. Comandos verificados en entorno de prueba.', DATEADD(DAY,-55,GETDATE()), 1, DATEADD(DAY,-60,GETDATE()), 8, 'TKN-TC-MT001-V2-01', 'Contraseña'),
    (2, 10, 'Aprobación', 'Aprobado', 2, N'Aprobado para publicación.', DATEADD(DAY,-53,GETDATE()), 1, DATEADD(DAY,-60,GETDATE()), 8, 'TKN-TC-MT001-V2-02', 'Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 3)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES
    (3, 10, 'Revisión', 'Aprobado', 1, N'Política revisada y alineada con ISO 27001.', DATEADD(DAY,-65,GETDATE()), 1, DATEADD(DAY,-70,GETDATE()), 8, 'TKN-TC-PI001-V1-01', 'Contraseña'),
    (3, 10, 'Aprobación', 'Aprobado', 2, N'Aprobada por Dirección.', DATEADD(DAY,-63,GETDATE()), 1, DATEADD(DAY,-70,GETDATE()), 8, 'TKN-TC-PI001-V1-02', 'Contraseña'),
    (3, 7, 'Firma', 'Aprobado', 3, N'Firmado digitalmente por el Administrador.', DATEADD(DAY,-62,GETDATE()), 1, DATEADD(DAY,-70,GETDATE()), 8, 'TKN-TC-PI001-V1-03', 'Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 4)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Estatus, FechaCreacion, IdUsuarioCreacion)
    VALUES
    (4, 10, 'Revisión', 'Pendiente', 1, 1, DATEADD(DAY,-30,GETDATE()), 8),
    (4, 10, 'Aprobación', 'Pendiente', 2, 1, DATEADD(DAY,-30,GETDATE()), 8);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 7)
BEGIN
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES (7, 10, 'Revisión', 'Aprobado', 1, N'Política revisada por asesor legal.', DATEADD(DAY,-18,GETDATE()), 1, DATEADD(DAY,-20,GETDATE()), 8, 'TKN-TC-LEG001-V1-01', 'Contraseña');
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Estatus, FechaCreacion, IdUsuarioCreacion)
    VALUES (7, 7, 'Firma', 'Pendiente', 2, 1, DATEADD(DAY,-20,GETDATE()), 8);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 9)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES (9, 10, 'Revisión', 'Rechazado', 1, N'No sigue formato corporativo. Requiere revisión completa.', DATEADD(DAY,-45,GETDATE()), 1, DATEADD(DAY,-50,GETDATE()), 7, 'TKN-TC-ADM001-V1-01', 'Contraseña');

-- Grupo Innovar (IdVersionDocumento 10, 11, 12, 14, 16, 18)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 10)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES
    (10, 14, 'Revisión', 'Aprobado', 1, N'Cifras verificadas contra estados de cuenta bancarios.', DATEADD(DAY,-75,GETDATE()), 1, DATEADD(DAY,-80,GETDATE()), 12, 'TKN-GI-RF001-V1-01', 'Contraseña'),
    (10, 11, 'Aprobación', 'Aprobado', 2, N'Reporte Q1 aprobado para distribución.', DATEADD(DAY,-74,GETDATE()), 1, DATEADD(DAY,-80,GETDATE()), 12, 'TKN-GI-RF001-V1-02', 'Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 11)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Estatus, FechaCreacion, IdUsuarioCreacion)
    VALUES (11, 14, 'Revisión', 'Pendiente', 1, 1, DATEADD(DAY,-15,GETDATE()), 12);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 12)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES (12, 11, 'Firma', 'Aprobado', 1, N'Acta firmada en sesión por Consejo.', DATEADD(DAY,-73,GETDATE()), 1, DATEADD(DAY,-75,GETDATE()), 11, 'TKN-GI-AR001-V1-01', 'Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 14)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES
    (14, 14, 'Revisión', 'Aprobado', 1, N'Tolerancias verificadas con auditor externo.', DATEADD(DAY,-37,GETDATE()), 1, DATEADD(DAY,-40,GETDATE()), 12, 'TKN-GI-PO001-V2-01', 'Contraseña'),
    (14, 11, 'Aprobación', 'Aprobado', 2, N'Procedimiento actualizado aprobado.', DATEADD(DAY,-35,GETDATE()), 1, DATEADD(DAY,-40,GETDATE()), 12, 'TKN-GI-PO001-V2-02', 'Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 16)
BEGIN
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES (16, 14, 'Revisión', 'Aprobado', 1, N'Plan de ventas revisado y validado.', DATEADD(DAY,-23,GETDATE()), 1, DATEADD(DAY,-25,GETDATE()), 12, 'TKN-GI-AR002-V1-01', 'Contraseña');
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Estatus, FechaCreacion, IdUsuarioCreacion)
    VALUES (16, 11, 'Firma', 'Pendiente', 2, 1, DATEADD(DAY,-25,GETDATE()), 12);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento = 18)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES
    (18, 14, 'Revisión', 'Aprobado', 1, N'Procedimiento revisado.', DATEADD(DAY,-37,GETDATE()), 1, DATEADD(DAY,-40,GETDATE()), 12, 'TKN-GI-PO003-V1-01', 'Contraseña'),
    (18, 11, 'Aprobación', 'Aprobado', 2, N'Aprobado por Dirección.', DATEADD(DAY,-35,GETDATE()), 1, DATEADD(DAY,-40,GETDATE()), 12, 'TKN-GI-PO003-V1-02', 'Contraseña');
GO

-- ============================================================
-- RESUMEN FINAL
-- ============================================================
PRINT '========================================';
PRINT '  SEED REFACTORIZADO COMPLETADO';
PRINT '----------------------------------------';
PRINT '  SUPERADMIN   : admin@sigd.local        / Admin@SIGD2026!';
PRINT '----------------------------------------';
PRINT '  EMPRESA 1: TechCorp Solutions';
PRINT '  Admin   : admin.tech@techcorp.local    / Test@2026!';
PRINT '  Usuario : user.tech@techcorp.local     / Test@2026!';
PRINT '  Auditor : auditor.tech@techcorp.local  / Test@2026!';
PRINT '  Superior: superior.tech@techcorp.local / Test@2026!';
PRINT '----------------------------------------';
PRINT '  EMPRESA 2: Grupo Innovar';
PRINT '  Admin   : admin@grupoinnovar.local     / Test@2026!';
PRINT '  Usuario : user@grupoinnovar.local      / Test@2026!';
PRINT '  Auditor : auditor@grupoinnovar.local   / Test@2026!';
PRINT '  Superior: superior@grupoinnovar.local  / Test@2026!';
PRINT '========================================';