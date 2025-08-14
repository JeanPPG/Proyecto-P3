Ext.onReady(() => {
    const personaJuridicaPanel = createPersonaJuridicaPanel();
    const personaNaturalPanel  = createPersonaNaturalPanel();
    const productoFisicoPanel  = createProductoFisicoPanel();
    const productoDigitalPanel = createProductoDigitalPanel();
    const usuarioPanel         = createUsuarioPanel();
    const facturaPanel        = createFacturaPanel();
    const ventaPanel          = createVentaPanel();
    const detalleVentaPanel   = createDetalleVentaPanel();

    const mainCard = Ext.create('Ext.panel.Panel', {
        region: 'center',
        layout: 'card',
        items: [
            personaJuridicaPanel,
            personaNaturalPanel,
            productoFisicoPanel,
            productoDigitalPanel,
            usuarioPanel,
            facturaPanel,
            ventaPanel,
            detalleVentaPanel
        ],
    });

    Ext.create('Ext.container.Viewport', {
        id: 'mainViewport',
        layout: 'border',
        items: [
            {
                region: 'north',
                xtype: 'toolbar',
                items: [
                    {
                        text: 'Persona Jurídica',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(personaJuridicaPanel);
                        }
                    },
                    {
                        text: 'Persona Natural',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(personaNaturalPanel);
                        }
                    },
                    {
                        text: 'Producto Físico',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(productoFisicoPanel);
                        }
                    },
                    {
                        text: 'Producto Digital',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(productoDigitalPanel);
                        }
                    },
                    {
                        text: 'Usuarios',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(usuarioPanel);
                        }
                    },
                    {
                        text: 'Facturas',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(facturaPanel);
                        }
                    },
                    {
                        text: 'Ventas',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(ventaPanel);
                        }
                    },
                    {
                        text: 'Detalles de Venta',
                        handler: () => {
                            mainCard.getLayout().setActiveItem(detalleVentaPanel);
                        }
                    }
                ],
            },
            mainCard,
        ],
    });
});
