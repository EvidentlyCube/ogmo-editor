package editor.ui.windows
{
    import editor.ui.*;
    import editor.layers.object.ObjectFolder;
    import editor.ui.elements.Label;
    import editor.ui.elements.ObjectLayerElementButton;

    public class ObjectPaletteWindow extends Window
    {
        public static var windowWidth:uint = 128;

        private var label:Label;

        public function ObjectPaletteWindow(x:int)
        {
            super(windowWidth + 4, 100, "Objects");
            this.x = x;
            this.y = 20 + Window.BAR_HEIGHT;

            label = new Label("", 66, bodyHeight - 14, "Center", "Center");
            ui.addChild(label);
        }

        public function setFolder(to:ObjectFolder):void
        {
            var button:ObjectLayerElementButton;
            var j:int = 0;
            var perRow:int = Math.floor( windowWidth / ObjectLayerElementButton.gridSize );

            //Empty the window
            while (ui.numChildren > 0)
                ui.removeChildAt( 0 );
            addChild(label);

            //Set the title
            title = to.name;

            //Add the back button if necessary
            if (to != Ogmo.project.objects)
            {
                j = 1;
                button = new ObjectLayerElementButton( ObjectLayerElementButton.BACK, to.parent );
                button.x = 2;
                button.y = 2;
                ui.addChild( button );
            }

            //Add all the buttons
            for ( var i:int = 0; i < to.length; i++ )
            {
                if (to.contents[ i ] is ObjectFolder)
                    button = new ObjectLayerElementButton( ObjectLayerElementButton.FOLDER, to.contents[ i ] );
                else
                    button = new ObjectLayerElementButton( ObjectLayerElementButton.OBJECT, to.contents[ i ] );

                button.x = 2 + (j % perRow) * ObjectLayerElementButton.gridSize;
                button.y = 2 + Math.floor( j / perRow ) * ObjectLayerElementButton.gridSize;
                ui.addChild( button );
                j++;
            }

            //Adjust the height
            bodyHeight = 24 + (Math.floor( (j - 1) / perRow ) + 1) * ObjectLayerElementButton.gridSize;

            //Move the label
            label.y = bodyHeight - 14;
        }

        public function set mouseText(to:String):void
        {
            label.text = to;
        }

    }

}