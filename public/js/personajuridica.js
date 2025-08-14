const createPersonaJuridicaPanel = () => {
    // Función para validar RUC ecuatoriano
    const validarRUCEcuatoriano = (ruc) => {
        if (!ruc || ruc.length !== 13) return false;
        
        // Verificar que solo contenga números
        if (!/^\d{13}$/.test(ruc)) return false;
        
        // Los primeros dos dígitos deben corresponder a una provincia válida (01-24)
        const provincia = parseInt(ruc.substring(0, 2));
        if (provincia < 1 || provincia > 24) return false;
        
        // El tercer dígito indica el tipo de RUC
        const tercerDigito = parseInt(ruc.charAt(2));
        
        // Para personas jurídicas, el tercer dígito debe ser 9
        if (tercerDigito === 9) {
            // RUC de persona jurídica (sociedad privada o extranjera)
            return validarRUCPersonaJuridica(ruc);
        } 
        // Para RUC de persona natural (6) o públicas (6)
        else if (tercerDigito === 6) {
            // RUC de persona natural o institución pública
            return validarRUCPersonaNatural(ruc);
        } 
        // Otros tipos válidos
        else if (tercerDigito >= 0 && tercerDigito <= 5) {
            // RUC de persona natural (usar algoritmo de cédula para los primeros 10 dígitos)
            return validarRUCPersonaNatural(ruc);
        }
        
        return false;
    };
    
    // Validación para RUC de persona jurídica (tercer dígito = 9)
    const validarRUCPersonaJuridica = (ruc) => {
        const coeficientes = [4, 3, 2, 7, 6, 5, 4, 3, 2];
        let suma = 0;
        
        for (let i = 0; i < coeficientes.length; i++) {
            suma += parseInt(ruc.charAt(i)) * coeficientes[i];
        }
        
        const residuo = suma % 11;
        const digitoVerificador = parseInt(ruc.charAt(9));
        
        if (residuo === 0) {
            return digitoVerificador === 0;
        } else if (residuo === 1) {
            return false; // No válido si el residuo es 1
        } else {
            return digitoVerificador === (11 - residuo);
        }
    };
    
    // Validación para RUC de persona natural (tercer dígito = 6 o 0-5)
    const validarRUCPersonaNatural = (ruc) => {
        // Usar algoritmo de cédula para los primeros 10 dígitos
        const coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
        let suma = 0;
        
        for (let i = 0; i < coeficientes.length; i++) {
            let valor = parseInt(ruc.charAt(i)) * coeficientes[i];
            if (valor >= 10) {
                valor -= 9;
            }
            suma += valor;
        }
        
        const digitoVerificador = parseInt(ruc.charAt(9));
        const modulo = suma % 10;
        const resultado = modulo === 0 ? 0 : 10 - modulo;
        
        // Los últimos 3 dígitos deben ser 001 para establecimientos
        const establecimiento = ruc.substring(10, 13);
        
        return resultado === digitoVerificador && establecimiento === "001";
    };

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
                            const errorMsg = j.error || j.message;
                            // Verificar si es un error específico de RUC
                            if (errorMsg.toLowerCase().includes('ruc') || 
                                errorMsg.toLowerCase().includes('identificacion') ||
                                errorMsg.toLowerCase().includes('identificación')) {
                                msg = 'El RUC ingresado no es válido. Por favor verifique el número.';
                            } else {
                                msg = errorMsg;
                            }
                        }
                    } catch (e) {
                        msg = 'Error de servidor';
                    }
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
                        { 
                            xtype: 'textfield', 
                            name: 'telefono', 
                            fieldLabel: 'Teléfono', 
                            allowBlank: false,
                            regex: /^[0-9]{7,10}$/,
                            regexText: 'Ingrese 7 a 10 dígitos.'
                        },
                        { xtype: 'textfield', name: 'direccion', fieldLabel: 'Dirección', allowBlank: false },
                        {
                            xtype: 'displayfield',
                            name: 'tipo',
                            fieldLabel: 'Tipo',
                            value: 'JURIDICA'
                        },
                        { xtype: 'textfield', name: 'razonSocial', fieldLabel: 'Razón Social', allowBlank: false },
                        { 
                            xtype: 'textfield', 
                            name: 'ruc', 
                            fieldLabel: 'RUC', 
                            allowBlank: false, 
                            minLength: 13, 
                            maxLength: 13,
                            regex: /^[0-9]{13}$/,
                            regexText: 'El RUC debe tener 13 dígitos.',
                            validator: function(value) {
                                if (!value) return true; // Permitir vacío para que allowBlank maneje esto
                                if (!validarRUCEcuatoriano(value)) {
                                    return 'El RUC ingresado no es válido según el algoritmo de validación ecuatoriano.';
                                }
                                return true;
                            },
                            listeners: {
                                blur: function(field) {
                                    // Validar en tiempo real cuando el usuario sale del campo
                                    const value = field.getValue();
                                    if (value && value.length === 13) {
                                        if (!validarRUCEcuatoriano(value)) {
                                            field.markInvalid('El RUC ingresado no es válido.');
                                        }
                                    }
                                }
                            }
                        },
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

                        // Validación adicional antes de enviar
                        const rucField = form.findField('ruc');
                        const rucValue = rucField.getValue();
                        
                        if (!validarRUCEcuatoriano(rucValue)) {
                            Ext.Msg.alert('Error de Validación', 'El RUC ingresado no es válido. Por favor verifique el número.');
                            rucField.focus();
                            return;
                        }

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
                                        if (j && (j.error || j.message)) {
                                            const errorMsg = j.error || j.message;
                                            // Verificar si es un error específico de RUC
                                            if (errorMsg.toLowerCase().includes('ruc') || 
                                                errorMsg.toLowerCase().includes('identificacion') ||
                                                errorMsg.toLowerCase().includes('identificación')) {
                                                msg = 'El RUC ingresado no es válido o ya existe en el sistema.';
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
                    if (isNew) rec.set('tipo', 'JURIDICA');
                }
            }
        });

        win.show();
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
                                            if (j && (j.error || j.message)) {
                                                const errorMsg = j.error || j.message;
                                                if (errorMsg.toLowerCase().includes('ruc')) {
                                                    msg = 'No se puede eliminar: el RUC está siendo utilizado por otros registros.';
                                                } else {
                                                    msg = errorMsg;
                                                }
                                            }
                                        } catch (e) {}
                                    }
                                    Ext.Msg.alert('Error', msg);
                                    personaJuridicaStore.reload();
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