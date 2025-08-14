const createDetalleVentaPanel = () => {
    Ext.define('App.model.DetalleVenta', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'idVenta', type: 'int' },
            { name: 'lineNumber', type: 'int' },
            { name: 'idProducto', type: 'int' },
            { name: 'cantidad', type: 'int' },
            { name: 'precioUnitario', type: 'float' },
            { name: 'subtotal', type: 'float' }
        ]
    });

    const storeDetalleVenta = Ext.create('Ext.data.Store', {
        storeId: 'storeDetalleVenta',
        model: 'App.model.DetalleVenta',
        autoLoad: true,
        autosync: false,
        proxy: {
            type: 'rest',
            url: '/api/detalle_venta.php',
            reader: {
                type: 'json',
                rootProperty: ''
            },
            writers: {
                type: 'json',
                writeAllFields: true
            }
        }
    });

    const openDialog = (rec, isNew) => {
        const win = Ext.create('Ext.window.Window', {
            title: isNew ? 'Nuevo Detalle de Venta' : 'Editar Detalle de Venta',
            modal: true,
            layout: 'fit',
            width: 600,
            items: [{
                xtype: 'form',
                bodyPadding: 10,
                defaults: { anchor: '100%', msgTarget: 'side' },
                items: [
                    {
                        xtype: 'textfield',
                        name: 'idVenta',
                        fieldLabel: 'ID Venta',
                        allowBlank: false
                    },
                    {
                        xtype: 'numberfield',
                        name: 'lineNumber',
                        fieldLabel: 'Número de Línea',
                        allowBlank: false
                    },
                    {
                        xtype: 'textfield',
                        name: 'idProducto',
                        fieldLabel: 'ID Producto',
                        allowBlank: false
                    },
                    {
                        xtype: 'numberfield',
                        name: 'cantidad',
                        fieldLabel: 'Cantidad',
                        allowBlank: false,
                        listeners: {
                            change: function (field, newValue) {
                                const form = field.up('form').getForm();
                                const precio = form.findField('precioUnitario').getValue() || 0;
                                form.findField('subtotal').setValue((newValue || 0) * precio);
                            }
                        }
                    },
                    {
                        xtype: 'numberfield',
                        name: 'precioUnitario',
                        fieldLabel: 'Precio Unitario',
                        allowBlank: false,
                        listeners: {
                            change: function (field, newValue) {
                                const form = field.up('form').getForm();
                                const cantidad = form.findField('cantidad').getValue() || 0;
                                form.findField('subtotal').setValue(cantidad * (newValue || 0));
                            }
                        }
                    },
                    {
                        xtype: 'numberfield',
                        name: 'subtotal',
                        fieldLabel: 'Subtotal',
                        readOnly: true 
                    }
                ]
            }],
            buttons: [{
                text: 'Guardar',
                formBind: true,
                handler: () => {
                    const form = win.down('form').getForm();
                    if (!form.isValid()) return;
                    form.updateRecord(rec);
                    if (isNew) storeDetalleVenta.add(rec);
                    storeDetalleVenta.sync({
                        success: () => {
                            Ext.Msg.alert('Success', 'Detalle de venta guardado correctamente.');
                        },
                        failure: () => {
                            Ext.Msg.alert('Error', 'No se pudo guardar el detalle de venta.');
                        }
                    });
                }
            },
            {
                text: 'Cancelar',
                handler: () => win.close()
            }]
        
            
        });
        win.show();
        win.down('form').loadRecord(rec);
    };

    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Detalle Venta',
        store: storeDetalleVenta,
        columns: [
            { text: 'ID Venta', dataIndex: 'idVenta', flex: 1 },
            { text: 'Número de Línea', dataIndex: 'lineNumber', flex: 1 },
            { text: 'ID Producto', dataIndex: 'idProducto', flex: 1 },
            { text: 'Cantidad', dataIndex: 'cantidad', flex: 1 },
            { text: 'Precio Unitario', dataIndex: 'precioUnitario', flex: 1 },
            { text: 'Subtotal', dataIndex: 'subtotal', flex: 1 }
        ],
        tbar: [
            {
                text: 'Agregar',
                handler: () => openDialog(Ext.create('App.model.DetalleVenta'), true)
            },
            {
                text: 'Editar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection()[0];
                    if (sel.length === 0) {
                        Ext.Msg.alert('Error', 'Seleccione un registro para editar.');
                        return;
                    }
                    openDialog(sel[0], false);
                }
            },
            {
                text: 'Eliminar',
                handler: () => {
                    const rec = grid.getSelectionModel().getSelection()[0];
                    if (rec) {
                        storeDetalleVenta.remove(rec);
                        storeDetalleVenta.sync();
                    }
                }
            },
            '->',
            {
                text: 'Refrescar',
                handler: () => storeDetalleVenta.reload()
            }
        ]
    });

    return grid;
}