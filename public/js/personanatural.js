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
        ]
    });

    let personaNaturalStore = Ext.create('Ext.data.Store', {
        storeId: 'personaNaturalStore',
        model: 'App.model.PersonaNatural',
        proxy: {
            type: 'ajax',
            url: '/api/persona_natural.php',
            reader: {
                type: 'json',
                rootProperty: 'data'
            },
            writer: {
                type: 'json',
                writeAllFields: true,
                rootProperty: 'data'
            },
            appendId: false
        },
        autoLoad: true,
        autoSync: false
    });

    const openDialog = (rec, isNew) => {
        const win = Ext.create('Ext.window.Window', {
            title: isNew ? 'Nueva Persona Natural' : 'Editar Persona Natural',
            modal: true,
            layout: 'fit',
            items: [
                {
                    xtype: 'form',
                    bodyPadding: 10,
                    defaults: { anchor: '100%' },
                    items: [
                        { xtype: 'textfield', name: 'id', hidden: true },
                        { xtype: 'textfield', name: 'email', fieldLabel: 'Email', allowBlank: false },
                        { xtype: 'textfield', name: 'telefono', fieldLabel: 'Teléfono', allowBlank: false },
                        { xtype: 'textfield', name: 'direccion', fieldLabel: 'Dirección', allowBlank: false },
                        {
                            xtype: 'textfield',
                            name: 'tipo',
                            fieldLabel: 'Tipo',
                            value: 'NATURAL',
                            readOnly: true
                        },
                        { xtype: 'textfield', name: 'nombres', fieldLabel: 'Nombres', allowBlank: false },
                        { xtype: 'textfield', name: 'apellidos', fieldLabel: 'Apellidos', allowBlank: false },
                        { xtype: 'textfield', name: 'cedula', fieldLabel: 'Cédula', allowBlank: false }
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

                        rec.set('tipo', 'NATURAL');

                        form.updateRecord(rec);
                        if (isNew) personaNaturalStore.add(rec);

                        personaNaturalStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Persona Natural guardada correctamente.');
                                win.close();
                            },
                            failure: () => {
                                Ext.Msg.alert('Error', 'No se pudo guardar la Persona Natural.');
                            }
                        });
                    }
                },
                {
                    text: 'Cancelar',
                    handler: () => {
                        win.close();
                    }
                }
            ]
        });

        win.show();
        win.down('form').loadRecord(rec);
    }

    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Personas Naturales',
        store: personaNaturalStore,
        itemId: 'personaNaturalPanel',
        layout: 'fit',
        columns: [
            { text: 'ID', dataIndex: 'id', flex: 1 },
            { text: 'Email', dataIndex: 'email', flex: 2 },
            { text: 'Teléfono', dataIndex: 'telefono', flex: 2 },
            { text: 'Dirección', dataIndex: 'direccion', flex: 3 },
            { text: 'Tipo', dataIndex: 'tipo', flex: 2 },
            { text: 'Nombres', dataIndex: 'nombres', flex: 2 },
            { text: 'Apellidos', dataIndex: 'apellidos', flex: 2 },
            { text: 'Cédula', dataIndex: 'cedula', flex: 2 }
        ],
        tbar: [
            {
                text: 'Agregar Persona Natural',
                handler: () => {
                    const rec = Ext.create('App.model.PersonaNatural');
                    openDialog(rec, true);
                }
            },
            {
                text: 'Editar Persona Natural',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (sel.length === 0) {
                        Ext.Msg.alert('Error', 'Seleccione una Persona Natural para editar.');
                        return;
                    }
                    openDialog(sel[0], false);
                }
            },
            {
                text: 'Eliminar Persona Natural',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (sel.length === 0) {
                        Ext.Msg.alert('Error', 'Seleccione una Persona Natural para eliminar.');
                        return;
                    }
                    Ext.Msg.confirm('Confirmar', '¿Está seguro de eliminar la Persona Natural seleccionada?', (btn) => {
                        if (btn === 'yes') {
                            personaNaturalStore.remove(sel[0]);
                            personaNaturalStore.sync({
                                success: () => {
                                    Ext.Msg.alert('Éxito', 'Persona Natural eliminada correctamente.');
                                },
                                failure: () => {
                                    Ext.Msg.alert('Error', 'No se pudo eliminar la Persona Natural.');
                                }
                            });
                        }
                    });
                }
            }
        ]
    });

    return grid;
};