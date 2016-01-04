package editor.ui 
{
    import editor.definitions.*;
    import editor.layers.grid.GridLayer;
    import editor.layers.object.ObjectFolder;
    import editor.layers.object.ObjectLayer;
    import editor.layers.tile.TileLayer;
    import editor.ui.elements.LayerButtonAlpha;
    import editor.ui.elements.LayerButtonVisibility;
    import editor.ui.elements.ObjectLayerElementButton;
    import editor.ui.elements.TextButton;
    import editor.ui.windows.LevelInfoWindow;
    import editor.ui.windows.ObjectInfoWindow;
    import editor.ui.windows.ObjectPaletteWindow;
    import editor.ui.windows.TilePaletteWindow;
    import editor.ui.windows.ToolWindow;
    import editor.ui.windows.Window;

    import flash.display.DisplayObject;

    import flash.display.Sprite;
    import flash.events.Event;

    public class Windows extends Sprite
    {
        //Windows
        public function Windows()
        {
            addEventListener( Event.ADDED_TO_STAGE, init );
        }
        public var windowLevelInfo:LevelInfoWindow;
        public var windowLayers:Window;
        public var windowTilesetPalette:Window;
        public var windowObjectPalette:ObjectPaletteWindow;
        public var windowObjectInfo:ObjectInfoWindow;
        public var windowTools:ToolWindow;
        public var tilePalette:TilePaletteWindow;
        public var windowLayersVisibilities:Sprite;
        public var windowLayersAlphas:Sprite;

        public function setLayer( to:int ):void
        {
            //Set selected in layer window buttons
            if (windowLayers)
            {
                for ( var i:int = 0; i < windowLayers.ui.numChildren; i++ )
                {
                    if (i == to)
                        (windowLayers.ui.getChildAt( i ) as TextButton).selected = true;
                    else
                        (windowLayers.ui.getChildAt( i ) as TextButton).selected = false;
                }
            }

            //Activate and deactivate windows correctly
            if (Ogmo.level.selectedLayer is TileLayer)
            {
                if (windowTilesetPalette)
                    windowTilesetPalette.active = true;
                if (windowObjectPalette)
                    windowObjectPalette.active = false;
                if (windowObjectInfo)
                    windowObjectInfo.active = false;
            }
            else if (Ogmo.level.selectedLayer is GridLayer)
            {
                if (windowTilesetPalette)
                    windowTilesetPalette.active = false;
                if (windowObjectPalette)
                    windowObjectPalette.active = false;
                if (windowObjectInfo)
                    windowObjectInfo.active = false;
            }
            else if (Ogmo.level.selectedLayer is ObjectLayer)
            {
                if (windowTilesetPalette)
                    windowTilesetPalette.active = false;
                if (windowObjectPalette)
                    windowObjectPalette.active = true;
                if (windowObjectInfo)
                    windowObjectInfo.active = true;
            }
        }

        public function setTileset( to:int ):void
        {
            //Create the palette in the palette window
            if (windowTilesetPalette.ui.numChildren > 0)
                windowTilesetPalette.ui.removeChildAt( 0 );
            var t:TilePaletteWindow = new TilePaletteWindow( Ogmo.level.selectedTileset );
            t.x = 5;
            t.y = 5;
            tilePalette = t;
            windowTilesetPalette.ui.addChild( t );
        }

        /* ========================== UTILITIES ========================== */

        public function setObjectFolder( to:ObjectFolder ):void
        {
            Ogmo.level.selectedObjectFolder = to;
            windowObjectPalette.setFolder(to);
        }

        public function resetObjectsSelected():void
        {
            for ( var i:int = 0; i < windowObjectPalette.ui.numChildren; i++ )
                (windowObjectPalette.ui.getChildAt( i ) as ObjectLayerElementButton).selected = false;
        }

        public function updateVisibilities():void
        {
            if (windowLayersVisibilities == null)
                return;

            var i:int;
            for (i = 0; i < windowLayersVisibilities.numChildren; i++ )
            {
                (windowLayersVisibilities.getChildAt( i ) as LayerButtonVisibility).setImage();
            }

            for (i = 0; i < windowLayersAlphas.numChildren; i++ )
            {
                (windowLayersAlphas.getChildAt( i ) as LayerButtonAlpha).setImage();
            }
        }

        private function buttonSetLayer( obj:TextButton ):void
        {
            Ogmo.level.setLayer( obj.layerNum );
        }

        private function buttonSetTilesetPalette( obj:TextButton ):void
        {
            Ogmo.level.setTileset( obj.tilesetNum );
        }

        private function init( e:Event = null ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, init );

            addEventListener( Event.REMOVED_FROM_STAGE, destroy );
            stage.addEventListener( Event.RESIZE, onResize );

            var i:int;
            var button:TextButton;
            var layer:LayerDefinition;
            var offsetX:uint = 0;

            //Level info window
            windowLevelInfo = new LevelInfoWindow;
            addChild( windowLevelInfo );
            windowLevelInfo.active = true;

            //The Layer Window
            if (Ogmo.project.layers.length > 1)
            {
                offsetX = 110;

                windowLayers     = new Window( 120, (TextButton.HEIGHT + 2) * Ogmo.project.layers.length + 3, "Layers" );
                windowLayers.x    = 20;
                windowLayers.y    = 20 + Window.BAR_HEIGHT;

                windowLayersVisibilities = new Sprite;
                windowLayersVisibilities.x = 80;

                windowLayersAlphas = new Sprite;
                windowLayersAlphas.x = 100;

                for ( i = 0; i < Ogmo.project.layers.length; i++ )
                {
                    layer = Ogmo.project.layers[ i ];

                    button = new TextButton( 74, layer.name, buttonSetLayer );
                    button.x = 3;
                    button.y = 3 + (i * (TextButton.HEIGHT + 2));
                    button.layerNum = i;
                    windowLayers.ui.addChild( button );

                    var visButton:LayerButtonVisibility = new LayerButtonVisibility( i );
                    visButton.y = 3 + (22 * i);
                    windowLayersVisibilities.addChild( visButton );

                    var alphaButton:LayerButtonAlpha = new LayerButtonAlpha( i );
                    alphaButton.y = 3 + (22 * i);
                    windowLayersAlphas.addChild( alphaButton );
                }
                windowLayers.addChild( windowLayersVisibilities );
                windowLayers.addChild( windowLayersAlphas );

                addChild( windowLayers );
                windowLayers.active = true;
            }



            //The Tileset Palette Window
            if (Ogmo.project.tilesetsCount > 0)
            {
                windowTilesetPalette     = new Window( 100, 100, "Palette" );
                windowTilesetPalette.x    = 20 + offsetX + (Ogmo.project.tilesetsCount > 1 ? 90 : 0);
                windowTilesetPalette.y    = 20 + Window.BAR_HEIGHT;

                addChild( windowTilesetPalette );
            }

            if (Ogmo.project.objectsCount > 0)
            {
                //The Object Palette Window
                windowObjectPalette        = new ObjectPaletteWindow(20 + offsetX);

                addChild( windowObjectPalette );

                //The Object Info Window
                windowObjectInfo = new ObjectInfoWindow;
                addChild( windowObjectInfo );
            }

            //Tool window
            addChild(windowTools = new ToolWindow);

            for ( i = 0; i < numChildren; i++ )
            {
                (getChildAt( i ) as Window).stickToEdges( Ogmo.STAGE_DEFAULT_WIDTH, Ogmo.STAGE_DEFAULT_HEIGHT );
                (getChildAt( i ) as Window).enforceBounds();
            }

            //addChild(windowLevelLibrary = new LevelLibraryWindow());
        }

        /* ========================== EVENTS ========================== */

        private function destroy( e:Event ):void
        {
            removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
            stage.removeEventListener( Event.RESIZE, onResize );
        }

        private function addedToStage( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, addedToStage );
            stage.addEventListener( Event.RESIZE, onResize, false, 0, true );
        }

        private function onResize( e:Event ):void
        {
            for ( var i:int = 0; i < numChildren; i++ ){
                var child:DisplayObject = getChildAt(i);
                if (child is Window){
                    Window(child).enforceBounds();
                }
            }
        }

        public function set mouse( to:Boolean ):void
        {
            mouseChildren     = to;
            mouseEnabled     = to;
        }
    }

}