const express = require('express');
const router = express.Router();

const controller = require('../controllers/clientesController');

router.get('/', controller.listar);
router.get('/:id', controller.buscar);
router.post('/', controller.criar);
router.put('/:id', controller.atualizar);
router.patch('/:id', controller.atualizar);
router.delete('/:id', controller.excluir);

module.exports = router;
