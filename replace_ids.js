const fs = require('fs');
const path = require('path');

const files = [
    'scripts/sqlserver/seed.sql',
    'scripts/postgres/seed_demo.sql',
    'scripts/mongo/seed_demo.js'
];

const idMap = {
    '7': '2',
    '8': '3',
    '9': '4',
    '10': '5',
    '11': '6',
    '12': '7',
    '13': '8',
    '14': '9'
};

files.forEach(file => {
    const fullPath = path.join(__dirname, file);
    if (!fs.existsSync(fullPath)) {
        console.log('Skipping ' + file);
        return;
    }
    
    let content = fs.readFileSync(fullPath, 'utf8');
    
    // We only want to replace specific patterns to avoid replacing IdDepartamento=7 with IdDepartamento=2
    // Let's identify the patterns where User IDs are used.
    
    // In SQL Server seed.sql:
    // Id = 7
    // VALUES (7,
    // IdUsuario = 7
    // IdUsuarioCreacion = 7
    // IdUsuarioModificacion = 7
    // IdUsuarioPropietario = 7
    // IdUsuarioSube = 7
    // IdUsuarioAsignado = 7
    // id_usuario_creacion: 7 (in Mongo)
    // id_usuario = 7 (in Postgres)
    
    // Actually, we can just replace ID variables carefully:
    
    // A safer way is to use a replacer function for specific SQL and JS patterns.
    const patterns = [
        /(Id|IdUsuario|IdUsuarioCreacion|IdUsuarioModificacion|IdUsuarioPropietario|IdUsuarioSube|IdUsuarioAsignado|id_usuario|id_usuario_creacion)\s*(=|:)\s*(\d+)/gi,
        /(VALUES\s*\()(\d+)(,\s*\d+,\s*(?:2|3),\s*N')/g, // Usuario inserts (Id, IdDepartamento, IdEmpresa, Nombre) -> we only replace the first \d+
        /(VALUES\s*\()(\d+)(,\s*@Rol)/g, // Usuario_Rol inserts
        /(VALUES\s*\([^,]+,\s*)(\d+)(,\s*'\d{3}\.\d{3}\.\d{1,3}\.\d{1,3}')/g // Acuse de lectura Postgres: VALUES (19, 8, '192.168.2.10'... we need to replace the 8
    ];
    
    patterns.forEach(regex => {
        content = content.replace(regex, (match, p1, p2, p3) => {
            if (regex === patterns[0]) {
                const oldId = p3;
                if (idMap[oldId]) {
                    return `${p1}${p2} ${idMap[oldId]}`;
                }
                return match;
            } else if (regex === patterns[1] || regex === patterns[2]) {
                const oldId = p2;
                if (idMap[oldId]) {
                    return `${p1}${idMap[oldId]}${p3}`;
                }
                return match;
            } else if (regex === patterns[3]) {
                const oldId = p2;
                if (idMap[oldId]) {
                    return `${p1}${idMap[oldId]}${p3}`;
                }
                return match;
            }
        });
    });
    
    // Also fix exact strings:
    // Postgres acuses: VALUES ... (19, 8,
    // Postgres Documento Vigente: VALUES ... TRUE, 8, 2)
    content = content.replace(/(TRUE,\s*)(\d+)(,\s*(?:2|3)\))/g, (match, p1, p2, p3) => {
        if (idMap[p2]) {
            return `${p1}${idMap[p2]}${p3}`;
        }
        return match;
    });

    // SQL Server Documento inserts:
    // VALUES (19, 'TC-MT-001', N'Manual...', 8, 'Vigente', 8,
    content = content.replace(/(,\s*'[^']+',\s*N'[^']+',\s*\d+,\s*'[^']+',\s*)(\d+)(,\s*GETDATE\(\),\s*1,\s*)(\d+)/g, (match, p1, p2, p3, p4) => {
        let newP2 = idMap[p2] || p2;
        let newP4 = idMap[p4] || p4;
        return `${p1}${newP2}${p3}${newP4}`;
    });
    
    // SQL Server Documento_Version inserts:
    // N'Versión inicial', 8, DATEADD(DAY,-85,GETDATE()), 1, 8, '.pdf'
    content = content.replace(/(N'[^']+',\s*)(\d+)(,\s*DATEADD[^,]+,\s*1,\s*)(\d+)(,\s*'\.[^']+')/g, (match, p1, p2, p3, p4, p5) => {
        let newP2 = idMap[p2] || p2;
        let newP4 = idMap[p4] || p4;
        return `${p1}${newP2}${p3}${newP4}`;
    });

    // Flujo Aprobacion SQL Server
    // VALUES (1, 4, 8, 'Revisa', 'Aprobado',
    content = content.replace(/(VALUES\s*\(\d+,\s*\d+,\s*)(\d+)(,\s*'[^']+',\s*'[^']+')/g, (match, p1, p2, p3) => {
        let newP2 = idMap[p2] || p2;
        return `${p1}${newP2}${p3}`;
    });
    // Flujo aprobacion has IdUsuarioCreacion at the end:
    // 'Aprobado', N'Ok', DATEADD(DAY,-28,GETDATE()), 1, 8,
    content = content.replace(/(',\s*N'[^']*',\s*DATEADD[^,]+,\s*\d+,\s*)(\d+)(,\s*GETDATE\(\))/g, (match, p1, p2, p3) => {
        let newP2 = idMap[p2] || p2;
        return `${p1}${newP2}${p3}`;
    });

    // BitacoraTransaccional SQL Server
    // VALUES (8, 20, 3, 'APROBACION', N'Se aprobó política', 8);
    content = content.replace(/(VALUES\s*\()(\d+)(,\s*\d+,\s*(?:\d+|NULL),\s*'[^']+',\s*N'[^']+',\s*)(\d+)(\);)/g, (match, p1, p2, p3, p4, p5) => {
        let newP2 = idMap[p2] || p2;
        let newP4 = idMap[p4] || p4;
        return `${p1}${newP2}${p3}${newP4}${p5}`;
    });

    fs.writeFileSync(fullPath, content, 'utf8');
    console.log('Processed ' + file);
});
