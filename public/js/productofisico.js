const createProductoFisicoPanel = () => {
    Ext.define('App.model.ProductoFisico', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'nombre', type: 'string' },
            { name: 'descripcion', type: 'string' },
            { name: 'precioUnitario', type: 'float' },
            { name: 'stock', type: 'int' },
            { name: 'idCategoria', type: 'int' },
            { name: 'peso', type: 'float' },
            { name: 'alto', type: 'float' },
            { name: 'ancho', type: 'float' },
            { name: 'profundidad', type: 'float' }
        ],
        idProperty: 'id'
    });

    const productoFisicoStore = Ext.create('Ext.data.Store', {
        storeId: 'productoFisicoStore',
        model: 'App.model.ProductoFisico',
        proxy: {
            type: 'rest',
            url: '/api/producto_fisico.php',
            reader: {
                type: 'json',
                transform: function (data) {
                    if (Array.isArray(data)) return data;
                    if (data && data.error) {
                        Ext.Msg.alert('Error', data.error);
                        return [];
                    }
                    return data && data.data ? data.data : data;
                }
            },
            writer: {
                type: 'json',
                writeAllFields: true,
                allowSingle: true
            },
            batchActions: false,
            listeners: {
                exception: function (proxy, response) {
                    let msg = 'Error de servidor';
                    try {
                        const j = JSON.parse(response.responseText);
                        if (j && j.error) msg = j.error;
                    } catch (e) {}
                    Ext.Msg.alert('Error', msg);
                }
            }
        },
        autoLoad: true,
        autoSync: false
    });

    const openDialog = (rec, isNew) => {
        const win = Ext.create('Ext.window.Window', {
            title: isNew ? 'Nuevo Producto Físico' : 'Editar Producto Físico',
            modal: true,
            layout: 'fit',
            width: 520,
            items: [{
                xtype: 'form',
                bodyPadding: 12,
                defaults: { anchor: '100%', msgTarget: 'side' },
                items: [
                    { xtype: 'hiddenfield', name: 'id' },
                    { xtype: 'textfield', name: 'nombre', fieldLabel: 'Nombre', allowBlank: false },
                    { xtype: 'textarea', name: 'descripcion', fieldLabel: 'Descripción' },
                    { xtype: 'numberfield', name: 'precioUnitario', fieldLabel: 'Precio Unitario', allowBlank: false, minValue: 0 },
                    { xtype: 'numberfield', name: 'stock', fieldLabel: 'Stock', allowBlank: false, minValue: 0 },
                    { xtype: 'numberfield', name: 'idCategoria', fieldLabel: 'ID Categoría', allowBlank: false, minValue: 1 },
                    { xtype: 'numberfield', name: 'peso', fieldLabel: 'Peso', minValue: 0 },
                    { xtype: 'numberfield', name: 'alto', fieldLabel: 'Alto', minValue: 0 },
                    { xtype: 'numberfield', name: 'ancho', fieldLabel: 'Ancho', minValue: 0 },
                    { xtype: 'numberfield', name: 'profundidad', fieldLabel: 'Profundidad', minValue: 0 }
                ]
            }],
            buttons: [
                {
                    text: 'Guardar',
                    formBind: true,
                    handler: () => {
                        const form = win.down('form').getForm();
                        if (!form.isValid()) return;
                        form.updateRecord(rec);
                        if (isNew) {
                            productoFisicoStore.add(rec);
                        }
                        productoFisicoStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Producto Físico guardado correctamente.');
                                productoFisicoStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo guardar el Producto Físico.';
                                const op = batch.operations && batch.operations[0];
                                if (op && op.error && op.error.response) {
                                    try {
                                        const j = JSON.parse(op.error.response.responseText);
                                        if (j && j.error) msg = j.error;
                                    } catch (e) {}
                                }
                                Ext.Msg.alert('Error', msg);
                            }
                        });
                    }
                },
                { text: 'Cancelar', handler: () => win.close() }
            ]
        });
        win.show();
        win.down('form').loadRecord(rec);
    };

    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Productos Físicos',
        store: productoFisicoStore,
        itemId: 'productoFisicoPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 50 },
            { text: 'Nombre', dataIndex: 'nombre', flex: 1 },
            { text: 'Descripción', dataIndex: 'descripcion', flex: 1 },
            { text: 'Precio Unitario', dataIndex: 'precioUnitario', width: 120 },
            { text: 'Stock', dataIndex: 'stock', width: 100 },
            { text: 'ID Categoría', dataIndex: 'idCategoria', width: 100 },
            { text: 'Peso', dataIndex: 'peso', width: 90 },
            { text: 'Alto', dataIndex: 'alto', width: 90 },
            { text: 'Ancho', dataIndex: 'ancho', width: 90 },
            { text: 'Profundidad', dataIndex: 'profundidad', width: 110 }
        ],
        tbar: [
            {
                text: 'Agregar',
                handler: () => {
                    const rec = Ext.create('App.model.ProductoFisico', {});
                    openDialog(rec, true);
                }
            },
            {
                text: 'Editar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (sel.length === 0) {
                        Ext.Msg.alert('Atención', 'Seleccione un Producto Físico para editar.');
                        return;
                    }
                    openDialog(sel[0], false);
                }
            },
            {
                text: 'Eliminar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (sel.length === 0) {
                        Ext.Msg.alert('Atención', 'Seleccione un Producto Físico para eliminar.');
                        return;
                    }
                    Ext.Msg.confirm('Confirmar', '¿Seguro que desea eliminar?', (btn) => {
                        if (btn === 'yes') {
                            productoFisicoStore.remove(sel[0]);
                            productoFisicoStore.sync({
                                success: () => {
                                    Ext.Msg.alert('Éxito', 'Producto Físico eliminado correctamente.');
                                    productoFisicoStore.reload();
                                },
                                failure: (batch) => {
                                    let msg = 'No se pudo eliminar.';
                                    const op = batch.operations && batch.operations[0];
                                    if (op && op.error && op.error.response) {
                                        try {
                                            const j = JSON.parse(op.error.response.responseText);
                                            if (j && j.error) msg = j.error;
                                        } catch (e) {}
                                    }
                                    Ext.Msg.alert('Error', msg);
                                }
                            });
                        }
                    });
                }
            },
            '->',
            {
                text: 'Refrescar',
                handler: () => productoFisicoStore.reload()
            }
        ]
    });

    return grid;
};
