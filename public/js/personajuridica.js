const createPersonaJuridicaPanel = () => {
    Ext.define('App.model.PersonaJuridica', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'email', type: 'string' },
            { name: 'telefono', type: 'string' },
            { name: 'direccion', type: 'string' },
            { name: 'tipo', type: 'string', defaultValue: 'JURIDICA' },
            { name: 'razonSocial', type: 'string' },
            { name: 'ruc', type: 'string' },
            { name: 'representanteLegal', type: 'string' }
        ],
        idProperty: 'id'
    });

    const personaJuridicaStore = Ext.create('Ext.data.Store', {
        storeId: 'personaJuridicaStore',
        model: 'App.model.PersonaJuridica',
        proxy: {
            type: 'rest',
            url: '/api/persona_juridica.php',
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
            title: isNew ? 'Nueva Persona Jurídica' : 'Editar Persona Jurídica',
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
                        { xtype: 'textfield', name: 'email', fieldLabel: 'Email', allowBlank: false, vtype: 'email' },
                        { xtype: 'textfield', name: 'telefono', fieldLabel: 'Teléfono', allowBlank: false },
                        { xtype: 'textfield', name: 'direccion', fieldLabel: 'Dirección', allowBlank: false },
                        {
                            xtype: 'displayfield',
                            name: 'tipo',
                            fieldLabel: 'Tipo',
                            value: 'JURIDICA'
                        },
                        { xtype: 'textfield', name: 'razonSocial', fieldLabel: 'Razón Social', allowBlank: false },
                        { xtype: 'textfield', name: 'ruc', fieldLabel: 'RUC', allowBlank: false, minLength: 13, maxLength: 13 },
                        { xtype: 'textfield', name: 'representanteLegal', fieldLabel: 'Representante Legal', allowBlank: false }
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
                        rec.set('tipo', 'JURIDICA');

                        if (isNew) {
                            personaJuridicaStore.add(rec);
                        }

                        personaJuridicaStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Persona Jurídica guardada correctamente.');
                                personaJuridicaStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo guardar la Persona Jurídica.';
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
        title: 'Personas Jurídicas',
        store: personaJuridicaStore,
        itemId: 'personaJuridicaPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 60 },
            { text: 'Email', dataIndex: 'email', flex: 2 },
            { text: 'Teléfono', dataIndex: 'telefono', flex: 1 },
            { text: 'Dirección', dataIndex: 'direccion', flex: 2 },
            { text: 'Tipo', dataIndex: 'tipo', width: 90 },
            { text: 'Razón Social', dataIndex: 'razonSocial', flex: 1.5 },
            { text: 'RUC', dataIndex: 'ruc', width: 150 },
            { text: 'Representante Legal', dataIndex: 'representanteLegal', flex: 1.5 }
        ],
        tbar: [
            {
                text: 'Agregar',
                handler: () => {
                    const rec = Ext.create('App.model.PersonaJuridica', { tipo: 'JURIDICA' });
                    openDialog(rec, true);
                }
            },
            {
                text: 'Editar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (sel.length === 0) {
                        Ext.Msg.alert('Atención', 'Seleccione una Persona Jurídica para editar.');
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
                        Ext.Msg.alert('Atención', 'Seleccione una Persona Jurídica para eliminar.');
                        return;
                    }
                    Ext.Msg.confirm('Confirmar', '¿Seguro que desea eliminar?', (btn) => {
                        if (btn === 'yes') {
                            personaJuridicaStore.remove(sel[0]);
                            personaJuridicaStore.sync({
                                success: () => {
                                    Ext.Msg.alert('Éxito', 'Eliminado correctamente.');
                                    personaJuridicaStore.reload();
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
                handler: () => personaJuridicaStore.reload()
            }
        ]
    });

    return grid;
};
