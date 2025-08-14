const createVentaPanel = () => {
    Ext.define('App.model.Venta', {
        extend: 'Ext.data.Model',
        idProperty: 'id',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'fecha', type: 'date', dateFormat: 'Y-m-d H:i:s' },
            { name: 'idCliente', type: 'int' },
            { name: 'total', type: 'float' },
            { name: 'estado', type: 'string' } // BORRADOR | EMITIDA | ANULADA
        ]
    });

    const ventaStore = Ext.create('Ext.data.Store', {
        storeId: 'ventaStore',
        model: 'App.model.Venta',
        autoLoad: true,
        autoSync: false,
        proxy: {
            type: 'rest',
            url: '/api/venta.php',
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
                allowSingle: true,
                writeAllFields: true,

                getRecordData: function (record) {
                    const d = record.getData();
                    if (record.phantom) {
                        return { idCliente: d.idCliente };
                    }
                    const changes = record.getChanges() || {};
                    const payload = { id: d.id };
                    if ('idCliente' in changes) payload.idCliente = d.idCliente;
                    if ('total' in changes)     payload.total     = d.total;
                    if ('estado' in changes)    payload.estado    = d.estado;
                    // si no hay cambios, igual manda id para que no falle
                    return Object.keys(payload).length ? payload : { id: d.id };
                }
            },
            batchActions: false,
            listeners: {
                exception: function (proxy, response) {
                    let msg = 'Error de servidor';
                    try {
                        const j = JSON.parse(response.responseText);
                        if (j && (j.error || j.message)) msg = j.error || j.message;
                    } catch (e) { /* ignore */ }
                    Ext.Msg.alert('Error', msg);
                }
            }
        }
    });

    const openCreateDialog = () => {
        const win = Ext.create('Ext.window.Window', {
            title: 'Nueva Venta (BORRADOR)',
            modal: true,
            layout: 'fit',
            width: 420,
            items: [{
                xtype: 'form',
                bodyPadding: 12,
                defaults: { anchor: '100%', msgTarget: 'side', labelWidth: 120 },
                items: [
                    { xtype: 'numberfield', name: 'idCliente', fieldLabel: 'ID Cliente', allowBlank: false, minValue: 1 },
                    { xtype: 'displayfield', fieldLabel: 'Estado', value: 'BORRADOR' }
                ]
            }],
            buttons: [
                {
                    text: 'Crear',
                    handler: () => {
                        const form = win.down('form').getForm();
                        if (!form.isValid()) return;
                        const rec = Ext.create('App.model.Venta', form.getValues());
                        ventaStore.add(rec);
                        ventaStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Venta creada.');
                                ventaStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo crear la venta.';
                                const op = batch.operations && batch.operations[0];
                                if (op?.error?.response?.responseText) {
                                    try {
                                        const j = JSON.parse(op.error.response.responseText);
                                        if (j?.error || j?.message) msg = j.error || j.message;
                                    } catch (e) {}
                                }
                                Ext.Msg.alert('Error', msg);
                                ventaStore.rejectChanges();
                            }
                        });
                    }
                },
                { text: 'Cancelar', handler: () => win.close() }
            ]
        });
        win.show();
    };

    const openEditDialog = (rec) => {
        const win = Ext.create('Ext.window.Window', {
            title: `Editar Venta #${rec.get('id')}`,
            modal: true,
            layout: 'fit',
            width: 460,
            items: [{
                xtype: 'form',
                bodyPadding: 12,
                defaults: { anchor: '100%', msgTarget: 'side', labelWidth: 120 },
                items: [
                    { xtype: 'displayfield', fieldLabel: 'ID', value: rec.get('id') },
                    { xtype: 'displayfield', fieldLabel: 'Fecha', value: rec.get('fecha') ? Ext.Date.format(rec.get('fecha'), 'Y-m-d H:i:s') : '' },
                    { xtype: 'numberfield', name: 'idCliente', fieldLabel: 'ID Cliente', minValue: 1, value: rec.get('idCliente'), allowBlank: false },
                    { xtype: 'numberfield', name: 'total', fieldLabel: 'Total', value: rec.get('total'), minValue: 0, decimalPrecision: 2 },
                    {
                        xtype: 'combo',
                        name: 'estado',
                        fieldLabel: 'Estado',
                        store: ['BORRADOR', 'EMITIDA', 'ANULADA'],
                        forceSelection: true,
                        editable: false,
                        value: rec.get('estado')
                    }
                ]
            }],
            buttons: [
                {
                    text: 'Guardar',
                    handler: () => {
                        const form = win.down('form').getForm();
                        if (!form.isValid()) return;
                        rec.set(form.getValues());
                        ventaStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Venta actualizada.');
                                ventaStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo actualizar.';
                                const op = batch.operations && batch.operations[0];
                                if (op?.error?.response?.responseText) {
                                    try {
                                        const j = JSON.parse(op.error.response.responseText);
                                        if (j?.error || j?.message) msg = j.error || j.message;
                                    } catch (e) {}
                                }
                                Ext.Msg.alert('Error', msg);
                                ventaStore.rejectChanges();
                            }
                        });
                    }
                },
                { text: 'Cancelar', handler: () => win.close() }
            ]
        });
        win.show();
    };

    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Ventas',
        store: ventaStore,
        itemId: 'ventaPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 70 },
            { text: 'Fecha', dataIndex: 'fecha', width: 160, renderer: v => v ? Ext.Date.format(new Date(v), 'Y-m-d H:i:s') : '' },
            { text: 'ID Cliente', dataIndex: 'idCliente', width: 120 },
            { text: 'Total', dataIndex: 'total', width: 110, align: 'right', renderer: v => Ext.util.Format.number(v, '0,0.00') },
            { text: 'Estado', dataIndex: 'estado', width: 120 }
        ],
        tbar: [
            { text: 'Nueva', iconCls: 'x-fa fa-plus', handler: openCreateDialog },
            {
                text: 'Editar',
                iconCls: 'x-fa fa-edit',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione una venta.');
                    openEditDialog(sel[0]);
                }
            },
            {
                text: 'Emitir',
                iconCls: 'x-fa fa-paper-plane',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione una venta.');
                    const rec = sel[0];
                    if (rec.get('estado') === 'EMITIDA') return Ext.Msg.alert('Info', 'Ya está EMITIDA.');
                    rec.set('estado', 'EMITIDA');
                    ventaStore.sync({
                        success: () => { Ext.Msg.alert('Éxito', 'Venta emitida.'); ventaStore.reload(); },
                        failure: () => { Ext.Msg.alert('Error', 'No se pudo emitir.'); ventaStore.rejectChanges(); }
                    });
                }
            },
            {
                text: 'Anular',
                iconCls: 'x-fa fa-ban',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione una venta.');
                    const rec = sel[0];
                    if (rec.get('estado') === 'ANULADA') return Ext.Msg.alert('Info', 'Ya está ANULADA.');
                    rec.set('estado', 'ANULADA');
                    ventaStore.sync({
                        success: () => { Ext.Msg.alert('Éxito', 'Venta anulada.'); ventaStore.reload(); },
                        failure: () => { Ext.Msg.alert('Error', 'No se pudo anular.'); ventaStore.rejectChanges(); }
                    });
                }
            },
            {
                text: 'Eliminar',
                iconCls: 'x-fa fa-trash',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione una venta.');
                    Ext.Msg.confirm('Confirmar', '¿Seguro que desea eliminar?', (btn) => {
                        if (btn !== 'yes') return;
                        ventaStore.remove(sel[0]);
                        ventaStore.sync({
                            success: () => { Ext.Msg.alert('Éxito', 'Venta eliminada.'); ventaStore.reload(); },
                            failure: (batch) => {
                                let msg = 'No se pudo eliminar.';
                                const op = batch.operations && batch.operations[0];
                                if (op?.error?.response?.responseText) {
                                    try {
                                        const j = JSON.parse(op.error.response.responseText);
                                        if (j?.error || j?.message) msg = j.error || j.message;
                                    } catch (e) {}
                                }
                                Ext.Msg.alert('Error', msg);
                                ventaStore.rejectChanges();
                            }
                        });
                    });
                }
            },
            '->',
            { text: 'Refrescar', handler: () => ventaStore.reload() }
        ]
    });

    return grid;
};
