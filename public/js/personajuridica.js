// personajuridica.js
const createPersonaJuridicaPanel = () => {
    // ===== Model =====
    Ext.define('App.model.PersonaJuridica', {
        extend: 'Ext.data.Model',
        idProperty: 'id',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'email', type: 'string' },
            { name: 'telefono', type: 'string' },
            { name: 'direccion', type: 'string' },
            { name: 'tipo', type: 'string', defaultValue: 'JURIDICA' },
            { name: 'razonSocial', type: 'string' },
            { name: 'ruc', type: 'string' },
            { name: 'representanteLegal', type: 'string' }
        ]
    });

    // ===== Store =====
    const personaJuridicaStore = Ext.create('Ext.data.Store', {
        storeId: 'personaJuridicaStore',
        model: 'App.model.PersonaJuridica',
        autoLoad: true,
        autoSync: false,
        proxy: {
            // Usamos ajax porque tu backend acepta PUT/POST en la MISMA URL sin /{id}
            type: 'ajax',
            url: '/api/persona_juridica.php',
            actionMethods: { create: 'POST', read: 'GET', update: 'PUT', destroy: 'DELETE' },
            headers: { 'Content-Type': 'application/json' },
            reader: {
                type: 'json',
                transform: function (data) {
                    // Aceptar: [ ... ]  |  { data: [...] }  |  { error: "..." }  |  { message: "..." }
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
                writeRecordId: true,
                allowSingle: true,
                // Garantizamos que el body sea JSON puro (no form-data)
                getRecordData: function (record) {
                    const data = Ext.apply({}, record.getData());
                    // El backend ya fuerza tipo, pero enviarlo no causa daño
                    data.tipo = 'JURIDICA';
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

    // ===== Ventana (Crear/Editar) =====
    const openDialog = (rec, isNew) => {
        const win = Ext.create('Ext.window.Window', {
            title: isNew ? 'Nueva Persona Jurídica' : 'Editar Persona Jurídica',
            modal: true,
            layout: 'fit',
            width: 560,
            items: [{
                xtype: 'form',
                bodyPadding: 12,
                defaults: { anchor: '100%', msgTarget: 'side', labelWidth: 150 },
                items: [
                    { xtype: 'hiddenfield', name: 'id' },
                    { xtype: 'textfield', name: 'email', fieldLabel: 'Email', allowBlank: false, vtype: 'email' },
                    {
                        xtype: 'textfield', name: 'telefono', fieldLabel: 'Teléfono', allowBlank: false,
                        regex: /^[0-9]{7,10}$/, regexText: 'Ingrese 7 a 10 dígitos.'
                    },
                    { xtype: 'textfield', name: 'direccion', fieldLabel: 'Dirección', allowBlank: false },

                    { xtype: 'displayfield', name: 'tipo', fieldLabel: 'Tipo', value: 'JURIDICA' },

                    { xtype: 'textfield', name: 'razonSocial', fieldLabel: 'Razón Social', allowBlank: false },

                    // Validación de RUC (13 dígitos + dígito 3 = 9 por defecto; cambia a /(6|9)/ si aceptas públicas)
                    {
                        xtype: 'textfield', name: 'ruc', fieldLabel: 'RUC', allowBlank: false, minLength: 13, maxLength: 13,
                        validator: function (val) {
                            const v = String(val || '').trim();
                            if (!/^[0-9]{13}$/.test(v)) return 'RUC debe tener 13 dígitos.';
                            // Política: privadas (9). Si también públicas: if (!/[69]/.test(v.charAt(2))) ...
                            if (v.charAt(2) !== '9') return 'Para persona jurídica privada, el 3.er dígito debe ser 9.';
                            return true;
                        }
                    },

                    { xtype: 'textfield', name: 'representanteLegal', fieldLabel: 'Representante Legal', allowBlank: true }
                ]
            }],
            buttons: [
                {
                    text: 'Guardar',
                    formBind: true,
                    handler: () => {
                        const form = win.down('form').getForm();
                        if (!form.isValid()) return;

                        // Forzar tipo correcto siempre
                        rec.set('tipo', 'JURIDICA');

                        // Pasar valores del form al record
                        form.updateRecord(rec);

                        // Si es nuevo, agregarlo al store antes de sync
                        if (isNew) personaJuridicaStore.add(rec);

                        personaJuridicaStore.sync({
                            success: () => {
                                Ext.Msg.alert('Éxito', 'Persona Jurídica guardada correctamente.');
                                win.close();
                                personaJuridicaStore.reload();
                            },
                            failure: (batch) => {
                                let msg = 'No se pudo guardar la Persona Jurídica.';
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
                    if (isNew) rec.set('tipo', 'JURIDICA');
                }
            }
        });

        win.show();
    };

    // ===== Grid =====
    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Personas Jurídicas',
        store: personaJuridicaStore,
        itemId: 'personaJuridicaPanel',
        layout: 'fit',
        selModel: { selType: 'rowmodel', mode: 'SINGLE' },
        columns: [
            { text: 'ID', dataIndex: 'id', width: 70 },
            { text: 'Email', dataIndex: 'email', flex: 1.6 },
            { text: 'Teléfono', dataIndex: 'telefono', width: 140 },
            { text: 'Dirección', dataIndex: 'direccion', flex: 1.6 },
            { text: 'Tipo', dataIndex: 'tipo', width: 110 },
            { text: 'Razón Social', dataIndex: 'razonSocial', flex: 1.3 },
            { text: 'RUC', dataIndex: 'ruc', width: 160 },
            { text: 'Representante Legal', dataIndex: 'representanteLegal', flex: 1.2 }
        ],
        tbar: [
            {
                text: 'Agregar',
                iconCls: 'x-fa fa-plus',
                handler: () => openDialog(Ext.create('App.model.PersonaJuridica', { tipo: 'JURIDICA' }), true)
            },
            {
                text: 'Editar',
                iconCls: 'x-fa fa-edit',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Error', 'Seleccione un registro.');
                    openDialog(sel[0], false);
                }
            },
            {
                text: 'Eliminar',
                iconCls: 'x-fa fa-trash',
                handler: () => {
                    const sel = grid.getSelectionModel().getSelection();
                    if (!sel.length) return Ext.Msg.alert('Error', 'Seleccione un registro.');
                    Ext.Msg.confirm('Confirmación', '¿Seguro que desea eliminar la persona jurídica?', (btn) => {
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
                                            if (j && (j.error || j.message)) msg = j.error || j.message;
                                        } catch (e) {}
                                    }
                                    Ext.Msg.alert('Error', msg);
                                    personaJuridicaStore.reload(); // revertir UI
                                }
                            });
                        }
                    });
                }
            },
            '->',
            { text: 'Refrescar', handler: () => personaJuridicaStore.reload() }
        ]
    });

    return grid;
};
