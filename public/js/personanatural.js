const createPersonaNaturalPanel = () => {
    Ext.define('App.model.PersonaNatural', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'email', type: 'string' },
            { name: 'telefono', type: 'string' },
            { name: 'direccion', type: 'string' },
            { name: 'tipo', type: 'string' },
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
    });

    return grid;
};