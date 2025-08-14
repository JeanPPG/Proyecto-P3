const createPersonaNaturalPanel = () => {
    // Función para validar cédula ecuatoriana
    const validarCedulaEcuatoriana = (cedula) => {
        if (!cedula || cedula.length !== 10) return false;
        
        // Verificar que solo contenga números
        if (!/^\d{10}$/.test(cedula)) return false;
        
        // Verificar que los primeros dos dígitos correspondan a una provincia válida (01-24)
        const provincia = parseInt(cedula.substring(0, 2));
        if (provincia < 1 || provincia > 24) return false;
        
        // Algoritmo de validación del dígito verificador
        const coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
        let suma = 0;
        
        for (let i = 0; i < coeficientes.length; i++) {
            let valor = parseInt(cedula.charAt(i)) * coeficientes[i];
            if (valor >= 10) {
                valor -= 9;
            }
            suma += valor;
        }
        
        const digitoVerificador = parseInt(cedula.charAt(9));
        const modulo = suma % 10;
        const resultado = modulo === 0 ? 0 : 10 - modulo;
        
        return resultado === digitoVerificador;
    };

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
                        if (j && (j.error || j.message)) {
                            // Verificar si es un error específico de cédula
                            const errorMsg = j.error || j.message;
                            if (errorMsg.toLowerCase().includes('cedula') || 
                                errorMsg.toLowerCase().includes('cédula') ||
                                errorMsg.toLowerCase().includes('identificacion') ||
                                errorMsg.toLowerCase().includes('identificación')) {
                                msg = 'La cédula ingresada no es válida. Por favor verifique el número.';
                            } else {
                                msg = errorMsg;
                            }
                        }
                    } catch (e) {
                        // Si no se puede parsear la respuesta, mantener mensaje genérico
                        msg = 'Error de servidor';
                    }
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
                        regexText: 'La cédula debe tener 10 dígitos.',
                        validator: function(value) {
                            if (!value) return true; // Permitir vacío para que allowBlank maneje esto
                            if (!validarCedulaEcuatoriana(value)) {
                                return 'La cédula ingresada no es válida según el algoritmo de validación ecuatoriano.';
                            }
                            return true;
                        },
                        listeners: {
                            blur: function(field) {
                                // Validar en tiempo real cuando el usuario sale del campo
                                const value = field.getValue();
                                if (value && value.length === 10) {
                                    if (!validarCedulaEcuatoriana(value)) {
                                        field.markInvalid('La cédula ingresada no es válida.');
                                    }
                                }
                            }
                        }
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

                        // Validación adicional antes de enviar
                        const cedulaField = form.findField('cedula');
                        const cedulaValue = cedulaField.getValue();
                        
                        if (!validarCedulaEcuatoriana(cedulaValue)) {
                            Ext.Msg.alert('Error de Validación', 'La cédula ingresada no es válida. Por favor verifique el número.');
                            cedulaField.focus();
                            return;
                        }

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
                                        if (j && (j.error || j.message)) {
                                            const errorMsg = j.error || j.message;
                                            // Verificar si es un error específico de cédula
                                            if (errorMsg.toLowerCase().includes('cedula') || 
                                                errorMsg.toLowerCase().includes('cédula') ||
                                                errorMsg.toLowerCase().includes('identificacion') ||
                                                errorMsg.toLowerCase().includes('identificación')) {
                                                msg = 'La cédula ingresada no es válida o ya existe en el sistema.';
                                            } else {
                                                msg = errorMsg;
                                            }
                                        }
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