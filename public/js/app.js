Ext.onReady(() => {
    const personaJuridicaPanel = createPersonaJuridicaPanel();

    const personaNaturalPanel = createPersonaNaturalPanel();

    const productoFisicoPanel = createProductoFisicoPanel();

    const mainCard = Ext.create('Ext.panel.Panel',{
        region: 'center',
        layout: 'card',
        items: [personaJuridicaPanel, personaNaturalPanel, productoFisicoPanel],
    });

    Ext.create('Ext.container.Viewport', {
        id: 'mainViewport',
        layout: 'border',
        items:[
            {
                region: 'north',
                xtype: 'toolbar',
                items:[
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
                    }
                ],
            },
            mainCard,
        ],

    });
});