<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dashboard de Reportes | SIGD Empresarial</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <link href="css/dashboard.css" rel="stylesheet" />
</head>
<body>

<!-- ══════════════ SIDEBAR ══════════════ -->
<aside class="sidebar">
    <div class="sidebar-logo">SIGD <span>Reportes</span></div>
    <nav>
        <a href="?action=dashboard" class="nav-link-side active">
            <i class="fas fa-chart-line fa-fw"></i> Dashboard
        </a>
        <a href="?action=portal" class="nav-link-side">
            <i class="fas fa-file-alt fa-fw"></i> Portal Operario
        </a>
        <div class="sidebar-divider"></div>
        <a href="http://localhost:5000" target="_blank" class="nav-link-side">
            <i class="fas fa-arrow-up-right-from-square fa-fw"></i> Módulo Central
        </a>
        <a href="http://localhost:5000/Busqueda/Global" target="_blank" class="nav-link-side">
            <i class="fas fa-search fa-fw"></i> Buscador Global
        </a>
        <div class="sidebar-divider"></div>
        <a href="#" class="nav-link-side" data-bs-toggle="modal" data-bs-target="#modalConexiones" id="btn-config-conexiones" style="color: var(--sapphire-light) !important;">
            <i class="fas fa-cog fa-fw"></i> Conexiones
        </a>
    </nav>
</aside>

<!-- ══════════════ MAIN ══════════════ -->
<div class="main-content">

    <!-- Header -->
    <div class="page-hero animate-fade-in">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div>
                <h1><i class="fas fa-chart-bar me-2"></i>Dashboard de Reportes</h1>
                <p>Monitorea y analiza métricas de publicación y acuses de lectura en tiempo real.</p>
            </div>
            <div class="d-flex gap-2 align-items-center">
                <span class="badge-live"><i class="fas fa-circle me-1" style="font-size:.55rem"></i>En vivo</span>
                <a href="?action=portal" class="portal-btn">
                    <i class="fas fa-users me-1"></i>Portal Operario
                </a>
            </div>
        </div>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-grid" id="kpi-grid">
        <div class="kpi-card kpi-blue">
            <div class="kpi-icon"><i class="fas fa-file-alt"></i></div>
            <div class="kpi-value" id="kpi-docs">—</div>
            <div class="kpi-label">Documentos Vigentes</div>
        </div>
        <div class="kpi-card kpi-green">
            <div class="kpi-icon"><i class="fas fa-building"></i></div>
            <div class="kpi-value" id="kpi-deptos">—</div>
            <div class="kpi-label">Departamentos con Docs</div>
        </div>
        <div class="kpi-card kpi-red">
            <div class="kpi-icon"><i class="fas fa-check-double"></i></div>
            <div class="kpi-value" id="kpi-acuses">—</div>
            <div class="kpi-label">Acuses de Lectura</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon" style="background:rgba(210,168,255,.15);color:var(--accent4)">
                <i class="fas fa-calendar-check"></i>
            </div>
            <div class="kpi-value" id="kpi-fecha" style="font-size:1rem;padding-top:.5rem;color:var(--accent4)">—</div>
            <div class="kpi-label">Última Publicación</div>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="charts-row">
        <div class="chart-card">
            <h2><i class="fas fa-chart-pie"></i>Docs por Departamento</h2>
            <canvas id="chartDepto" height="250"></canvas>
        </div>
        <div class="chart-card">
            <h2><i class="fas fa-chart-line"></i>Evolución de Publicaciones (últimos 12 meses)</h2>
            <canvas id="chartEvolucion" height="250"></canvas>
        </div>
    </div>

    <!-- Activity Table -->
    <div class="activity-table">
        <h2><i class="fas fa-history me-2" style="color:var(--text-muted)"></i>Últimos Documentos Publicados</h2>
        <table class="sigd-table">
            <thead>
                <tr>
                    <th>Código</th>
                    <th>Título</th>
                    <th>Versión</th>
                    <th>Departamento</th>
                    <th>Fecha de Publicación</th>
                </tr>
            </thead>
            <tbody id="tabla-recientes">
                <tr><td colspan="5" class="text-center" style="color:var(--text-muted);padding:2rem">
                    <i class="fas fa-spinner fa-spin me-2"></i>Cargando datos...
                </td></tr>
            </tbody>
        </table>
    </div>

</div><!-- /main-content -->

<script>
// Detectar si está en un iframe
if (window.self !== window.top) {
    document.body.classList.add('in-iframe');
}

const BASE = window.location.origin + window.location.pathname.replace(/\?.*/, '');

// ── Paleta de colores Chart.js ──
const COLORS = ['#3B82F6', '#06B6D4', '#8B5CF6', '#F59E0B', '#EF4444', '#60A5FA', '#22D3EE', '#A78BFA'];

// ── 1. KPIs ──
fetch(`${BASE}?action=api_kpis`)
    .then(r => r.json())
    .then(d => {
        document.getElementById('kpi-docs').textContent    = d.total_documentos   ?? '0';
        document.getElementById('kpi-deptos').textContent  = d.total_departamentos ?? '0';
        document.getElementById('kpi-acuses').textContent  = d.total_acuses        ?? '0';
        const fecha = d.ultima_publicacion;
        document.getElementById('kpi-fecha').textContent   = fecha !== 'Sin documentos' && fecha
            ? new Date(fecha).toLocaleDateString('es-MX', { day:'2-digit', month:'short', year:'numeric' })
            : 'Sin datos';
    })
    .catch(() => {
        ['kpi-docs','kpi-deptos','kpi-acuses','kpi-fecha'].forEach(id => {
            document.getElementById(id).textContent = 'N/A';
        });
    });

// ── 2. Gráfica de barras: Docs por Departamento ──
fetch(`${BASE}?action=api_docs_por_depto`)
    .then(r => r.json())
    .then(rows => {
        if (rows.error) return;
        const labels = rows.map(r => r.departamento);
        const data   = rows.map(r => parseInt(r.total));
        new Chart(document.getElementById('chartDepto'), {
            type: 'doughnut',
            data: {
                labels,
                datasets: [{ data, backgroundColor: COLORS, borderColor: '#141A2A', borderWidth: 3 }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { color: '#94A3B8', padding: 12, font: { size: 11 } }
                    },
                    tooltip: {
                        callbacks: {
                            label: ctx => ` ${ctx.label}: ${ctx.parsed} docs`
                        }
                    }
                }
            }
        });
    });

// ── 3. Gráfica de línea: Evolución mensual ──
fetch(`${BASE}?action=api_evolucion`)
    .then(r => r.json())
    .then(rows => {
        if (rows.error || rows.length === 0) {
            document.getElementById('chartEvolucion').parentElement.innerHTML +=
                '<p style="color:var(--text-secondary);text-align:center;font-size:.88rem">Sin datos en los últimos 12 meses. Los documentos aparecerán conforme sean aprobados.</p>';
            return;
        }
        const labels = rows.map(r => r.mes);
        const data   = rows.map(r => parseInt(r.total));
        new Chart(document.getElementById('chartEvolucion'), {
            type: 'line',
            data: {
                labels,
                datasets: [{
                    label: 'Documentos publicados',
                    data,
                    borderColor: '#3B82F6',
                    backgroundColor: 'rgba(59,130,246,.08)',
                    fill: true,
                    tension: .35,
                    pointBackgroundColor: '#3B82F6',
                    pointRadius: 5,
                    pointHoverRadius: 7,
                }]
            },
            options: {
                responsive: true,
                interaction: { mode: 'index', intersect: false },
                scales: {
                    x: { ticks: { color: '#94A3B8', font: { size: 11 } }, grid: { color: 'rgba(30,37,56,0.5)' } },
                    y: { ticks: { color: '#94A3B8', font: { size: 11 }, stepSize: 1 }, grid: { color: 'rgba(30,37,56,0.5)' }, beginAtZero: true }
                },
                plugins: { legend: { labels: { color: '#F8FAFC' } } }
            }
        });
    });

// ── 4. Tabla de documentos recientes ──
fetch(`${BASE}?action=api_recientes`)
    .then(r => r.json())
    .then(rows => {
        const tbody = document.getElementById('tabla-recientes');
        if (!rows.length) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center" style="color:var(--text-muted);padding:2rem">Aún no hay documentos sincronizados. Aprueba un documento en el Módulo Central para verlo aquí.</td></tr>';
            return;
        }
        tbody.innerHTML = rows.map(doc => `
            <tr>
                <td><span class="badge-version">${doc.codigo_interno}</span></td>
                <td>${doc.titulo}</td>
                <td><span class="badge-version">v${doc.version_actual}</span></td>
                <td><span class="badge-depto">${doc.nombre_departamento || ('Depto ' + doc.id_departamento)}</span></td>
                <td style="color:var(--text-muted)">${doc.fecha_formateada}</td>
            </tr>
        `).join('');
    })
    .catch(() => {
        document.getElementById('tabla-recientes').innerHTML =
            '<tr><td colspan="5" class="text-center" style="color:var(--text-muted)">Error cargando datos</td></tr>';
    });
</script>


    <!-- Modal Configuración de Conexiones -->
    <div class="modal fade" id="modalConexiones" tabindex="-1" aria-labelledby="modalConexionesLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="modalConexionesLabel"><i class="fas fa-network-wired me-2"></i> Configuración de Conexiones</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="small text-muted mb-3">Define las URLs del ecosistema para la navegación del cliente y llamadas de API. De forma predeterminada, se detecta el host actual y cambia el puerto.</p>
                    <div class="mb-3">
                        <label for="cfg_csharp" class="form-label fw-bold">Módulo Central (C# - Puerto 5000)</label>
                        <input type="text" id="cfg_csharp" class="form-control" placeholder="http://localhost:5000" />
                    </div>
                    <div class="mb-3">
                        <label for="cfg_php" class="form-label fw-bold">Módulo de Reportes/Portal (PHP - Puerto 8000)</label>
                        <input type="text" id="cfg_php" class="form-control" placeholder="http://localhost:8000" />
                    </div>
                    <div class="mb-3">
                        <label for="cfg_node" class="form-label fw-bold">Buscador Global (Node.js - Puerto 3000)</label>
                        <input type="text" id="cfg_node" class="form-control" placeholder="http://localhost:3000" />
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-jewel btn-sm" id="btnResetConexiones">Restablecer</button>
                    <button type="button" class="btn btn-jewel-primary btn-sm" id="btnGuardarConexiones">Guardar Cambios</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        (function() {
            // Configuración y resolución de conexiones
            const currentHost = window.location.hostname;
            const defaultCSharp = `http://${currentHost}:5000`;
            const defaultPHP = window.location.origin;
            const defaultNode = `http://${currentHost}:3000`;

            const resolvedUrls = {
                csharp: localStorage.getItem('cfg_url_csharp') || defaultCSharp,
                php: localStorage.getItem('cfg_url_php') || defaultPHP,
                node: localStorage.getItem('cfg_url_node') || defaultNode
            };

            function rewriteLinks() {
                document.querySelectorAll('a[href]').forEach(el => {
                    let href = el.getAttribute('href');
                    if (href) {
                        if (href.startsWith('http://localhost:5000')) {
                            el.href = href.replace('http://localhost:5000', resolvedUrls.csharp);
                        } else if (href.startsWith('http://localhost:8000')) {
                            el.href = href.replace('http://localhost:8000', resolvedUrls.php);
                        } else if (href.startsWith('http://localhost:3000')) {
                            el.href = href.replace('http://localhost:3000', resolvedUrls.node);
                        }
                    }
                });
            }

            rewriteLinks();

            document.addEventListener('DOMContentLoaded', () => {
                rewriteLinks();
                
                const inputCSharp = document.getElementById('cfg_csharp');
                const inputPHP = document.getElementById('cfg_php');
                const inputNode = document.getElementById('cfg_node');
                
                if (inputCSharp) inputCSharp.value = resolvedUrls.csharp;
                if (inputPHP) inputPHP.value = resolvedUrls.php;
                if (inputNode) inputNode.value = resolvedUrls.node;

                const btnGuardar = document.getElementById('btnGuardarConexiones');
                if (btnGuardar) {
                    btnGuardar.addEventListener('click', () => {
                        localStorage.setItem('cfg_url_csharp', inputCSharp.value.trim());
                        localStorage.setItem('cfg_url_php', inputPHP.value.trim());
                        localStorage.setItem('cfg_url_node', inputNode.value.trim());
                        location.reload();
                    });
                }

                const btnReset = document.getElementById('btnResetConexiones');
                if (btnReset) {
                    btnReset.addEventListener('click', () => {
                        localStorage.removeItem('cfg_url_csharp');
                        localStorage.removeItem('cfg_url_php');
                        localStorage.removeItem('cfg_url_node');
                        location.reload();
                    });
                }
            });
        })();
    </script>
</body>
</html>
