const createPersonaNaturalPanel = () => {
    Ext.define('App.model.PersonaNatural', {
        extend: 'Ext.data.Model',
        idProperty: 'id',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'email', type: 'string' },
            { name: 'telefono', type: 'string' },
            { name: 'direccion', type: 'string' },
            { name: 'tipo', type: 'string', defaultValue: 'NATURAL' },
            { name: 'nombres', type: 'string' },
            { name: 'apellidos', type: 'string' },
            { name: 'cedula', type: 'string' }
        ]
    });

    const personaNaturalStore = Ext.create('Ext.data.Store', {
        storeId: 'personaNaturalStore',
        model: 'App.model.PersonaNatural',
        autoLoad: true,
        autoSync: false,
        proxy: {
            type: 'rest',                     
            url: '/api/persona_natural.php',
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
            title: isNew ? 'Nueva Persona Natural' : 'Editar Persona Natural',
            modal: true,
            layout: 'fit',
            width: 520,
            items: [{
                xtype: 'form',
                bodyPadding: 12,
                defaults: { anchor: '100%', msgTarget: 'side' },
                items: [
                    { xtype: 'hiddenfield', name: 'id' },
                    { xtype: 'textfield', name: 'email', fieldLabel: 'Email', allowBlank: false, vtype: 'email' },
                    { xtype: 'textfield', name: 'telefono', fieldLabel: 'Teléfono', allowBlank: false, regex: /^[0-9]{7,10}$/, regexText: 'Ingrese 7 a 10 dígitos.' },
                    { xtype: 'textfield', name: 'direccion', fieldLabel: 'Dirección', allowBlank: false },
                    { xtype: 'displayfield', name: 'tipo', fieldLabel: 'Tipo', value: 'NATURAL' },
                    { xtype: 'textfield', name: 'nombres', fieldLabel: 'Nombres', allowBlank: false },
                    { xtype: 'textfield', name: 'apellidos', fieldLabel: 'Apellidos', allowBlank: false },
                    {
                        xtype: 'textfield',
                        name: 'cedula',
                        fieldLabel: 'Cédula',
                        allowBlank: false,
                        minLength: 10,
                        maxLength: 10,
                        regex: /^[0-9]{10}$/,
                        regexText: 'La cédula debe tener 10 dígitos.'
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
                        rec.set('tipo', 'NATURAL');

                        if (isNew) personaNaturalStore.add(rec);

                        personaNaturalStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Persona Natural guardada correctamente.');
                                personaNaturalStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo guardar la Persona Natural.';
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
                show: () => {
                    win.down('form').loadRecord(rec);
                    if (isNew) rec.set('tipo', 'NATURAL');
                }
            }
        });

        win.show();
    };

    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Personas Naturales',
        store: personaNaturalStore,
        itemId: 'personaNaturalPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 60 },
            { text: 'Email', dataIndex: 'email', flex: 1.6 },
            { text: 'Teléfono', dataIndex: 'telefono', width: 140 },
            { text: 'Dirección', dataIndex: 'direccion', flex: 1.6 },
            { text: 'Tipo', dataIndex: 'tipo', width: 90 },
            { text: 'Nombres', dataIndex: 'nombres', flex: 1.2 },
            { text: 'Apellidos', dataIndex: 'apellidos', flex: 1.2 },
            { text: 'Cédula', dataIndex: 'cedula', width: 140 }
        ],
        tbar: [
            {
                text: 'Agregar',
                handler: () => openDialog(Ext.create('App.model.PersonaNatural', { tipo: 'NATURAL' }), true)
            },
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
                            personaNaturalStore.remove(sel[0]);
                            personaNaturalStore.sync({
                                success: () => {
                                    Ext.Msg.alert('Éxito', 'Eliminado correctamente.');
                                    personaNaturalStore.reload();
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
                                    personaNaturalStore.reload(); 
                                }
                            });
                        }
                    });
                }
            },
            '->',
            { text: 'Refrescar', handler: () => personaNaturalStore.reload() }
        ]
    });

    return grid;
};
