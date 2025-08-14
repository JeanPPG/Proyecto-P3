const createUsuarioPanel = () => {
    Ext.define('App.model.Usuario', {
        extend: 'Ext.data.Model',
        idProperty: 'id',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'username', type: 'string' },
            { name: 'passwordHash', type: 'string' },
            { name: 'estado', type: 'string', defaultValue: 'ACTIVO' }
        ]
    });

    const usuarioStore = Ext.create('Ext.data.Store', {
        storeId: 'usuarioStore',
        model: 'App.model.Usuario',
        autoLoad: true,
        autoSync: false,
        proxy: {
            type: 'rest',
            url: '/api/usuario.php',
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
                    const data = Ext.apply({}, record.getData());
                    if (!data.passwordHash || String(data.passwordHash).trim() === '') {
                        delete data.passwordHash;
                    }
                    return data;
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

    const openDialog = (rec, isNew) => {
        const win = Ext.create('Ext.window.Window', {
            title: isNew ? 'Nuevo Usuario' : 'Editar Usuario',
            modal: true,
            layout: 'fit',
            width: 420,
            items: [{
                xtype: 'form',
                bodyPadding: 12,
                defaults: { anchor: '100%', msgTarget: 'side', labelWidth: 110 },
                items: [
                    { xtype: 'hiddenfield', name: 'id' },
                    { xtype: 'textfield', name: 'username', fieldLabel: 'Usuario', allowBlank: false, minLength: 3, maxLength: 50 },
                    {
                        xtype: 'textfield',
                        name: 'passwordHash',
                        fieldLabel: isNew ? 'Contraseña' : 'Nueva contraseña',
                        inputType: 'password',
                        allowBlank: !isNew, 
                        emptyText: isNew ? '' : '(dejar en blanco para no cambiar)'
                    },
                    {
                        xtype: 'combo',
                        name: 'estado',
                        fieldLabel: 'Estado',
                        store: ['ACTIVO', 'INACTIVO', 'BLOQUEADO'],
                        forceSelection: true,
                        editable: false
                    }
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
                        if (isNew) usuarioStore.add(rec);

                        usuarioStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Usuario guardado correctamente.');
                                usuarioStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo guardar el usuario.';
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
            ],
            listeners: {
                show: () => win.down('form').loadRecord(rec)
            }
        });

        win.show();
    };

    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Usuarios',
        store: usuarioStore,
        itemId: 'usuarioPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 70 },
            { text: 'Usuario', dataIndex: 'username', flex: 1.4 },
            { text: 'Estado', dataIndex: 'estado', width: 130 }
        ],
        tbar: [
            { text: 'Agregar', handler: () => openDialog(Ext.create('App.model.Usuario', { estado: 'ACTIVO' }), true) },
            {
                text: 'Editar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione un usuario.');
                    openDialog(sel[0], false);
                }
            },
            {
                text: 'Eliminar', 
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Atención', 'Seleccione un usuario.');
                    Ext.Msg.confirm('Confirmar', '¿Seguro que desea eliminar este usuario?', (btn) => {
                        if (btn === 'yes') {
                            usuarioStore.remove(sel[0]); 
                            usuarioStore.sync({
                                success: () => {
                                    Ext.Msg.alert('Éxito', 'Usuario eliminado correctamente.');
                                    usuarioStore.reload();
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
                                    usuarioStore.reload();
                                }
                            });
                        }
                    });
                }
            },
            '->',
            { text: 'Refrescar', handler: () => usuarioStore.reload() }
        ]
    });

    return grid;
};
