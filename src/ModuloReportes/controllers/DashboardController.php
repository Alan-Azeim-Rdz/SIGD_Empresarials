<?php
/**
 * ============================================================
 * SIGD Empresarial — Módulo de Reportes
 * Controlador del Dashboard de Estadísticas
 * ============================================================
 * Provee métricas y KPIs consultando la tabla documento_vigente
 * en PostgreSQL. Cada método retorna datos en JSON para ser
 * consumidos por Chart.js en el frontend del dashboard.
 * ============================================================
 */

declare(strict_types=1);

namespace Controllers;

use Config\Database;
use PDO;
use Exception;

class DashboardController
{
    private ?PDO $db;

    public function __construct()
    {
        $database  = new Database();
        $this->db  = $database->getConnection();
    }

    // ──────────────────────────────────────────────────────────
    // VISTA HTML: Renderiza el dashboard completo
    // GET /index.php?action=dashboard
    // ──────────────────────────────────────────────────────────
    public function mostrarDashboard(): void
    {
        header("Content-Type: text/html; charset=UTF-8");
        require_once __DIR__ . '/../views/dashboard.php';
    }

    // ──────────────────────────────────────────────────────────
    // API: Totales rápidos para las tarjetas KPI
    // GET /index.php?action=api_kpis
    // ──────────────────────────────────────────────────────────
    public function obtenerKpis(): void
    {
        try {
            // Total de documentos vigentes activos
            $stmt = $this->db->query("SELECT COUNT(*) AS total FROM documento_vigente WHERE estatus = true");
            $totalDocs = (int)$stmt->fetchColumn();

            // Total de departamentos con al menos un documento
            $stmt2 = $this->db->query("SELECT COUNT(DISTINCT id_departamento) AS total FROM documento_vigente WHERE estatus = true");
            $totalDeptos = (int)$stmt2->fetchColumn();

            // Última fecha de publicación
            $stmt3 = $this->db->query("SELECT MAX(fecha_publicacion) AS ultima FROM documento_vigente WHERE estatus = true");
            $ultimaFecha = $stmt3->fetchColumn() ?? 'Sin documentos';

            // Total de acuses registrados
            $totalAcuses = 0;
            try {
                $stmt4 = $this->db->query("SELECT COUNT(*) AS total FROM acuse_lectura");
                $totalAcuses = (int)$stmt4->fetchColumn();
            } catch (Exception) {
                // La tabla podría no existir aún
            }

            echo json_encode([
                'total_documentos'  => $totalDocs,
                'total_departamentos' => $totalDeptos,
                'ultima_publicacion' => $ultimaFecha,
                'total_acuses'      => $totalAcuses,
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }

    // ──────────────────────────────────────────────────────────
    // API: Documentos por departamento (para gráfica de barras)
    // GET /index.php?action=api_docs_por_depto
    // ──────────────────────────────────────────────────────────
    public function docsPorDepartamento(): void
    {
        try {
            $stmt = $this->db->query("
                SELECT COALESCE(d.nombre, 'Depto ' || dv.id_departamento) AS departamento, COUNT(dv.id_documento) AS total
                FROM documento_vigente dv
                LEFT JOIN departamento d ON dv.id_departamento = d.id_departamento
                WHERE dv.estatus = true
                GROUP BY d.nombre, dv.id_departamento
                ORDER BY total DESC
                LIMIT 10
            ");
            $rows = $stmt->fetchAll();
            echo json_encode($rows);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }

    // ──────────────────────────────────────────────────────────
    // API: Evolución mensual de publicaciones (gráfica de línea)
    // GET /index.php?action=api_evolucion
    // ──────────────────────────────────────────────────────────
    public function evolucionMensual(): void
    {
        try {
            $stmt = $this->db->query("
                SELECT
                    TO_CHAR(fecha_publicacion, 'YYYY-MM') AS mes,
                    COUNT(*)                               AS total
                FROM documento_vigente
                WHERE estatus = true
                  AND fecha_publicacion >= NOW() - INTERVAL '12 months'
                GROUP BY mes
                ORDER BY mes ASC
            ");
            $rows = $stmt->fetchAll();
            echo json_encode($rows);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }

    // ──────────────────────────────────────────────────────────
    // API: Últimos 10 documentos publicados (tabla de actividad)
    // GET /index.php?action=api_recientes
    // ──────────────────────────────────────────────────────────
    public function documentosRecientes(): void
    {
        try {
            $stmt = $this->db->query("
                SELECT
                    dv.id_documento,
                    dv.codigo_interno,
                    dv.titulo,
                    dv.version_actual,
                    TO_CHAR(dv.fecha_publicacion, 'DD/MM/YYYY HH24:MI') AS fecha_formateada,
                    dv.id_departamento,
                    COALESCE(d.nombre, 'Depto ' || dv.id_departamento) AS nombre_departamento
                FROM documento_vigente dv
                LEFT JOIN departamento d ON dv.id_departamento = d.id_departamento
                WHERE dv.estatus = true
                ORDER BY dv.fecha_publicacion DESC
                LIMIT 10
            ");
            $rows = $stmt->fetchAll();
            echo json_encode($rows);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }

    // ──────────────────────────────────────────────────────────
    // API: Detalle de cumplimiento por documento (quién leyó y quién no)
    // GET /index.php?action=api_cumplimiento_detalle&id_doc=X
    // ──────────────────────────────────────────────────────────
    public function documentoCumplimientoDetalle(): void
    {
        try {
            $id_doc = (int)($_GET['id_doc'] ?? 0);
            if (!$id_doc) {
                http_response_code(400);
                echo json_encode(['status' => 'error', 'message' => 'id_doc es requerido.']);
                return;
            }

            $query = "
                SELECT 
                    u.id_usuario,
                    u.nombre,
                    u.apellido_p,
                    u.correo,
                    TO_CHAR(a.fecha_lectura, 'DD/MM/YYYY HH24:MI') AS fecha_formateada,
                    a.direccion_ip,
                    CASE WHEN a.id_acuse IS NOT NULL THEN true ELSE false END AS leido
                FROM documento_vigente dv
                JOIN usuario u ON u.id_departamento = dv.id_departamento AND u.id_empresa = dv.id_empresa AND u.estatus = true
                LEFT JOIN acuse_lectura a ON a.id_documento = dv.id_documento AND a.id_usuario = u.id_usuario AND a.estatus = true
                WHERE dv.id_documento = :id_doc AND dv.estatus = true
                ORDER BY leido DESC, u.nombre ASC
            ";
            $stmt = $this->db->prepare($query);
            $stmt->execute([':id_doc' => $id_doc]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($rows);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }
}
