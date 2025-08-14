const createFacturaPanel = () => {
    Ext.define('App.model.Factura', {
        extend: 'Ext.data.Model',
        idProperty: 'id',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'idVenta', type: 'int' },
            { name: 'numero', type: 'string' },
            { name: 'claveAcceso', type: 'string' },
            { name: 'fechaEmision', type: 'date', dateFormat: 'Y-m-d H:i:s' },
            { name: 'estado', type: 'string' } // PENDIENTE | ENVIADA | ANULADA
        ]
    });

    const facturaStore = Ext.create('Ext.data.Store', {
        storeId: 'facturaStore',
        model: 'App.model.Factura',
        autoLoad: true,
        autoSync: false,
        proxy: {
            type: 'rest',
            url: '/api/factura.php',
            appendId: true,
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
                allowSingle: true,
                getRecordData: function (record) {
                    const d = record.getData();
                    return {
                        idVenta: d.idVenta,
                        numero: d.numero,
                        claveAcceso: d.claveAcceso
                    };
                }
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

    const openCreateDialog = () => {
        const win = Ext.create('Ext.window.Window', {
            title: 'Nueva Factura',
            modal: true,
            layout: 'fit',
            width: 520,
            items: [{
                xtype: 'form',
                bodyPadding: 12,
                defaults: { anchor: '100%', msgTarget: 'side', labelWidth: 130 },
                items: [
                    { xtype: 'numberfield', name: 'idVenta', fieldLabel: 'ID Venta', allowBlank: false, minValue: 1 },
                    { xtype: 'textfield', name: 'numero', fieldLabel: 'Número', allowBlank: false, maxLength: 50 },
                    { xtype: 'textfield', name: 'claveAcceso', fieldLabel: 'Clave de Acceso', allowBlank: false, maxLength: 100 }
                ]
            }],
            buttons: [
                {
                    text: 'Crear',
                    handler: () => {
                        const form = win.down('form').getForm();
                        if (!form.isValid()) return;

                        const values = form.getValues();
                        const rec = Ext.create('App.model.Factura', values);

                        facturaStore.add(rec);
                        facturaStore.sync({
                            success: (batch) => {
                                Ext.Msg.alert('Éxito', 'Factura creada correctamente.');
                                facturaStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo crear la factura.';
                                const op = batch.operations && batch.operations[0];
                                if (op && op.error && op.error.response) {
                                    try {
                                        const j = JSON.parse(op.error.response.responseText);
                                        if (j && (j.error || j.message)) msg = j.error || j.message;
                                    } catch (e) {}
                                }
                                Ext.Msg.alert('Error', msg);
                                facturaStore.rejectChanges();
                            }
                        });
                    }
                },
                { text: 'Cancelar', handler: () => win.close() }
            ]
        });
        win.show();
    };

    const openEnviarDialog = (rec) => {
        const win = Ext.create('Ext.window.Window', {
            title: `Enviar Factura #${rec.get('id')}`,
            modal: true,
            layout: 'fit',
            width: 520,
            items: [{
                xtype: 'form',
                bodyPadding: 12,
                defaults: { anchor: '100%', msgTarget: 'side', labelWidth: 130 },
                items: [
                    { xtype: 'displayfield', fieldLabel: 'ID', value: rec.get('id') },
                    { xtype: 'displayfield', fieldLabel: 'Estado actual', value: rec.get('estado') },
                    { xtype: 'textfield', name: 'numero', fieldLabel: 'Número (opcional)', value: rec.get('numero') || '' },
                    { xtype: 'textfield', name: 'claveAcceso', fieldLabel: 'Clave Acceso (opcional)', value: rec.get('claveAcceso') || '' }
                ]
            }],
            buttons: [
                {
                    text: 'Enviar',
                    handler: () => {
                        const form = win.down('form').getForm();
                        const vals = form.getValues();
                        Ext.Ajax.request({
                            url: '/api/factura.php?action=enviar',
                            method: 'PUT',
                            jsonData: {
                                id: rec.get('id'),
                                ...(vals.numero ? { numero: vals.numero } : {}),
                                ...(vals.claveAcceso ? { claveAcceso: vals.claveAcceso } : {})
                            },
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Factura marcada como ENVIADA.');
                                facturaStore.reload();
                                win.close();
                            },
                            failure: (resp) => {
                                let msg = 'No se pudo marcar como ENVIADA.';
                                try {
                                    const j = JSON.parse(resp.responseText);
                                    if (j && (j.error || j.message)) msg = j.error || j.message;
                                } catch (e) {}
                                Ext.Msg.alert('Error', msg);
                            }
                        });
                    }
                },
                { text: 'Cancelar', handler: () => win.close() }
            ]
        });
        win.show();
    };

    const anularFactura = (rec) => {
        Ext.Msg.confirm('Confirmar', `¿Anular la factura #${rec.get('id')}?`, (btn) => {
            if (btn !== 'yes') return;
            Ext.Ajax.request({
                url: '/api/factura.php?action=anular',
                method: 'PUT',
                jsonData: { id: rec.get('id') },
                success: () => {
                    Ext.Msg.alert('Éxito', 'Factura ANULADA.');
                    facturaStore.reload();
                },
                failure: (resp) => {
                    let msg = 'No se pudo anular la factura.';
                    try {
                        const j = JSON.parse(resp.responseText);
                        if (j && (j.error || j.message)) msg = j.error || j.message;
                    } catch (e) {}
                    Ext.Msg.alert('Error', msg);
                }
            });
        });
    };

    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Facturas',
        store: facturaStore,
        itemId: 'facturaPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 70 },
            { text: 'ID Venta', dataIndex: 'idVenta', width: 100 },
            { text: 'Número', dataIndex: 'numero', width: 180 },
            { text: 'Clave de Acceso', dataIndex: 'claveAcceso', flex: 1.4 },
            { text: 'Fecha Emisión', dataIndex: 'fechaEmision', width: 160, renderer: v => v ? Ext.Date.format(new Date(v), 'Y-m-d H:i:s') : '' },
            { text: 'Estado', dataIndex: 'estado', width: 130 }
        ],
        tbar: [
            { text: 'Nueva', iconCls: 'x-fa fa-plus', handler: () => openCreateDialog() },
            {
                text: 'Enviar',
                iconCls: 'x-fa fa-paper-plane',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione una factura.');
                    const rec = sel[0];
                    if (rec.get('estado') === 'ENVIADA') {
                        return Ext.Msg.alert('Info', 'Esta factura ya está ENVIADA.');
                    }
                    openEnviarDialog(rec);
                }
            },
            {
                text: 'Anular',
                iconCls: 'x-fa fa-ban',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione una factura.');
                    const rec = sel[0];
                    if (rec.get('estado') === 'ANULADA') {
                        return Ext.Msg.alert('Info', 'Esta factura ya está ANULADA.');
                    }
                    anularFactura(rec);
                }
            },
            '->',
            { text: 'Refrescar', handler: () => facturaStore.reload() }
        ]
    });

    return grid;
};
