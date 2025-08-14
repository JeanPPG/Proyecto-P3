const createRolPanel = () => {
    Ext.define('App.model.Rol', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'nombre', type: 'string' }
        ],
        idProperty: 'id'
    });

    const rolStore = Ext.create('Ext.data.Store', {
        storeId: 'rolStore',
        model: 'App.model.Rol',
        proxy: {
            type: 'rest',
            url: '/api/rol.php',
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
            title: isNew ? 'Nuevo Rol' : 'Editar Rol',
            modal: true,
            layout: 'fit',
            width: 520,
            items: [
                {
                    xtype: 'form',
                    bodyPadding: 12,
                    defaults: { anchor: '100%', msgTarget: 'side' },
                    items: [
                        { xtype: 'hiddenfield', name: 'id' },
                        { xtype: 'textfield', name: 'nombre', fieldLabel: 'Nombre', allowBlank: false }
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
                            rolStore.add(rec);
                        }

                        rolStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Rol guardado correctamente.');
                                rolStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo guardar el Rol.';
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
        title: 'Roles',
        store: rolStore,
        itemId: 'rolPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 60 },
            { text: 'Nombre', dataIndex: 'nombre', flex: 1 }
        ],
        tbar: [
            {
                text: 'Agregar',
                handler: () => {
                    const rec = Ext.create('App.model.Rol', {});
                    openDialog(rec, true);
                }
            },
            {
                text: 'Editar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (sel.length === 0) {
                        Ext.Msg.alert('Atención', 'Seleccione un Rol para editar.');
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
                        Ext.Msg.alert('Atención', 'Seleccione un Rol para eliminar.');
                        return;
                    }
                    Ext.Msg.confirm('Confirmar', '¿Seguro que desea eliminar?', (btn) => {
                        if (btn === 'yes') {
                            rolStore.remove(sel[0]);
                            rolStore.sync({
                                success: () => {
                                    Ext.Msg.alert('Éxito', 'Eliminado correctamente.');
                                    rolStore.reload();
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
                handler: () => rolStore.reload()
            }
        ]
    });

    return grid;
};