const createProductoFisicoPanel = () => {
    Ext.define('App.model.ProductoFisico', {
        extend: 'Ext.data.Model',
        fields: [
            { name: 'id', type: 'int' },
            { name: 'nombre', type: 'string' },
            { name: 'descripcion', type: 'string' },
            { name: 'precioUnitario', type: 'float' },
            { name: 'stock', type: 'int' },
            { name: 'idCategoria', type: 'int' },
            { name: 'peso', type: 'float' },
            { name: 'alto', type: 'float' },
            { name: 'ancho', type: 'float' },
            { name: 'profundidad', type: 'float' }
        ]
    });

    let productoFisicoStore = Ext.create('Ext.data.Store', {
        storeId: 'productoFisicoStore',
        model: 'App.model.ProductoFisico',
        proxy: {
            type: 'ajax',
            url: '/api/producto_fisico.php',
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
        title: 'Productos Físicos',
        store: productoFisicoStore,
        itemId: 'productoFisicoPanel',
        layout: 'fit',
        columns: [
            { text: 'ID', dataIndex: 'id', flex: 1 },
            { text: 'Nombre', dataIndex: 'nombre', flex: 2 },
            { text: 'Descripción', dataIndex: 'descripcion', flex: 2 },
            { text: 'Precio Unitario', dataIndex: 'precioUnitario', flex: 2 },
            { text: 'Stock', dataIndex: 'stock', flex: 2 },
            { text: 'ID Categoría', dataIndex: 'idCategoria', flex: 2 },
            { text: 'Peso', dataIndex: 'peso', flex: 2 },
            { text: 'Alto', dataIndex: 'alto', flex: 2 },
            { text: 'Ancho', dataIndex: 'ancho', flex: 2 },
            { text: 'Profundidad', dataIndex: 'profundidad', flex: 2 }
        ],
    });

    return grid;
};