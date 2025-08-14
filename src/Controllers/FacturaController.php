<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\FacturaRepository;
use App\Entities\Factura;

class FacturaController
{
    private FacturaRepository $repo;

    public function __construct()
    {
        $this->repo = new FacturaRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json; charset=utf-8');
        $method = $_SERVER['REQUEST_METHOD'];
        $action = $_GET['action'] ?? null;

        try {
            if ($method === 'PUT' && $action === 'enviar') {
                $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                $id = (int)($payload['id'] ?? 0);
                if ($id <= 0) {
                    http_response_code(400);
                    echo json_encode(['error' => 'id es requerido']);
                    return;
                }
                $numero = $payload['numero'] ?? null;         
                $clave  = $payload['claveAcceso'] ?? null;    

                $ok = $this->repo->markEnviada($id, $numero, $clave);
                echo json_encode(['success' => (bool)$ok]);
                return;
            }

            if ($method === 'PUT' && $action === 'anular') {
                $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                $id = (int)($payload['id'] ?? 0);
                if ($id <= 0) {
                    http_response_code(400);
                    echo json_encode(['error' => 'id es requerido']);
                    return;
                }
                $ok = $this->repo->anular($id);
                echo json_encode(['success' => (bool)$ok]);
                return;
            }

            switch ($method) {
                case 'GET': {
                    if (isset($_GET['id'])) {
                        $factura = $this->repo->findById((int)$_GET['id']);
                        if (!$factura) {
                            http_response_code(404);
                            echo json_encode(['error' => 'Factura no encontrada']);
                            return;
                        }
                        echo json_encode($this->toArray($factura));
                    } else {
                        $list = array_map(fn(Factura $f) => $this->toArray($f), $this->repo->findAll());
                        echo json_encode($list);
                    }
                    return;
                }

                case 'POST': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $idVenta     = (int)($payload['idVenta'] ?? 0);
                    $numero      = (string)($payload['numero'] ?? '');
                    $claveAcceso = (string)($payload['claveAcceso'] ?? '');

                    if ($idVenta <= 0 || $numero === '' || $claveAcceso === '') {
                        http_response_code(400);
                        echo json_encode(['error' => 'idVenta, numero y claveAcceso son requeridos']);
                        return;
                    }

                    $result = $this->repo->createWithVenta($idVenta, $numero, $claveAcceso);

                    if (is_int($result)) {
                        echo json_encode(['success' => true, 'factura_id' => $result]);
                    } else {
                        echo json_encode(['success' => (bool)$result]);
                    }
                    return;
                }

                case 'PUT': {
                    http_response_code(400);
                    echo json_encode(['error' => 'Usa ?action=enviar o ?action=anular']);
                    return;
                }

                case 'DELETE': {
                    http_response_code(405);
                    echo json_encode(['error' => 'Eliminar facturas no está permitido']);
                    return;
                }
            }

            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
        } catch (\Throwable $e) {
            http_response_code(400);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }

    private function toArray(Factura $f): array
    {
        return [
            'id'          => $f->getId(),
            'idVenta'     => $f->getIdVenta(),
            'numero'      => $f->getNumero(),
            'claveAcceso' => $f->getClaveAcceso(),
            'fechaEmision'=> $f->getFechaEmision()->format('Y-m-d H:i:s'),
            'estado'      => $f->getEstado(),
        ];
    }
}
