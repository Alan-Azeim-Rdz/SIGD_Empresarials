USE [SIGD_Central];
GO
SET NOCOUNT ON;

-- ==========================================================================================
-- SEED CONSOLIDADO: EMPRESAS, USUARIOS Y DATOS DE DEMOSTRACIÓN
-- Incluye: Empresas TechCorp y Grupo Innovar, sus usuarios, tipos de documento,
--          documentos ficticios, versiones y flujos de aprobación.
-- Idempotente: todos los INSERT usan IF NOT EXISTS / SET IDENTITY_INSERT.
-- ==========================================================================================

PRINT '========================================';
PRINT '  INICIANDO SEED CONSOLIDADO';
PRINT '========================================';

-- ============================================================
-- SECCIÓN 1: ROLES GLOBALES
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol] WHERE Nombre = 'Administrador' AND Estatus = 1)
BEGIN
    INSERT INTO [dbo].[Rol] (Nombre, Descripcion, IdUsuarioCreacion, FechaCreacion, Estatus)
    VALUES (N'Administrador', N'Administrador de la empresa. Gestiona usuarios, roles, departamentos y documentos.', 1, GETDATE(), 1);
    PRINT '  ✓ Rol Administrador creado.';
END ELSE PRINT '  → Rol Administrador ya existe.';

IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol] WHERE Nombre = 'Usuario' AND Estatus = 1)
BEGIN
    INSERT INTO [dbo].[Rol] (Nombre, Descripcion, IdUsuarioCreacion, FechaCreacion, Estatus)
    VALUES (N'Usuario', N'Usuario de área. Permisos de consulta y creación de borradores.', 1, GETDATE(), 1);
    PRINT '  ✓ Rol Usuario creado.';
END ELSE PRINT '  → Rol Usuario ya existe.';

IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol] WHERE Nombre = 'Auditor' AND Estatus = 1)
BEGIN
    INSERT INTO [dbo].[Rol] (Nombre, Descripcion, IdUsuarioCreacion, FechaCreacion, Estatus)
    VALUES (N'Auditor', N'Solo lectura global dentro de su empresa.', 1, GETDATE(), 1);
    PRINT '  ✓ Rol Auditor creado.';
END ELSE PRINT '  → Rol Auditor ya existe.';

IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol] WHERE Nombre = 'Superior')
BEGIN
    INSERT INTO [dbo].[Rol] (Nombre, Descripcion, Estatus, FechaCreacion, IdUsuarioCreacion)
    VALUES (N'Superior', N'Permite autorizar flujos de aprobación.', 1, GETDATE(), 1);
    PRINT '  ✓ Rol Superior creado.';
END ELSE PRINT '  → Rol Superior ya existe.';
GO


-- ============================================================
-- SECCIÓN 2: USUARIOS DE LA EMPRESA DEMO (Id=1)
-- ============================================================

DECLARE @EmpDemo INT = 1;
DECLARE @DptoDemo INT = 1;

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'admin.demo@sigd.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DptoDemo, @EmpDemo, N'Admin', N'Demo', N'SIGD', N'admin.demo@sigd.local',
            CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Admin@SIGD2026!')), 2),
            GETDATE(), 1, 1);

    DECLARE @AdminDemoId INT = SCOPE_IDENTITY();
    DECLARE @RolAdminIdDemo INT = (SELECT TOP 1 Id FROM [dbo].[Rol] WHERE Nombre = 'Administrador' AND Estatus = 1);
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@AdminDemoId, @RolAdminIdDemo, GETDATE(), GETDATE(), 1, 1);
    PRINT '  ✓ admin.demo@sigd.local creado.';
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'user.demo@sigd.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DptoDemo, @EmpDemo, N'Usuario', N'Demo', N'SIGD', N'user.demo@sigd.local',
            CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Admin@SIGD2026!')), 2),
            GETDATE(), 1, 1);

    DECLARE @UserDemoId INT = SCOPE_IDENTITY();
    DECLARE @RolUserIdDemo INT = (SELECT TOP 1 Id FROM [dbo].[Rol] WHERE Nombre = 'Usuario' AND Estatus = 1);
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@UserDemoId, @RolUserIdDemo, GETDATE(), GETDATE(), 1, 1);
    PRINT '  ✓ user.demo@sigd.local creado.';
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'auditor.demo@sigd.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DptoDemo, @EmpDemo, N'Auditor', N'Demo', N'SIGD', N'auditor.demo@sigd.local',
            CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Admin@SIGD2026!')), 2),
            GETDATE(), 1, 1);

    DECLARE @AuditorDemoId INT = SCOPE_IDENTITY();
    DECLARE @RolAuditorIdDemo INT = (SELECT TOP 1 Id FROM [dbo].[Rol] WHERE Nombre = 'Auditor' AND Estatus = 1);
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@AuditorDemoId, @RolAuditorIdDemo, GETDATE(), GETDATE(), 1, 1);
    PRINT '  ✓ auditor.demo@sigd.local creado.';
END
GO


-- ============================================================
-- SECCIÓN 3: EMPRESA 1 — TechCorp Solutions
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[Empresa] WHERE Slug = 'techcorp')
BEGIN
    INSERT INTO [dbo].[Empresa] (Nombre, Slug, RFC, CorreoContacto, FechaRegistro, Estatus)
    VALUES (N'TechCorp Solutions', N'techcorp', N'TCS123456789', N'contacto@techcorp.local', GETDATE(), 1);
    PRINT '  ✓ Empresa TechCorp Solutions creada.';
END ELSE PRINT '  → Empresa TechCorp ya existe.';
GO

-- Departamentos TechCorp
DECLARE @EmpTech INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'techcorp');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Nombre = 'Administración' AND IdEmpresa = @EmpTech)
    INSERT INTO [dbo].[Departamento] (Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (N'Administración', N'ADM', 1, GETDATE(), @EmpTech, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Nombre = 'Tecnología de Información' AND IdEmpresa = @EmpTech)
    INSERT INTO [dbo].[Departamento] (Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (N'Tecnología de Información', N'TI', 1, GETDATE(), @EmpTech, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Nombre = 'Recursos Humanos' AND IdEmpresa = @EmpTech)
    INSERT INTO [dbo].[Departamento] (Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (N'Recursos Humanos', N'RRHH', 1, GETDATE(), @EmpTech, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Nombre = 'Legal y Cumplimiento' AND IdEmpresa = @EmpTech)
    INSERT INTO [dbo].[Departamento] (Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (N'Legal y Cumplimiento', N'LEG', 1, GETDATE(), @EmpTech, 1);
GO

-- Tipos de documento TechCorp
DECLARE @EmpTech INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'techcorp');
IF NOT EXISTS (SELECT 1 FROM [dbo].[TipoDocumento] WHERE Nombre = 'Manual Técnico' AND IdEmpresa = @EmpTech)
    INSERT INTO [dbo].[TipoDocumento] (Nombre, Abreviatura, TiempoRetencionMeses, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES
    (N'Manual Técnico',  N'MT',  60, 1, GETDATE(), @EmpTech, 1),
    (N'Política Interna',N'PI',  36, 1, GETDATE(), @EmpTech, 1),
    (N'Contrato',        N'CON', 84, 1, GETDATE(), @EmpTech, 1);
GO

-- Admin TechCorp: admin.tech@techcorp.local | Admin@Tech2026!
DECLARE @EmpTech  INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'techcorp');
DECLARE @DptoTech INT = (SELECT TOP 1 Id FROM [dbo].[Departamento] WHERE Nombre = 'Administración' AND IdEmpresa = @EmpTech);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'admin.tech@techcorp.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DptoTech, @EmpTech, N'Ana', N'García', N'Martínez', N'admin.tech@techcorp.local',
            CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Admin@Tech2026!')), 2),
            GETDATE(), 1, 1);

    DECLARE @AdminTechId INT = SCOPE_IDENTITY();
    DECLARE @RolAdminId  INT = (SELECT TOP 1 Id FROM [dbo].[Rol] WHERE Nombre = 'Administrador' AND Estatus = 1);
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@AdminTechId, @RolAdminId, GETDATE(), GETDATE(), 1, 1);
    UPDATE [dbo].[Departamento] SET IdUsuarioCreacion = @AdminTechId WHERE IdEmpresa = @EmpTech AND IdUsuarioCreacion = 1;
    PRINT '  ✓ admin.tech@techcorp.local creado.';
END

-- Usuario y Auditor TechCorp
IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'user.tech@techcorp.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DptoTech, @EmpTech, N'Usuario', N'Demo', N'Tech', N'user.tech@techcorp.local',
            CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Admin@Tech2026!')), 2),
            GETDATE(), 1, 1);
    DECLARE @UserTechId INT = SCOPE_IDENTITY();
    DECLARE @RolUserId  INT = (SELECT TOP 1 Id FROM [dbo].[Rol] WHERE Nombre = 'Usuario' AND Estatus = 1);
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@UserTechId, @RolUserId, GETDATE(), GETDATE(), 1, 1);
    PRINT '  ✓ user.tech@techcorp.local creado.';
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'auditor.tech@techcorp.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DptoTech, @EmpTech, N'Auditor', N'Demo', N'Tech', N'auditor.tech@techcorp.local',
            CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Admin@Tech2026!')), 2),
            GETDATE(), 1, 1);
    DECLARE @AuditorTechId INT = SCOPE_IDENTITY();
    DECLARE @RolAuditorId  INT = (SELECT TOP 1 Id FROM [dbo].[Rol] WHERE Nombre = 'Auditor' AND Estatus = 1);
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@AuditorTechId, @RolAuditorId, GETDATE(), GETDATE(), 1, 1);
    PRINT '  ✓ auditor.tech@techcorp.local creado.';
END
GO


-- ============================================================
-- SECCIÓN 4: EMPRESA 2 — Grupo Innovar
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[Empresa] WHERE Slug = 'grupoinnovar')
BEGIN
    INSERT INTO [dbo].[Empresa] (Nombre, Slug, RFC, CorreoContacto, FechaRegistro, Estatus)
    VALUES (N'Grupo Innovar', N'grupoinnovar', N'GIN654321XYZ', N'info@grupoinnovar.local', GETDATE(), 1);
    PRINT '  ✓ Empresa Grupo Innovar creada.';
END ELSE PRINT '  → Empresa Grupo Innovar ya existe.';
GO

-- Departamentos Grupo Innovar
DECLARE @EmpInnov INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'grupoinnovar');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Nombre = 'Administración' AND IdEmpresa = @EmpInnov)
    INSERT INTO [dbo].[Departamento] (Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (N'Administración', N'ADM', 1, GETDATE(), @EmpInnov, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Nombre = 'Finanzas' AND IdEmpresa = @EmpInnov)
    INSERT INTO [dbo].[Departamento] (Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (N'Finanzas', N'FIN', 1, GETDATE(), @EmpInnov, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Nombre = 'Operaciones' AND IdEmpresa = @EmpInnov)
    INSERT INTO [dbo].[Departamento] (Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (N'Operaciones', N'OPS', 1, GETDATE(), @EmpInnov, 1);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Departamento] WHERE Nombre = 'Comercial' AND IdEmpresa = @EmpInnov)
    INSERT INTO [dbo].[Departamento] (Nombre, Abreviatura, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES (N'Comercial', N'COM', 1, GETDATE(), @EmpInnov, 1);
GO

-- Tipos de documento Grupo Innovar
DECLARE @EmpInnov INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'grupoinnovar');
IF NOT EXISTS (SELECT 1 FROM [dbo].[TipoDocumento] WHERE Nombre = 'Reporte Financiero' AND IdEmpresa = @EmpInnov)
    INSERT INTO [dbo].[TipoDocumento] (Nombre, Abreviatura, TiempoRetencionMeses, Estatus, FechaCreacion, IdEmpresa, IdUsuarioCreacion)
    VALUES
    (N'Reporte Financiero',      N'RF', 60, 1, GETDATE(), @EmpInnov, 1),
    (N'Acta de Reunión',         N'AR', 24, 1, GETDATE(), @EmpInnov, 1),
    (N'Procedimiento Operativo', N'PO', 48, 1, GETDATE(), @EmpInnov, 1);
GO

-- Admin Grupo Innovar: admin@grupoinnovar.local | Admin@Innov2026!
DECLARE @EmpInnov   INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'grupoinnovar');
DECLARE @DptoInnov  INT = (SELECT TOP 1 Id FROM [dbo].[Departamento] WHERE Nombre = 'Administración' AND IdEmpresa = @EmpInnov);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'admin@grupoinnovar.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DptoInnov, @EmpInnov, N'Carlos', N'López', N'Hernández', N'admin@grupoinnovar.local',
            CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Admin@Innov2026!')), 2),
            GETDATE(), 1, 1);

    DECLARE @AdminInnovId INT = SCOPE_IDENTITY();
    DECLARE @RolAdminId2  INT = (SELECT TOP 1 Id FROM [dbo].[Rol] WHERE Nombre = 'Administrador' AND Estatus = 1);
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@AdminInnovId, @RolAdminId2, GETDATE(), GETDATE(), 1, 1);
    UPDATE [dbo].[Departamento] SET IdUsuarioCreacion = @AdminInnovId WHERE IdEmpresa = @EmpInnov AND IdUsuarioCreacion = 1;
    PRINT '  ✓ admin@grupoinnovar.local creado.';
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'user@grupoinnovar.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DptoInnov, @EmpInnov, N'Usuario', N'Demo', N'Innovar', N'user@grupoinnovar.local',
            CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Admin@Innov2026!')), 2),
            GETDATE(), 1, 1);
    DECLARE @UserInnovId INT = SCOPE_IDENTITY();
    DECLARE @RolUserId2  INT = (SELECT TOP 1 Id FROM [dbo].[Rol] WHERE Nombre = 'Usuario' AND Estatus = 1);
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@UserInnovId, @RolUserId2, GETDATE(), GETDATE(), 1, 1);
    PRINT '  ✓ user@grupoinnovar.local creado.';
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'auditor@grupoinnovar.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DptoInnov, @EmpInnov, N'Auditor', N'Demo', N'Innovar', N'auditor@grupoinnovar.local',
            CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Admin@Innov2026!')), 2),
            GETDATE(), 1, 1);
    DECLARE @AuditorInnovId INT = SCOPE_IDENTITY();
    DECLARE @RolAuditorId2  INT = (SELECT TOP 1 Id FROM [dbo].[Rol] WHERE Nombre = 'Auditor' AND Estatus = 1);
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@AuditorInnovId, @RolAuditorId2, GETDATE(), GETDATE(), 1, 1);
    PRINT '  ✓ auditor@grupoinnovar.local creado.';
END
GO


-- ============================================================
-- SECCIÓN 5: USUARIOS DE DEMOSTRACIÓN ADICIONALES (TechCorp)
-- ============================================================

DECLARE @EmpTech    INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'techcorp');
DECLARE @DTITech    INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Tecnología de Información' AND IdEmpresa = @EmpTech);
DECLARE @DRRHHTech  INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Recursos Humanos'           AND IdEmpresa = @EmpTech);
DECLARE @DLegalTech INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Legal y Cumplimiento'       AND IdEmpresa = @EmpTech);
DECLARE @AdminTech  INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'admin.tech@techcorp.local');
DECLARE @PwdTest    VARCHAR(255) = CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Test@2026!')), 2);
DECLARE @RolUser    INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Usuario');
DECLARE @RolSuper   INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Superior');
DECLARE @RolAuditor INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Auditor');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'marco.torres@techcorp.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DTITech, @EmpTech, N'Marco', N'Torres', N'Ríos', N'marco.torres@techcorp.local', @PwdTest, DATEADD(DAY,-90,GETDATE()), 1, @AdminTech);
    DECLARE @u1 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@u1, @RolUser, DATEADD(DAY,-90,GETDATE()), DATEADD(DAY,-90,GETDATE()), 1, @AdminTech);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'sofia.ramos@techcorp.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DTITech, @EmpTech, N'Sofía', N'Ramos', N'Gutiérrez', N'sofia.ramos@techcorp.local', @PwdTest, DATEADD(DAY,-80,GETDATE()), 1, @AdminTech);
    DECLARE @u2 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@u2, @RolSuper, DATEADD(DAY,-80,GETDATE()), DATEADD(DAY,-80,GETDATE()), 1, @AdminTech);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'lucia.mendoza@techcorp.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DRRHHTech, @EmpTech, N'Lucía', N'Mendoza', N'Salinas', N'lucia.mendoza@techcorp.local', @PwdTest, DATEADD(DAY,-75,GETDATE()), 1, @AdminTech);
    DECLARE @u3 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@u3, @RolUser, DATEADD(DAY,-75,GETDATE()), DATEADD(DAY,-75,GETDATE()), 1, @AdminTech);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'jorge.vargas@techcorp.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DLegalTech, @EmpTech, N'Jorge', N'Vargas', N'Peña', N'jorge.vargas@techcorp.local', @PwdTest, DATEADD(DAY,-60,GETDATE()), 1, @AdminTech);
    DECLARE @u4 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@u4, @RolAuditor, DATEADD(DAY,-60,GETDATE()), DATEADD(DAY,-60,GETDATE()), 1, @AdminTech);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'diana.flores@techcorp.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DLegalTech, @EmpTech, N'Diana', N'Flores', N'Castillo', N'diana.flores@techcorp.local', @PwdTest, DATEADD(DAY,-55,GETDATE()), 1, @AdminTech);
    DECLARE @u5 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@u5, @RolUser, DATEADD(DAY,-55,GETDATE()), DATEADD(DAY,-55,GETDATE()), 1, @AdminTech);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'raul.suarez@techcorp.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DRRHHTech, @EmpTech, N'Raúl', N'Suárez', N'López', N'raul.suarez@techcorp.local', @PwdTest, DATEADD(DAY,-50,GETDATE()), 1, @AdminTech);
    DECLARE @u6 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@u6, @RolSuper, DATEADD(DAY,-50,GETDATE()), DATEADD(DAY,-50,GETDATE()), 1, @AdminTech);
END

PRINT '  ✓ Usuarios adicionales TechCorp creados.';
GO


-- ============================================================
-- SECCIÓN 6: USUARIOS DE DEMOSTRACIÓN ADICIONALES (Grupo Innovar)
-- ============================================================

DECLARE @EmpInnov   INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'grupoinnovar');
DECLARE @DFinInnov  INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Finanzas'     AND IdEmpresa = @EmpInnov);
DECLARE @DOpsInnov  INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Operaciones'  AND IdEmpresa = @EmpInnov);
DECLARE @DAdmInnov  INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Administración' AND IdEmpresa = @EmpInnov);
DECLARE @DCompInnov INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Comercial'    AND IdEmpresa = @EmpInnov);
DECLARE @AdminInnov INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'admin@grupoinnovar.local');
DECLARE @PwdTest    VARCHAR(255) = CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', CONVERT(VARBINARY, N'Test@2026!')), 2);
DECLARE @RolUser    INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Usuario');
DECLARE @RolSuper   INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Superior');
DECLARE @RolAuditor INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Auditor');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'patricia.luna@grupoinnovar.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DFinInnov, @EmpInnov, N'Patricia', N'Luna', N'Ortega', N'patricia.luna@grupoinnovar.local', @PwdTest, DATEADD(DAY,-85,GETDATE()), 1, @AdminInnov);
    DECLARE @v1 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@v1, @RolUser, DATEADD(DAY,-85,GETDATE()), DATEADD(DAY,-85,GETDATE()), 1, @AdminInnov);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'ernesto.medina@grupoinnovar.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DFinInnov, @EmpInnov, N'Ernesto', N'Medina', N'Reyes', N'ernesto.medina@grupoinnovar.local', @PwdTest, DATEADD(DAY,-70,GETDATE()), 1, @AdminInnov);
    DECLARE @v2 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@v2, @RolSuper, DATEADD(DAY,-70,GETDATE()), DATEADD(DAY,-70,GETDATE()), 1, @AdminInnov);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'isabel.cano@grupoinnovar.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DOpsInnov, @EmpInnov, N'Isabel', N'Cano', N'Jiménez', N'isabel.cano@grupoinnovar.local', @PwdTest, DATEADD(DAY,-65,GETDATE()), 1, @AdminInnov);
    DECLARE @v3 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@v3, @RolUser, DATEADD(DAY,-65,GETDATE()), DATEADD(DAY,-65,GETDATE()), 1, @AdminInnov);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'roberto.solis@grupoinnovar.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DAdmInnov, @EmpInnov, N'Roberto', N'Solís', N'Vega', N'roberto.solis@grupoinnovar.local', @PwdTest, DATEADD(DAY,-60,GETDATE()), 1, @AdminInnov);
    DECLARE @v4 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@v4, @RolAuditor, DATEADD(DAY,-60,GETDATE()), DATEADD(DAY,-60,GETDATE()), 1, @AdminInnov);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'elena.ruiz@grupoinnovar.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DCompInnov, @EmpInnov, N'Elena', N'Ruiz', N'Navarro', N'elena.ruiz@grupoinnovar.local', @PwdTest, DATEADD(DAY,-45,GETDATE()), 1, @AdminInnov);
    DECLARE @v5 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@v5, @RolUser, DATEADD(DAY,-45,GETDATE()), DATEADD(DAY,-45,GETDATE()), 1, @AdminInnov);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuario] WHERE Correo = 'miguel.rojas@grupoinnovar.local')
BEGIN
    INSERT INTO [dbo].[Usuario] (IdDepartamento, IdEmpresa, Nombre, ApellidoP, ApellidoM, Correo, Contrasena, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@DOpsInnov, @EmpInnov, N'Miguel', N'Rojas', N'Paredes', N'miguel.rojas@grupoinnovar.local', @PwdTest, DATEADD(DAY,-40,GETDATE()), 1, @AdminInnov);
    DECLARE @v6 INT = SCOPE_IDENTITY();
    INSERT INTO [dbo].[Usuario_Rol] (IdUsuario, IdRol, FechaAsignacion, FechaCreacion, Estatus, IdUsuarioCreacion)
    VALUES (@v6, @RolSuper, DATEADD(DAY,-40,GETDATE()), DATEADD(DAY,-40,GETDATE()), 1, @AdminInnov);
END

PRINT '  ✓ Usuarios adicionales Grupo Innovar creados.';
GO


-- ============================================================
-- SECCIÓN 7: PERMISOS DEL SISTEMA (evita duplicados)
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
    PRINT '  ✓ Permisos del sistema creados.';
END ELSE PRINT '  → Permisos ya existen, se omiten.';
GO

-- Asignar permisos al rol Administrador (todos), Superior (aprobar+ver), Auditor (ver+reportes+bitácora)
DECLARE @RolAdmin   INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Administrador');
DECLARE @RolSuper   INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Superior');
DECLARE @RolAuditor INT = (SELECT Id FROM [dbo].[Rol] WHERE Nombre = 'Auditor');

-- Admin → todos
IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol_Permiso] WHERE IdRol = @RolAdmin AND IdPermiso = (SELECT Id FROM [dbo].[Permiso] WHERE Codigo='DOC.CREAR'))
BEGIN
    INSERT INTO [dbo].[Rol_Permiso] (IdRol, IdPermiso, Estatus, FechaCreacion, IdUsuarioCreacion)
    SELECT @RolAdmin, Id, 1, GETDATE(), 1 FROM [dbo].[Permiso] WHERE Estatus = 1;
    PRINT '  ✓ Todos los permisos asignados al rol Administrador.';
END

-- Superior → aprobar y ver
IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol_Permiso] WHERE IdRol = @RolSuper AND IdPermiso = (SELECT Id FROM [dbo].[Permiso] WHERE Codigo='DOC.APROBAR'))
BEGIN
    INSERT INTO [dbo].[Rol_Permiso] (IdRol, IdPermiso, Estatus, FechaCreacion, IdUsuarioCreacion)
    SELECT @RolSuper, Id, 1, GETDATE(), 1 FROM [dbo].[Permiso] WHERE Codigo IN ('DOC.APROBAR','DOC.VER');
    PRINT '  ✓ Permisos asignados al rol Superior.';
END

-- Auditor → leer y reportes
IF NOT EXISTS (SELECT 1 FROM [dbo].[Rol_Permiso] WHERE IdRol = @RolAuditor AND IdPermiso = (SELECT Id FROM [dbo].[Permiso] WHERE Codigo='DOC.VER'))
BEGIN
    INSERT INTO [dbo].[Rol_Permiso] (IdRol, IdPermiso, Estatus, FechaCreacion, IdUsuarioCreacion)
    SELECT @RolAuditor, Id, 1, GETDATE(), 1 FROM [dbo].[Permiso] WHERE Codigo IN ('DOC.VER','RPT.VER','RPT.EXPORTAR','AUD.BITACORA');
    PRINT '  ✓ Permisos asignados al rol Auditor.';
END
GO


-- ============================================================
-- SECCIÓN 8: DOCUMENTOS, VERSIONES Y FLUJOS DE APROBACIÓN
-- TechCorp (8 docs) + Grupo Innovar (8 docs) con versiones y flujos
-- ============================================================

-- Referencias para TechCorp
DECLARE @EmpTech    INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'techcorp');
DECLARE @DTITech    INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Tecnología de Información' AND IdEmpresa = @EmpTech);
DECLARE @DRRHHTech  INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Recursos Humanos'           AND IdEmpresa = @EmpTech);
DECLARE @DLegalTech INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Legal y Cumplimiento'       AND IdEmpresa = @EmpTech);
DECLARE @DAdmTech   INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Administración'             AND IdEmpresa = @EmpTech);
DECLARE @TMTech     INT = (SELECT Id FROM [dbo].[TipoDocumento] WHERE Nombre = 'Manual Técnico'    AND IdEmpresa = @EmpTech);
DECLARE @TPITech    INT = (SELECT Id FROM [dbo].[TipoDocumento] WHERE Nombre = 'Política Interna'  AND IdEmpresa = @EmpTech);
DECLARE @TConTech   INT = (SELECT Id FROM [dbo].[TipoDocumento] WHERE Nombre = 'Contrato'          AND IdEmpresa = @EmpTech);
DECLARE @AdminTech  INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'admin.tech@techcorp.local');
DECLARE @uMarco     INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'marco.torres@techcorp.local');
DECLARE @uSofia     INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'sofia.ramos@techcorp.local');
DECLARE @uLucia     INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'lucia.mendoza@techcorp.local');
DECLARE @uDiana     INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'diana.flores@techcorp.local');
DECLARE @uRaul      INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'raul.suarez@techcorp.local');

-- Documentos TechCorp
IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno = 'TC-MT-001')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('TC-MT-001', N'Manual de Configuración de Servidores Linux', @DTITech, 'Vigente', @uMarco, DATEADD(DAY,-85,GETDATE()), 1, @uMarco, @TMTech, @EmpTech);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno = 'TC-PI-001')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('TC-PI-001', N'Política de Seguridad de la Información', @DTITech, 'Vigente', @uMarco, DATEADD(DAY,-70,GETDATE()), 1, @uMarco, @TPITech, @EmpTech);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno = 'TC-PI-002')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('TC-PI-002', N'Política de Vacaciones y Permisos', @DRRHHTech, 'En Revisión', @uLucia, DATEADD(DAY,-30,GETDATE()), 1, @uLucia, @TPITech, @EmpTech);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno = 'TC-CON-001')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('TC-CON-001', N'Contrato de Servicios Cloud – Proveedor AWS', @DLegalTech, 'Vigente', @uDiana, DATEADD(DAY,-60,GETDATE()), 1, @uDiana, @TConTech, @EmpTech);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno = 'TC-MT-002')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('TC-MT-002', N'Guía de Implementación de DevOps con GitLab CI/CD', @DTITech, 'Borrador', @uMarco, DATEADD(DAY,-10,GETDATE()), 1, @uMarco, @TMTech, @EmpTech);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno = 'TC-LEG-001')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('TC-LEG-001', N'Política de Protección de Datos Personales (LGPDP)', @DLegalTech, 'Pendiente Firma', @uDiana, DATEADD(DAY,-20,GETDATE()), 1, @uDiana, @TPITech, @EmpTech);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno = 'TC-CON-002')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('TC-CON-002', N'Contrato Colectivo de Trabajo 2026', @DRRHHTech, 'Vigente', @uLucia, DATEADD(DAY,-45,GETDATE()), 1, @uLucia, @TConTech, @EmpTech);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno = 'TC-ADM-001')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('TC-ADM-001', N'Manual de Procesos Administrativos v1.0', @DAdmTech, 'Rechazado', @AdminTech, DATEADD(DAY,-50,GETDATE()), 1, @AdminTech, @TMTech, @EmpTech);

PRINT '  ✓ Documentos TechCorp insertados.';
GO

-- Versiones TechCorp
DECLARE @dT1 INT = (SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-MT-001');
DECLARE @dT2 INT = (SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-PI-001');
DECLARE @dT3 INT = (SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-PI-002');
DECLARE @dT4 INT = (SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-CON-001');
DECLARE @dT5 INT = (SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-MT-002');
DECLARE @dT6 INT = (SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-LEG-001');
DECLARE @dT7 INT = (SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-CON-002');
DECLARE @dT8 INT = (SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-ADM-001');
DECLARE @uMarco INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='marco.torres@techcorp.local');
DECLARE @uSofia INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='sofia.ramos@techcorp.local');
DECLARE @uLucia INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='lucia.mendoza@techcorp.local');
DECLARE @uDiana INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='diana.flores@techcorp.local');
DECLARE @uRaul  INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='raul.suarez@techcorp.local');
DECLARE @AdminTech INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='admin.tech@techcorp.local');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dT1 AND NumeroVersion=1)
BEGIN
    INSERT INTO [dbo].[Documento_Version] (IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES
    (@dT1,1,'/archivos/techcorp/TC-MT-001_v1.pdf','a1b2c3d4e5f6789012345678901234567890123456789012345678901234abcd',N'Versión inicial',@uMarco,DATEADD(DAY,-85,GETDATE()),1,@uMarco,'.pdf','application/pdf',1024000),
    (@dT1,2,'/archivos/techcorp/TC-MT-001_v2.pdf','b2c3d4e5f6789012345678901234567890123456789012345678901234abcde',N'Corrección de comandos de red sección 4',@uMarco,DATEADD(DAY,-60,GETDATE()),1,@uMarco,'.pdf','application/pdf',1048576);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dT2 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (@dT2,1,'/archivos/techcorp/TC-PI-001_v1.pdf','c3d4e5f6789012345678901234567890123456789012345678901234abcdef01',N'Publicación inicial',@uMarco,DATEADD(DAY,-70,GETDATE()),1,@uMarco,'.pdf','application/pdf',512000);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dT3 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (@dT3,1,'/archivos/techcorp/TC-PI-002_v1.docx','d4e5f6789012345678901234567890123456789012345678901234abcdef0102',N'Borrador revisión legal',@uLucia,DATEADD(DAY,-30,GETDATE()),1,@uLucia,'.docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',245760);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dT4 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (@dT4,1,'/archivos/techcorp/TC-CON-001_v1.pdf','e5f6789012345678901234567890123456789012345678901234abcdef010203',N'Contrato firmado y escaneado',@uDiana,DATEADD(DAY,-60,GETDATE()),1,@uDiana,'.pdf','application/pdf',2097152);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dT5 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (@dT5,1,'/archivos/techcorp/TC-MT-002_v1.md','f6789012345678901234567890123456789012345678901234abcdef01020304',N'Primer borrador',@uMarco,DATEADD(DAY,-10,GETDATE()),1,@uMarco,'.md','text/markdown',51200);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dT6 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (@dT6,1,'/archivos/techcorp/TC-LEG-001_v1.pdf','a6789012345678901234567890123456789012345678901234abcdef01020305',N'Versión final para firma',@uDiana,DATEADD(DAY,-20,GETDATE()),1,@uDiana,'.pdf','application/pdf',768000);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dT7 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (@dT7,1,'/archivos/techcorp/TC-CON-002_v1.pdf','b6789012345678901234567890123456789012345678901234abcdef01020306',N'Contrato colectivo 2026 firmado',@uLucia,DATEADD(DAY,-45,GETDATE()),1,@uLucia,'.pdf','application/pdf',3145728);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dT8 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento, NumeroVersion, RutaArchivoFisico, HashDocumento, MotivoCambio, IdUsuarioSube, FechaSubida, Estatus, IdUsuarioCreacion, ExtensionArchivo, MimeType, TamanoBytes)
    VALUES (@dT8,1,'/archivos/techcorp/TC-ADM-001_v1.pdf','c6789012345678901234567890123456789012345678901234abcdef01020307',N'Primera versión para aprobación',@AdminTech,DATEADD(DAY,-50,GETDATE()),1,@AdminTech,'.pdf','application/pdf',409600);

PRINT '  ✓ Versiones TechCorp insertadas.';
GO

-- Flujos de aprobación TechCorp
DECLARE @vT1v2  INT = (SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-MT-001') AND NumeroVersion=2);
DECLARE @vT2v1  INT = (SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-PI-001') AND NumeroVersion=1);
DECLARE @vT3v1  INT = (SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-PI-002') AND NumeroVersion=1);
DECLARE @vT6v1  INT = (SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-LEG-001') AND NumeroVersion=1);
DECLARE @vT8v1  INT = (SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='TC-ADM-001') AND NumeroVersion=1);
DECLARE @uSofia  INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='sofia.ramos@techcorp.local');
DECLARE @uRaul   INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='raul.suarez@techcorp.local');
DECLARE @uMarco  INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='marco.torres@techcorp.local');
DECLARE @uLucia  INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='lucia.mendoza@techcorp.local');
DECLARE @uDiana  INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='diana.flores@techcorp.local');
DECLARE @AdminTech INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo='admin.tech@techcorp.local');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vT1v2)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES
    (@vT1v2,@uSofia,'Revisión','Aprobado',1,N'Revisado. Comandos verificados en entorno de prueba.',DATEADD(DAY,-55,GETDATE()),1,DATEADD(DAY,-60,GETDATE()),@uMarco,'TKN-TC-MT001-V2-01','Contraseña'),
    (@vT1v2,@uRaul,'Aprobación','Aprobado',2,N'Aprobado para publicación.',DATEADD(DAY,-53,GETDATE()),1,DATEADD(DAY,-60,GETDATE()),@uMarco,'TKN-TC-MT001-V2-02','Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vT2v1)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES
    (@vT2v1,@uSofia,'Revisión','Aprobado',1,N'Política revisada y alineada con ISO 27001.',DATEADD(DAY,-65,GETDATE()),1,DATEADD(DAY,-70,GETDATE()),@uMarco,'TKN-TC-PI001-V1-01','Contraseña'),
    (@vT2v1,@uRaul,'Aprobación','Aprobado',2,N'Aprobada por Dirección.',DATEADD(DAY,-63,GETDATE()),1,DATEADD(DAY,-70,GETDATE()),@uMarco,'TKN-TC-PI001-V1-02','Contraseña'),
    (@vT2v1,@AdminTech,'Firma','Aprobado',3,N'Firmado digitalmente por el Administrador.',DATEADD(DAY,-62,GETDATE()),1,DATEADD(DAY,-70,GETDATE()),@uMarco,'TKN-TC-PI001-V1-03','Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vT3v1)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Estatus, FechaCreacion, IdUsuarioCreacion)
    VALUES
    (@vT3v1,@uRaul,'Revisión','Pendiente',1,1,DATEADD(DAY,-30,GETDATE()),@uLucia),
    (@vT3v1,@uSofia,'Aprobación','Pendiente',2,1,DATEADD(DAY,-30,GETDATE()),@uLucia);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vT6v1)
BEGIN
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES (@vT6v1,@uSofia,'Revisión','Aprobado',1,N'Política revisada por asesor legal.',DATEADD(DAY,-18,GETDATE()),1,DATEADD(DAY,-20,GETDATE()),@uDiana,'TKN-TC-LEG001-V1-01','Contraseña');
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Estatus, FechaCreacion, IdUsuarioCreacion)
    VALUES (@vT6v1,@AdminTech,'Firma','Pendiente',2,1,DATEADD(DAY,-20,GETDATE()),@uDiana);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vT8v1)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento, IdUsuarioAsignado, TipoAccion, EstadoFirma, Orden, Comentarios, FechaFirma, Estatus, FechaCreacion, IdUsuarioCreacion, TokenFirma, MetodoAutenticacion)
    VALUES (@vT8v1,@uSofia,'Revisión','Rechazado',1,N'No sigue formato corporativo. Requiere revisión completa.',DATEADD(DAY,-45,GETDATE()),1,DATEADD(DAY,-50,GETDATE()),@AdminTech,'TKN-TC-ADM001-V1-01','Contraseña');

PRINT '  ✓ Flujos TechCorp insertados.';
GO


-- Documentos Grupo Innovar
DECLARE @EmpInnov   INT = (SELECT Id FROM [dbo].[Empresa] WHERE Slug = 'grupoinnovar');
DECLARE @DFinInnov  INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Finanzas'       AND IdEmpresa = @EmpInnov);
DECLARE @DOpsInnov  INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Operaciones'    AND IdEmpresa = @EmpInnov);
DECLARE @DAdmInnov  INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Administración' AND IdEmpresa = @EmpInnov);
DECLARE @DCompInnov INT = (SELECT Id FROM [dbo].[Departamento] WHERE Nombre = 'Comercial'      AND IdEmpresa = @EmpInnov);
DECLARE @TRFInnov   INT = (SELECT Id FROM [dbo].[TipoDocumento] WHERE Nombre = 'Reporte Financiero'      AND IdEmpresa = @EmpInnov);
DECLARE @TARInnov   INT = (SELECT Id FROM [dbo].[TipoDocumento] WHERE Nombre = 'Acta de Reunión'          AND IdEmpresa = @EmpInnov);
DECLARE @TPOInnov   INT = (SELECT Id FROM [dbo].[TipoDocumento] WHERE Nombre = 'Procedimiento Operativo'  AND IdEmpresa = @EmpInnov);
DECLARE @AdminInnov INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'admin@grupoinnovar.local');
DECLARE @vPatricia  INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'patricia.luna@grupoinnovar.local');
DECLARE @vIsabel    INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'isabel.cano@grupoinnovar.local');
DECLARE @vElena     INT = (SELECT Id FROM [dbo].[Usuario] WHERE Correo = 'elena.ruiz@grupoinnovar.local');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno='GI-RF-001')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('GI-RF-001',N'Reporte Financiero Q1 2026',@DFinInnov,'Vigente',@vPatricia,DATEADD(DAY,-80,GETDATE()),1,@vPatricia,@TRFInnov,@EmpInnov);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno='GI-RF-002')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('GI-RF-002',N'Reporte Financiero Q2 2026',@DFinInnov,'En Revisión',@vPatricia,DATEADD(DAY,-15,GETDATE()),1,@vPatricia,@TRFInnov,@EmpInnov);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno='GI-AR-001')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('GI-AR-001',N'Acta Reunión Consejo Directivo – Enero 2026',@DAdmInnov,'Vigente',@AdminInnov,DATEADD(DAY,-75,GETDATE()),1,@AdminInnov,@TARInnov,@EmpInnov);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno='GI-PO-001')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('GI-PO-001',N'Procedimiento de Control de Calidad en Línea de Producción',@DOpsInnov,'Vigente',@vIsabel,DATEADD(DAY,-65,GETDATE()),1,@vIsabel,@TPOInnov,@EmpInnov);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno='GI-PO-002')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('GI-PO-002',N'Procedimiento de Gestión de Proveedores',@DOpsInnov,'Borrador',@vIsabel,DATEADD(DAY,-8,GETDATE()),1,@vIsabel,@TPOInnov,@EmpInnov);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno='GI-AR-002')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('GI-AR-002',N'Acta Reunión Comercial – Plan de Ventas 2026',@DCompInnov,'Pendiente Firma',@vElena,DATEADD(DAY,-25,GETDATE()),1,@vElena,@TARInnov,@EmpInnov);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno='GI-RF-003')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('GI-RF-003',N'Presupuesto Anual 2026 – Proyección vs Real',@DFinInnov,'Vigente',@vPatricia,DATEADD(DAY,-50,GETDATE()),1,@vPatricia,@TRFInnov,@EmpInnov);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento] WHERE CodigoInterno='GI-PO-003')
    INSERT INTO [dbo].[Documento] (CodigoInterno, Titulo, IdDepartamento, EstadoActual, IdUsuarioPropietario, FechaCreacion, Estatus, IdUsuarioCreacion, IdTipoDocumento, IdEmpresa)
    VALUES ('GI-PO-003',N'Procedimiento de Atención a Quejas y Reclamaciones',@DCompInnov,'Vigente',@vElena,DATEADD(DAY,-40,GETDATE()),1,@vElena,@TPOInnov,@EmpInnov);

PRINT '  ✓ Documentos Grupo Innovar insertados.';
GO

-- Versiones + Flujos Grupo Innovar (abreviado para lectura; patrón idéntico a TechCorp)
DECLARE @dI1 INT=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-RF-001');
DECLARE @dI2 INT=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-RF-002');
DECLARE @dI3 INT=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-AR-001');
DECLARE @dI4 INT=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-PO-001');
DECLARE @dI5 INT=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-PO-002');
DECLARE @dI6 INT=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-AR-002');
DECLARE @dI7 INT=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-RF-003');
DECLARE @dI8 INT=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-PO-003');
DECLARE @vPatricia INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='patricia.luna@grupoinnovar.local');
DECLARE @vErnesto  INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='ernesto.medina@grupoinnovar.local');
DECLARE @vIsabel   INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='isabel.cano@grupoinnovar.local');
DECLARE @vElena    INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='elena.ruiz@grupoinnovar.local');
DECLARE @vMiguel   INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='miguel.rojas@grupoinnovar.local');
DECLARE @AdminInnov INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='admin@grupoinnovar.local');

-- Versiones Innovar
IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dI1 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento,NumeroVersion,RutaArchivoFisico,HashDocumento,MotivoCambio,IdUsuarioSube,FechaSubida,Estatus,IdUsuarioCreacion,ExtensionArchivo,MimeType,TamanoBytes)
    VALUES (@dI1,1,'/archivos/innovar/GI-RF-001_v1.xlsx','a7891012345678901234567890123456789012345678901234abcdef01020308',N'Reporte Q1 definitivo',@vPatricia,DATEADD(DAY,-80,GETDATE()),1,@vPatricia,'.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',2621440);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dI2 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento,NumeroVersion,RutaArchivoFisico,HashDocumento,MotivoCambio,IdUsuarioSube,FechaSubida,Estatus,IdUsuarioCreacion,ExtensionArchivo,MimeType,TamanoBytes)
    VALUES (@dI2,1,'/archivos/innovar/GI-RF-002_v1.xlsx','b7891012345678901234567890123456789012345678901234abcdef01020309',N'Primer borrador Q2',@vPatricia,DATEADD(DAY,-15,GETDATE()),1,@vPatricia,'.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',2883584);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dI3 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento,NumeroVersion,RutaArchivoFisico,HashDocumento,MotivoCambio,IdUsuarioSube,FechaSubida,Estatus,IdUsuarioCreacion,ExtensionArchivo,MimeType,TamanoBytes)
    VALUES (@dI3,1,'/archivos/innovar/GI-AR-001_v1.pdf','c7891012345678901234567890123456789012345678901234abcdef01020310',N'Acta firmada en sesión',@AdminInnov,DATEADD(DAY,-75,GETDATE()),1,@AdminInnov,'.pdf','application/pdf',614400);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dI4 AND NumeroVersion=1)
BEGIN
    INSERT INTO [dbo].[Documento_Version] (IdDocumento,NumeroVersion,RutaArchivoFisico,HashDocumento,MotivoCambio,IdUsuarioSube,FechaSubida,Estatus,IdUsuarioCreacion,ExtensionArchivo,MimeType,TamanoBytes)
    VALUES
    (@dI4,1,'/archivos/innovar/GI-PO-001_v1.pdf','d7891012345678901234567890123456789012345678901234abcdef01020311',N'Procedimiento inicial',@vIsabel,DATEADD(DAY,-65,GETDATE()),1,@vIsabel,'.pdf','application/pdf',819200),
    (@dI4,2,'/archivos/innovar/GI-PO-001_v2.pdf','e7891012345678901234567890123456789012345678901234abcdef01020312',N'Ajuste de tolerancias según auditoría interna',@vIsabel,DATEADD(DAY,-40,GETDATE()),1,@vIsabel,'.pdf','application/pdf',860160);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dI5 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento,NumeroVersion,RutaArchivoFisico,HashDocumento,MotivoCambio,IdUsuarioSube,FechaSubida,Estatus,IdUsuarioCreacion,ExtensionArchivo,MimeType,TamanoBytes)
    VALUES (@dI5,1,'/archivos/innovar/GI-PO-002_v1.docx','f7891012345678901234567890123456789012345678901234abcdef01020313',N'Borrador inicial',@vIsabel,DATEADD(DAY,-8,GETDATE()),1,@vIsabel,'.docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document',163840);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dI6 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento,NumeroVersion,RutaArchivoFisico,HashDocumento,MotivoCambio,IdUsuarioSube,FechaSubida,Estatus,IdUsuarioCreacion,ExtensionArchivo,MimeType,TamanoBytes)
    VALUES (@dI6,1,'/archivos/innovar/GI-AR-002_v1.pdf','a8891012345678901234567890123456789012345678901234abcdef01020314',N'Acta de reunión comercial',@vElena,DATEADD(DAY,-25,GETDATE()),1,@vElena,'.pdf','application/pdf',307200);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dI7 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento,NumeroVersion,RutaArchivoFisico,HashDocumento,MotivoCambio,IdUsuarioSube,FechaSubida,Estatus,IdUsuarioCreacion,ExtensionArchivo,MimeType,TamanoBytes)
    VALUES (@dI7,1,'/archivos/innovar/GI-RF-003_v1.xlsx','b8891012345678901234567890123456789012345678901234abcdef01020315',N'Proyección anual vs. gastos reales',@vPatricia,DATEADD(DAY,-50,GETDATE()),1,@vPatricia,'.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',3670016);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Documento_Version] WHERE IdDocumento=@dI8 AND NumeroVersion=1)
    INSERT INTO [dbo].[Documento_Version] (IdDocumento,NumeroVersion,RutaArchivoFisico,HashDocumento,MotivoCambio,IdUsuarioSube,FechaSubida,Estatus,IdUsuarioCreacion,ExtensionArchivo,MimeType,TamanoBytes)
    VALUES (@dI8,1,'/archivos/innovar/GI-PO-003_v1.pdf','c8891012345678901234567890123456789012345678901234abcdef01020316',N'Procedimiento de atención al cliente',@vElena,DATEADD(DAY,-40,GETDATE()),1,@vElena,'.pdf','application/pdf',512000);

PRINT '  ✓ Versiones Grupo Innovar insertadas.';
GO

-- Flujos Grupo Innovar
DECLARE @vI1v1 INT=(SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-RF-001') AND NumeroVersion=1);
DECLARE @vI2v1 INT=(SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-RF-002') AND NumeroVersion=1);
DECLARE @vI3v1 INT=(SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-AR-001') AND NumeroVersion=1);
DECLARE @vI4v2 INT=(SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-PO-001') AND NumeroVersion=2);
DECLARE @vI6v1 INT=(SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-AR-002') AND NumeroVersion=1);
DECLARE @vI8v1 INT=(SELECT Id FROM [dbo].[Documento_Version] WHERE IdDocumento=(SELECT Id FROM [dbo].[Documento] WHERE CodigoInterno='GI-PO-003') AND NumeroVersion=1);
DECLARE @vPatricia INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='patricia.luna@grupoinnovar.local');
DECLARE @vErnesto  INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='ernesto.medina@grupoinnovar.local');
DECLARE @vIsabel   INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='isabel.cano@grupoinnovar.local');
DECLARE @vElena    INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='elena.ruiz@grupoinnovar.local');
DECLARE @vMiguel   INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='miguel.rojas@grupoinnovar.local');
DECLARE @AdminInnov INT=(SELECT Id FROM [dbo].[Usuario] WHERE Correo='admin@grupoinnovar.local');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vI1v1)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento,IdUsuarioAsignado,TipoAccion,EstadoFirma,Orden,Comentarios,FechaFirma,Estatus,FechaCreacion,IdUsuarioCreacion,TokenFirma,MetodoAutenticacion)
    VALUES
    (@vI1v1,@vErnesto,'Revisión','Aprobado',1,N'Cifras verificadas contra estados de cuenta bancarios.',DATEADD(DAY,-75,GETDATE()),1,DATEADD(DAY,-80,GETDATE()),@vPatricia,'TKN-GI-RF001-V1-01','Contraseña'),
    (@vI1v1,@AdminInnov,'Aprobación','Aprobado',2,N'Reporte Q1 aprobado para distribución.',DATEADD(DAY,-74,GETDATE()),1,DATEADD(DAY,-80,GETDATE()),@vPatricia,'TKN-GI-RF001-V1-02','Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vI2v1)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento,IdUsuarioAsignado,TipoAccion,EstadoFirma,Orden,Estatus,FechaCreacion,IdUsuarioCreacion)
    VALUES (@vI2v1,@vErnesto,'Revisión','Pendiente',1,1,DATEADD(DAY,-15,GETDATE()),@vPatricia);

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vI3v1)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento,IdUsuarioAsignado,TipoAccion,EstadoFirma,Orden,Comentarios,FechaFirma,Estatus,FechaCreacion,IdUsuarioCreacion,TokenFirma,MetodoAutenticacion)
    VALUES (@vI3v1,@AdminInnov,'Firma','Aprobado',1,N'Acta firmada en sesión por Consejo.',DATEADD(DAY,-73,GETDATE()),1,DATEADD(DAY,-75,GETDATE()),@AdminInnov,'TKN-GI-AR001-V1-01','Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vI4v2)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento,IdUsuarioAsignado,TipoAccion,EstadoFirma,Orden,Comentarios,FechaFirma,Estatus,FechaCreacion,IdUsuarioCreacion,TokenFirma,MetodoAutenticacion)
    VALUES
    (@vI4v2,@vMiguel,'Revisión','Aprobado',1,N'Tolerancias verificadas con auditor externo.',DATEADD(DAY,-37,GETDATE()),1,DATEADD(DAY,-40,GETDATE()),@vIsabel,'TKN-GI-PO001-V2-01','Contraseña'),
    (@vI4v2,@AdminInnov,'Aprobación','Aprobado',2,N'Procedimiento actualizado aprobado.',DATEADD(DAY,-35,GETDATE()),1,DATEADD(DAY,-40,GETDATE()),@vIsabel,'TKN-GI-PO001-V2-02','Contraseña');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vI6v1)
BEGIN
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento,IdUsuarioAsignado,TipoAccion,EstadoFirma,Orden,Comentarios,FechaFirma,Estatus,FechaCreacion,IdUsuarioCreacion,TokenFirma,MetodoAutenticacion)
    VALUES (@vI6v1,@vErnesto,'Revisión','Aprobado',1,N'Plan de ventas revisado y validado.',DATEADD(DAY,-23,GETDATE()),1,DATEADD(DAY,-25,GETDATE()),@vElena,'TKN-GI-AR002-V1-01','Contraseña');
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento,IdUsuarioAsignado,TipoAccion,EstadoFirma,Orden,Estatus,FechaCreacion,IdUsuarioCreacion)
    VALUES (@vI6v1,@AdminInnov,'Firma','Pendiente',2,1,DATEADD(DAY,-25,GETDATE()),@vElena);
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[Flujo_Aprobacion] WHERE IdVersionDocumento=@vI8v1)
    INSERT INTO [dbo].[Flujo_Aprobacion] (IdVersionDocumento,IdUsuarioAsignado,TipoAccion,EstadoFirma,Orden,Comentarios,FechaFirma,Estatus,FechaCreacion,IdUsuarioCreacion,TokenFirma,MetodoAutenticacion)
    VALUES
    (@vI8v1,@vMiguel,'Revisión','Aprobado',1,N'Procedimiento revisado.',DATEADD(DAY,-37,GETDATE()),1,DATEADD(DAY,-40,GETDATE()),@vElena,'TKN-GI-PO003-V1-01','Contraseña'),
    (@vI8v1,@AdminInnov,'Aprobación','Aprobado',2,N'Aprobado por Dirección.',DATEADD(DAY,-35,GETDATE()),1,DATEADD(DAY,-40,GETDATE()),@vElena,'TKN-GI-PO003-V1-02','Contraseña');

PRINT '  ✓ Flujos Grupo Innovar insertados.';
GO


-- ============================================================
-- RESUMEN FINAL
-- ============================================================
PRINT '========================================';
PRINT '  SEED COMPLETADO EXITOSAMENTE';
PRINT '----------------------------------------';
PRINT '  SUPERADMIN   : admin@sigd.local        / Admin@SIGD2026!';
PRINT '  Demo Admin   : admin.demo@sigd.local   / Admin@SIGD2026!';
PRINT '----------------------------------------';
PRINT '  EMPRESA 1: TechCorp Solutions';
PRINT '  Admin   : admin.tech@techcorp.local    / Admin@Tech2026!';
PRINT '  Usuario : user.tech@techcorp.local     / Admin@Tech2026!';
PRINT '  Auditor : auditor.tech@techcorp.local  / Admin@Tech2026!';
PRINT '----------------------------------------';
PRINT '  EMPRESA 2: Grupo Innovar';
PRINT '  Admin   : admin@grupoinnovar.local     / Admin@Innov2026!';
PRINT '  Usuario : user@grupoinnovar.local      / Admin@Innov2026!';
PRINT '  Auditor : auditor@grupoinnovar.local   / Admin@Innov2026!';
PRINT '========================================';