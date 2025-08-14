// productodigital.js (versión REST unificada)
const createProductoDigitalPanel = () => {
    Ext.define('App.model.ProductoDigital', {
        extend: 'Ext.data.Model',
        idProperty: 'id',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'nombre', type: 'string' },
            { name: 'descripcion', type: 'string' },
            { name: 'precioUnitario', type: 'float' },
            { name: 'stock', type: 'int' },
            { name: 'idCategoria', type: 'int' },
            { name: 'urlDescarga', type: 'string' },
            { name: 'licencia', type: 'string' }
        ]
    });

    const productoDigitalStore = Ext.create('Ext.data.Store', {
        storeId: 'productoDigitalStore',
        model: 'App.model.ProductoDigital',
        autoLoad: true,
        autoSync: false,
        proxy: {
            type: 'rest',
            url: '/api/producto_digital.php',
            reader: {
                type: 'json',
                transform: function (data) {
                    if (Array.isArray(data)) return data;
                    if (data && (data.error || data.message)) {
                        Ext.Msg.alert('Error', data.error || data.message);
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
                        if (j && (j.error || j.message)) msg = j.error || j.message;
                    } catch (e) {}
                    Ext.Msg.alert('Error', msg);
                }
            }
        }
    });

    const openDialog = (rec, isNew) => {
        const win = Ext.create('Ext.window.Window', {
            title: isNew ? 'Nuevo Producto Digital' : 'Editar Producto Digital',
            modal: true,
            layout: 'fit',
            width: 560,
            items: [{
                xtype: 'form',
                bodyPadding: 12,
                defaults: { anchor: '100%', msgTarget: 'side', labelWidth: 140 },
                items: [
                    { xtype: 'hiddenfield', name: 'id' },
                    { xtype: 'textfield', name: 'nombre', fieldLabel: 'Nombre', allowBlank: false },
                    { xtype: 'textarea', name: 'descripcion', fieldLabel: 'Descripción' },
                    { xtype: 'numberfield', name: 'precioUnitario', fieldLabel: 'Precio Unitario', allowBlank: false, minValue: 0 },
                    { xtype: 'numberfield', name: 'stock', fieldLabel: 'Stock', allowBlank: false, minValue: 0 },
                    { xtype: 'numberfield', name: 'idCategoria', fieldLabel: 'ID Categoría', allowBlank: false, minValue: 1 },
                    {
                        xtype: 'textfield', name: 'urlDescarga', fieldLabel: 'URL de Descarga',
                        allowBlank: false, vtype: 'url'
                    },
                    { xtype: 'textfield', name: 'licencia', fieldLabel: 'Licencia', allowBlank: false }
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
                        if (isNew) productoDigitalStore.add(rec);

                        productoDigitalStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Producto Digital guardado correctamente.');
                                productoDigitalStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo guardar el Producto Digital.';
                                const op = batch.operations && batch.operations[0];
                                if (op && op.error && op.error.response) {
                                    try {
                                        const j = JSON.parse(op.error.response.responseText);
                                        if (j && (j.error || j.message)) msg = j.error || j.message;
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
        title: 'Productos Digitales',
        store: productoDigitalStore,
        itemId: 'productoDigitalPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 60 },
            { text: 'Nombre', dataIndex: 'nombre', flex: 1.2 },
            { text: 'Descripción', dataIndex: 'descripcion', flex: 1.4 },
            { text: 'Precio Unitario', dataIndex: 'precioUnitario', width: 130 },
            { text: 'Stock', dataIndex: 'stock', width: 100 },
            { text: 'ID Categoría', dataIndex: 'idCategoria', width: 120 },
            { text: 'URL de Descarga', dataIndex: 'urlDescarga', flex: 1.6 },
            { text: 'Licencia', dataIndex: 'licencia', flex: 1.0 }
        ],
        tbar: [
            { text: 'Agregar', handler: () => openDialog(Ext.create('App.model.ProductoDigital', {}), true) },
            {
                text: 'Editar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione un registro.');
                    openDialog(sel[0], false);
                }
            },
            {
                text: 'Eliminar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione un registro.');
                    Ext.Msg.confirm('Confirmar', '¿Seguro que desea eliminar?', (btn) => {
                        if (btn === 'yes') {
                            productoDigitalStore.remove(sel[0]);
                            productoDigitalStore.sync({
                                success: () => {
                                    Ext.Msg.alert('Éxito', 'Producto Digital eliminado correctamente.');
                                    productoDigitalStore.reload();
                                },
                                failure: (batch) => {
                                    let msg = 'No se pudo eliminar.';
                                    const op = batch.operations && batch.operations[0];
                                    if (op && op.error && op.error.response) {
                                        try {
                                            const j = JSON.parse(op.error.response.responseText);
                                            if (j && (j.error || j.message)) msg = j.error || j.message;
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
            { text: 'Refrescar', handler: () => productoDigitalStore.reload() }
        ]
    });

    return grid;
};
