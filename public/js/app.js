Ext.onReady(() => {
    const personaJuridicaPanel = createPersonaJuridicaPanel();

    const personaNaturalPanel = createPersonaNaturalPanel();

    const mainCard = Ext.create('Ext.panel.Panel',{
        region: 'center',
        layout: 'card',
        items: [personaJuridicaPanel, personaNaturalPanel],
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
                    }
                ],
            },
            mainCard,
        ],

    });
});