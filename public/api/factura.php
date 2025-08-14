<?php 

require __DIR__ . '/../../vendor/autoload.php';

use App\Controllers\FacturaController;

(new FacturaController())->handle();
