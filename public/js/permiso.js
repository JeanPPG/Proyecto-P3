const createPermisoPanel = () => {
    Ext.define('App.model.Permiso', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'codigo', type: 'string' }
        ],
        idProperty: ['id'] 
    });

    const permisoStore = Ext.create('Ext.data.Store', {
        storeId: 'permisoStore',
        model: 'App.model.Permiso',
        proxy: {
            type: 'rest',
            url: '/api/permiso.php', // Asumiendo que la API es para RolPermiso
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
            title: isNew ? 'Nuevo Permiso' : 'Editar Permiso',
            modal: true,
            layout: 'fit',
            width: 520,
            items: [
                {
                    xtype: 'form',
                    bodyPadding: 12,
                    defaults: { anchor: '100%', msgTarget: 'side' },
                    items: [
                        { xtype: 'numberfield', name: 'id', fieldLabel: 'ID Rol', allowBlank: false },
                        { xtype: 'textfield', name: 'codigo', fieldLabel: 'Código', allowBlank: false }
                    ]
                }
            ],
            buttons: [
                {
                    text: 'Guardar',
                    formBind: true,
                    handler: () => {
                        const form = win.down('form').getForm();
                        if (!form.isValid()) return;

                        form.updateRecord(rec);

                        if (isNew) {
                            permisoStore.add(rec);
                        }

                        permisoStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Permiso guardado correctamente.');
                                permisoStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo guardar el Permiso.';
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
        title: 'Permisos',
        store: permisoStore,
        itemId: 'permisoPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID Rol', dataIndex: 'id', width: 100 },
            { text: 'Código', dataIndex: 'codigo', flex: 1 }
        ],
        tbar: [
            {
                text: 'Agregar',
                handler: () => {
                    const rec = Ext.create('App.model.Permiso', {});
                    openDialog(rec, true);
                }
            },
            {
                text: 'Editar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (sel.length === 0) {
                        Ext.Msg.alert('Atención', 'Seleccione un Permiso para editar.');
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
                        Ext.Msg.alert('Atención', 'Seleccione un Permiso para eliminar.');
                        return;
                    }
                    Ext.Msg.confirm('Confirmar', '¿Seguro que desea eliminar?', (btn) => {
                        if (btn === 'yes') {
                            permisoStore.remove(sel[0]);
                            permisoStore.sync({
                                success: () => {
                                    Ext.Msg.alert('Éxito', 'Eliminado correctamente.');
                                    permisoStore.reload();
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
                handler: () => permisoStore.reload()
            }
        ]
    });

    return grid;
};