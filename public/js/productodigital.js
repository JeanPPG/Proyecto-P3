const createProductoDigitalPanel = () => {
    Ext.define('App.model.ProductoDigital', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'nombre', type: 'string' },
            { name: 'descripcion', type: 'string' },
            { name: 'precioUnitario', type: 'float' },
            { name: 'stock', type: 'int' },
            { name: 'idCategoria', type: 'int' },
            { name: 'urlDescarga', type: 'string' },
            { name: 'licencia', type: 'string' }
        ]
    });

    let productoDigitalStore = Ext.create('Ext.data.Store', {
        storeId: 'productoDigitalStore',
        model: 'App.model.ProductoDigital',
        proxy: {
            type: 'ajax',
            url: '/api/producto_digital.php',
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
        title: 'Productos Digitales',
        store: productoDigitalStore,
        itemId: 'productoDigitalPanel',
        layout: 'fit',
        columns: [
            { text: 'ID', dataIndex: 'id', flex: 1 },
            { text: 'Nombre', dataIndex: 'nombre', flex: 2 },
            { text: 'Descripción', dataIndex: 'descripcion', flex: 2 },
            { text: 'Precio Unitario', dataIndex: 'precioUnitario', flex: 2 },
            { text: 'Stock', dataIndex: 'stock', flex: 2 },
            { text: 'ID Categoría', dataIndex: 'idCategoria', flex: 2 },
            { text: 'URL de Descarga', dataIndex: 'urlDescarga', flex: 2 },
            { text: 'Licencia', dataIndex: 'licencia', flex: 2 }
        ],
    });

    return grid;
};