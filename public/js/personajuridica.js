const createPersonaJuridicaPanel = () => {
    Ext.define('App.model.PersonaJuridica', {
        extend: 'Ext.data.Model',
        idProperty: 'id', 
        fields: [
            { name: 'id', type: 'int' },
            { name: 'email', type: 'string' },
            { name: 'telefono', type: 'string' },
            { name: 'direccion', type: 'string' },
            { name: 'tipo', type: 'string' },
            { name: 'razonSocial', type: 'string' },
            { name: 'ruc', type: 'string' },
            { name: 'representanteLegal', type: 'string' }
        ]
    });

    let personaJuridicaStore = Ext.create('Ext.data.Store', {
        storeId: 'personaJuridicaStore',
        model: 'App.model.PersonaJuridica',
        proxy: {
            type: 'rest',
            url: '/api/persona_juridica.php',
            appendId: true, 
            reader: {
                type: 'json',
                rootProperty: ''
            },
            writer: {
                type: 'json',
                writeAllFields: true
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
                        { xtype: 'textfield', name: 'tipo', fieldLabel: 'Tipo', allowBlank: false },
                        { xtype: 'textfield', name: 'razonSocial', fieldLabel: 'Razón Social', allowBlank: false },
                        { xtype: 'textfield', name: 'ruc', fieldLabel: 'RUC', allowBlank: false },
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
                        if (isNew) personaJuridicaStore.add(rec);

                        personaJuridicaStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Persona Jurídica guardada correctamente.');
                                win.close(); 
                            },
                            failure: () => {
                                Ext.Msg.alert('Error', 'No se pudo guardar la Persona Jurídica.');
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
    };

    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Personas Jurídicas',
        store: personaJuridicaStore,
        itemId: 'personaJuridicaPanel',
        layout: 'fit',
        columns: [
            { text: 'ID', dataIndex: 'id', flex: 1 },
            { text: 'Email', dataIndex: 'email', flex: 2 },
            { text: 'Teléfono', dataIndex: 'telefono', flex: 2 },
            { text: 'Dirección', dataIndex: 'direccion', flex: 3 },
            { text: 'Tipo', dataIndex: 'tipo', flex: 2 },
            { text: 'Razón Social', dataIndex: 'razonSocial', flex: 2 },
            { text: 'RUC', dataIndex: 'ruc', flex: 2 },
            { text: 'Representante Legal', dataIndex: 'representanteLegal', flex: 2 }
        ],
        tbar: [
            {
                text: 'Nuevo',
                iconCls: 'x-fa fa-plus',
                handler: () => openDialog(Ext.create('App.model.PersonaJuridica'), true)
            },
            {
                text: 'Editar',
                iconCls: 'x-fa fa-edit',
                handler: () => {
                    const selection = grid.getSelectionModel().getSelection();
                    if (selection.length > 0) {
                        openDialog(selection[0], false);
                    } else {
                        Ext.Msg.alert('Error', 'Seleccione una persona jurídica para editar.');
                    }
                }
            },
            {
                text: 'Eliminar',
                iconCls: 'x-fa fa-trash',
                handler: () => {
                    const selection = grid.getSelectionModel().getSelection();
                    if (selection.length > 0) {
                        Ext.Msg.confirm('Confirmación', '¿Seguro que desea eliminar la persona jurídica?', (btn) => {
                            if (btn === 'yes') {
                                personaJuridicaStore.remove(selection);
                                personaJuridicaStore.sync({
                                    success: () => {
                                        Ext.Msg.alert('Éxito', 'Persona Jurídica eliminada correctamente.');
                                    },
                                    failure: () => {
                                        Ext.Msg.alert('Error', 'No se pudo eliminar la Persona Jurídica.');
                                    }
                                });
                            }
                        });
                    } else {
                        Ext.Msg.alert('Error', 'Seleccione una persona jurídica para eliminar.');
                    }
                }
            }
        ]
    });

    return grid;
};
