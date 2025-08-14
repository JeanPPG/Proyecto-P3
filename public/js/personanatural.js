const createPersonaNaturalPanel = () => {
    Ext.define('App.model.PersonaNatural', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'email', type: 'string' },
            { name: 'telefono', type: 'string' },
            { name: 'direccion', type: 'string' },
            { name: 'tipo', type: 'string', defaultValue: 'NATURAL' },
            { name: 'nombres', type: 'string' },
            { name: 'apellidos', type: 'string' },
            { name: 'cedula', type: 'string' }
        ],
        idProperty: 'id'
    });

    const personaNaturalStore = Ext.create('Ext.data.Store', {
        storeId: 'personaNaturalStore',
        model: 'App.model.PersonaNatural',
        proxy: {
            type: 'ajax',
            url: '/api/persona_natural.php',
            // Acciones → métodos HTTP que tus controllers ya soportan
            actionMethods: {
                create:  'POST',
                read:    'GET',
                update:  'PUT',
                destroy: 'DELETE'
            },
            // No uses rootProperty: 'data' porque tu API responde array plano
            reader: {
                type: 'json',
                // Si el backend a veces devuelve {error: "..."} manejamos eso:
                transform: function (data) {
                    if (Array.isArray(data)) return data;
                    if (data && data.error) {
                        Ext.Msg.alert('Error', data.error);
                        return [];
                    }
                    // si viniera {success:true} u otra cosa, evitar romper
                    return data && data.data ? data.data : data;
                }
            },
            writer: {
                type: 'json',
                writeAllFields: true,
                allowSingle: true // manda objeto simple, no array
                // sin rootProperty para enviar JSON plano
            },
            // Evita enviar lotes complejos; 1 request por operación
            batchActions: false,
            // Manejo de errores de red/servidor
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
            title: isNew ? 'Nueva Persona Natural' : 'Editar Persona Natural',
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
                            value: 'NATURAL' // se fuerza en set() igual
                        },
                        { xtype: 'textfield', name: 'nombres', fieldLabel: 'Nombres', allowBlank: false },
                        { xtype: 'textfield', name: 'apellidos', fieldLabel: 'Apellidos', allowBlank: false },
                        { xtype: 'textfield', name: 'cedula', fieldLabel: 'Cédula', allowBlank: false, minLength: 10, maxLength: 10 }
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

                        // Refresca el record con valores del form
                        form.updateRecord(rec);
                        // Fuerza tipo NATURAL para el backend
                        rec.set('tipo', 'NATURAL');

                        if (isNew) {
                            personaNaturalStore.add(rec);
                        }

                        personaNaturalStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Persona Natural guardada correctamente.');
                                personaNaturalStore.reload();
                                win.close();
                            },
                            failure: (batch) => {
                                // intenta extraer error del server
                                let msg = 'No se pudo guardar la Persona Natural.';
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
        title: 'Personas Naturales',
        store: personaNaturalStore,
        itemId: 'personaNaturalPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 60 },
            { text: 'Email', dataIndex: 'email', flex: 2 },
            { text: 'Teléfono', dataIndex: 'telefono', flex: 1 },
            { text: 'Dirección', dataIndex: 'direccion', flex: 2 },
            { text: 'Tipo', dataIndex: 'tipo', width: 90 },
            { text: 'Nombres', dataIndex: 'nombres', flex: 1.2 },
            { text: 'Apellidos', dataIndex: 'apellidos', flex: 1.2 },
            { text: 'Cédula', dataIndex: 'cedula', width: 120 }
        ],
        tbar: [
            {
                text: 'Agregar',
                handler: () => {
                    const rec = Ext.create('App.model.PersonaNatural', { tipo: 'NATURAL' });
                    openDialog(rec, true);
                }
            },
            {
                text: 'Editar',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (sel.length === 0) {
                        Ext.Msg.alert('Atención', 'Seleccione una Persona Natural para editar.');
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
                        Ext.Msg.alert('Atención', 'Seleccione una Persona Natural para eliminar.');
                        return;
                    }
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
                handler: () => personaNaturalStore.reload()
            }
        ]
    });

    return grid;
};
