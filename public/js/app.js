Ext.onReady(() => {
    const personaJuridicaPanel = createPersonaJuridicaPanel();

    const mainCard = Ext.create('Ext.panel.Panel',{
        region: 'center',
        layout: 'card',
        items: [personaJuridicaPanel],
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
                    
                ],
            },
            mainCard,
        ],

    });
});