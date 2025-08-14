const createPersonaJuridicaPanel = () => {
    Ext.define('App.model.PersonaJuridica', {
        extend: 'Ext.data.Model',
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
            type: 'ajax',
            url: '/api/persona_juridica.php',
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
        autoSync: false,
    });

    const grid = Ext.create('Ext.grid.Panel', {
        title: 'Personas Jurídicas',
        store: personaJuridicaStore,
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
        height: 400,
        width: 800,
        renderTo: Ext.getBody()
    });

    return grid;
};