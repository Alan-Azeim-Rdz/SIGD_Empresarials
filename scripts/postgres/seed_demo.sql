-- ==========================================================
-- SIGD EMPRESARIAL — SEED DATA DE DEMOSTRACIÓN REFACTORIZADO
-- Módulo de Reportes (PostgreSQL)
-- Inserta datos de muestra realistas para las 2 empresas:
-- TechCorp Solutions (2) y Grupo Innovar (3)
-- ==========================================================

-- ── 1. DEPARTAMENTOS POR EMPRESA ──────────────────────────

-- Empresa TechCorp Solutions (id_empresa = 2)
INSERT INTO departamento (id_departamento, nombre, abreviatura, estatus, id_usuario_creacion, id_empresa)
VALUES
    (7,  'Administración',            'ADM',  TRUE, 1, 2),
    (8,  'Tecnología de Información', 'TI',   TRUE, 1, 2),
    (9,  'Recursos Humanos',          'RRHH', TRUE, 1, 2),
    (10, 'Legal y Cumplimiento',      'LEG',  TRUE, 1, 2)
ON CONFLICT (id_departamento) DO UPDATE SET id_empresa = 2;

-- Empresa Grupo Innovar (id_empresa = 3)
INSERT INTO departamento (id_departamento, nombre, abreviatura, estatus, id_usuario_creacion, id_empresa)
VALUES
    (11, 'Administración',            'ADM',  TRUE, 1, 3),
    (12, 'Finanzas',                  'FIN',  TRUE, 1, 3),
    (13, 'Operaciones',               'OPS',  TRUE, 1, 3),
    (14, 'Comercial',                 'COM',  TRUE, 1, 3)
ON CONFLICT (id_departamento) DO UPDATE SET id_empresa = 3;


-- ── 2. TIPOS DE DOCUMENTO POR EMPRESA ─────────────────────

-- Tipos TechCorp (id_empresa = 2)
INSERT INTO tipo_documento (id_tipo, nombre, abreviatura, estatus, id_usuario_creacion, id_empresa)
VALUES
    (8,  'Contrato',          'CON', TRUE, 1, 2),
    (12, 'Manual Técnico',     'MT',  TRUE, 1, 2),
    (13, 'Política Interna',   'PI',  TRUE, 1, 2)
ON CONFLICT (id_tipo) DO UPDATE SET id_empresa = 2;

-- Tipos Grupo Innovar (id_empresa = 3)
INSERT INTO tipo_documento (id_tipo, nombre, abreviatura, estatus, id_usuario_creacion, id_empresa)
VALUES
    (9,  'Reporte Financiero',     'RF', TRUE, 1, 3),
    (10, 'Acta de Reunión',        'AR', TRUE, 1, 3),
    (11, 'Procedimiento Operativo', 'PO', TRUE, 1, 3)
ON CONFLICT (id_tipo) DO UPDATE SET id_empresa = 3;


-- ── 3. USUARIOS POR EMPRESA (Exactamente 8) ───────────────

-- Contraseñas hasheadas en SHA-256 para password: Test@2026!
-- Hash: D6C60A142079BF6EBBD2863FBFEE181E99F5EAA8D8D30353A2292BE1C2BC9A68 (uppercase)

-- Usuarios Empresa TechCorp Solutions (id_empresa = 2)
INSERT INTO usuario (id_usuario, id_departamento, nombre, apellido_p, correo, contrasena, estatus, id_usuario_creacion, id_empresa)
VALUES
    (7,  7, 'Ana',     'García',   'admin.tech@techcorp.local',    'D6C60A142079BF6EBBD2863FBFEE181E99F5EAA8D8D30353A2292BE1C2BC9A68', TRUE, 1, 2),
    (8,  8, 'Tomás',   'López',    'user.tech@techcorp.local',     'D6C60A142079BF6EBBD2863FBFEE181E99F5EAA8D8D30353A2292BE1C2BC9A68', TRUE, 1, 2),
    (9,  7, 'Silvia',  'Mendoza',  'auditor.tech@techcorp.local',  'D6C60A142079BF6EBBD2863FBFEE181E99F5EAA8D8D30353A2292BE1C2BC9A68', TRUE, 1, 2),
    (10, 8, 'Roberto', 'Vargas',   'superior.tech@techcorp.local', 'D6C60A142079BF6EBBD2863FBFEE181E99F5EAA8D8D30353A2292BE1C2BC9A68', TRUE, 1, 2)
ON CONFLICT (id_usuario) DO UPDATE SET id_empresa = 2, id_departamento = EXCLUDED.id_departamento;

-- Usuarios Empresa Grupo Innovar (id_empresa = 3)
INSERT INTO usuario (id_usuario, id_departamento, nombre, apellido_p, correo, contrasena, estatus, id_usuario_creacion, id_empresa)
VALUES
    (11, 11, 'Carlos',   'López',     'admin@grupoinnovar.local',    'D6C60A142079BF6EBBD2863FBFEE181E99F5EAA8D8D30353A2292BE1C2BC9A68', TRUE, 1, 3),
    (12, 13, 'Patricia', 'Luna',      'user@grupoinnovar.local',     'D6C60A142079BF6EBBD2863FBFEE181E99F5EAA8D8D30353A2292BE1C2BC9A68', TRUE, 1, 3),
    (13, 11, 'Ernesto',  'Medina',    'auditor@grupoinnovar.local',  'D6C60A142079BF6EBBD2863FBFEE181E99F5EAA8D8D30353A2292BE1C2BC9A68', TRUE, 1, 3),
    (14, 13, 'Elena',    'Ruiz',      'superior@grupoinnovar.local', 'D6C60A142079BF6EBBD2863FBFEE181E99F5EAA8D8D30353A2292BE1C2BC9A68', TRUE, 1, 3)
ON CONFLICT (id_usuario) DO UPDATE SET id_empresa = 3, id_departamento = EXCLUDED.id_departamento;


-- ── 4. DOCUMENTOS VIGENTES POR EMPRESA (Sincronizados) ─────

-- Empresa TechCorp Solutions (id_empresa = 2)
INSERT INTO documento_vigente
    (id_documento, codigo_interno, titulo, id_tipo, id_departamento, version_actual,
     fecha_publicacion, ruta_archivo_descarga, hash_verificacion, estatus, id_usuario_creacion, id_empresa)
VALUES
    (19, 'TC-MT-001',  'Manual de Configuración de Servidores Linux',       12, 8,  2, NOW() - INTERVAL '85 days', '/archivos/techcorp/TC-MT-001_v2.pdf',   'HASH_TC001', TRUE, 8, 2),
    (20, 'TC-PI-001',  'Política de Seguridad de la Información',           13, 8,  1, NOW() - INTERVAL '70 days', '/archivos/techcorp/TC-PI-001_v1.pdf',   'HASH_TC002', TRUE, 8, 2),
    (21, 'TC-PI-002',  'Política de Vacaciones y Permisos',                  13, 8,  1, NOW() - INTERVAL '30 days', '/archivos/techcorp/TC-PI-002_v1.docx',  'HASH_TC003', TRUE, 8, 2),
    (22, 'TC-CON-001', 'Contrato de Servicios Cloud – Proveedor AWS',        8,  8,  1, NOW() - INTERVAL '60 days', '/archivos/techcorp/TC-CON-001_v1.pdf',   'HASH_TC004', TRUE, 8, 2),
    (23, 'TC-MT-002',  'Guía de Implementación de DevOps con GitLab CI/CD',  12, 8,  1, NOW() - INTERVAL '10 days', '/archivos/techcorp/TC-MT-002_v1.md',     'HASH_TC005', TRUE, 8, 2),
    (24, 'TC-LEG-001', 'Política de Protección de Datos Personales (LGPDP)', 13, 8,  1, NOW() - INTERVAL '20 days', '/archivos/techcorp/TC-LEG-001_v1.pdf',   'HASH_TC006', TRUE, 8, 2),
    (25, 'TC-CON-002', 'Contrato Colectivo de Trabajo 2026',                 8,  8,  1, NOW() - INTERVAL '45 days', '/archivos/techcorp/TC-CON-002_v1.pdf',   'HASH_TC007', TRUE, 8, 2),
    (26, 'TC-ADM-001', 'Manual de Procesos Administrativos v1.0',            12, 8,  1, NOW() - INTERVAL '50 days', '/archivos/techcorp/TC-ADM-001_v1.pdf',   'HASH_TC008', TRUE, 7, 2)
ON CONFLICT (id_documento) DO UPDATE SET id_empresa = 2, id_departamento = EXCLUDED.id_departamento;

-- Empresa Grupo Innovar (id_empresa = 3)
INSERT INTO documento_vigente
    (id_documento, codigo_interno, titulo, id_tipo, id_departamento, version_actual,
     fecha_publicacion, ruta_archivo_descarga, hash_verificacion, estatus, id_usuario_creacion, id_empresa)
VALUES
    (27, 'GI-RF-001', 'Reporte Financiero Q1 2026',                         9,  13, 1, NOW() - INTERVAL '80 days', '/archivos/innovar/GI-RF-001_v1.xlsx',   'HASH_GI001', TRUE, 12, 3),
    (28, 'GI-RF-002', 'Reporte Financiero Q2 2026',                         9,  13, 1, NOW() - INTERVAL '15 days', '/archivos/innovar/GI-RF-002_v1.xlsx',   'HASH_GI002', TRUE, 12, 3),
    (29, 'GI-AR-001', 'Acta Reunión Consejo Directivo – Enero 2026',         10, 13, 1, NOW() - INTERVAL '75 days', '/archivos/innovar/GI-AR-001_v1.pdf',    'HASH_GI003', TRUE, 11, 3),
    (30, 'GI-PO-001', 'Procedimiento de Control de Calidad en Línea',       11, 13, 2, NOW() - INTERVAL '40 days', '/archivos/innovar/GI-PO-001_v2.pdf',    'HASH_GI004', TRUE, 12, 3),
    (31, 'GI-PO-002', 'Procedimiento de Gestión de Proveedores',             11, 13, 1, NOW() - INTERVAL '8 days',  '/archivos/innovar/GI-PO-002_v1.docx',   'HASH_GI005', TRUE, 12, 3),
    (32, 'GI-AR-002', 'Acta Reunión Comercial – Plan de Ventas 2026',        10, 13, 1, NOW() - INTERVAL '25 days', '/archivos/innovar/GI-AR-002_v1.pdf',    'HASH_GI006', TRUE, 12, 3),
    (33, 'GI-RF-003', 'Presupuesto Anual 2026 – Proyección vs Real',         9,  13, 1, NOW() - INTERVAL '50 days', '/archivos/innovar/GI-RF-003_v1.xlsx',   'HASH_GI007', TRUE, 12, 3),
    (34, 'GI-PO-003', 'Procedimiento de Atención a Quejas y Reclamaciones',  11, 13, 1, NOW() - INTERVAL '40 days', '/archivos/innovar/GI-PO-003_v1.pdf',    'HASH_GI008', TRUE, 12, 3)
ON CONFLICT (id_documento) DO UPDATE SET id_empresa = 3, id_departamento = EXCLUDED.id_departamento;


-- ── 5. ACUSES DE LECTURA DE MUESTRA (Cumplimiento realista) ──

INSERT INTO acuse_lectura
    (id_documento, id_usuario, direccion_ip, dispositivo_info, estatus, id_usuario_creacion)
VALUES
    -- Empresa TechCorp Solutions (Leído por Tomás López - Id 8)
    (19, 8, '192.168.2.10', 'Chrome/Windows',  TRUE, 7),
    (20, 8, '192.168.2.11', 'Chrome/Windows',  TRUE, 7),
    (22, 8, '192.168.2.12', 'Firefox/Windows', TRUE, 7),
    (25, 8, '192.168.2.13', 'Safari/macOS',    TRUE, 7),
    
    -- Empresa Grupo Innovar (Leído por Patricia Luna - Id 12 o Carlos López - Id 11)
    (27, 12, '192.168.3.10', 'Edge/Windows',    TRUE, 11),
    (29, 11, '192.168.3.11', 'Chrome/Android',  TRUE, 11),
    (30, 12, '192.168.3.12', 'Chrome/Windows',  TRUE, 11),
    (32, 12, '192.168.3.13', 'Safari/iOS',      TRUE, 11)
ON CONFLICT DO NOTHING;


-- ── 6. CONFIRMACIÓN Y AUDITORÍA ────────────────────────────

DO $$
DECLARE
    total_docs    INT;
    total_deptos  INT;
    total_usuarios INT;
    total_acuses  INT;
BEGIN
    SELECT COUNT(*) INTO total_docs    FROM documento_vigente WHERE estatus = TRUE;
    SELECT COUNT(*) INTO total_deptos  FROM departamento WHERE estatus = TRUE;
    SELECT COUNT(*) INTO total_usuarios FROM usuario WHERE estatus = TRUE;
    SELECT COUNT(*) INTO total_acuses  FROM acuse_lectura WHERE estatus = TRUE;
    
    RAISE NOTICE '============================================';
    RAISE NOTICE '  SEED DATA INSERTADO EXITOSAMENTE (POSTGRES)';
    RAISE NOTICE '  Departamentos       : %', total_deptos;
    RAISE NOTICE '  Usuarios            : %', total_usuarios;
    RAISE NOTICE '  Documentos vigentes : %', total_docs;
    RAISE NOTICE '  Acuses de lectura   : %', total_acuses;
    RAISE NOTICE '============================================';
END $$;
