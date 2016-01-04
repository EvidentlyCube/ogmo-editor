package editor.tools.tile 
{
    import editor.layers.Layer;
    import editor.layers.tile.Tile;
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class ToolTileEyedrop extends TileTool
    {

        public function ToolTileEyedrop(layer:Layer)
        {
            super(layer);
        }

        override protected function activate(e:Event):void
        {
            super.activate(e);
            layer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }

        override protected function deactivate(e:Event):void
        {
            super.deactivate(e);
            layer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }

        private function onMouseDown(e:MouseEvent):void
        {
            var t:Tile = tileLayer.tilemap.getTileAtPosition(e.localX, e.localY);
            if (t)
            {
                Ogmo.level.setTileset( Ogmo.project.getTilesetNumFromName( t.tileset.tilesetName ) );
                Ogmo.level.selectedTilePoint.x = t.tileRect.x;
                Ogmo.level.selectedTilePoint.y = t.tileRect.y;
                Ogmo.windows.tilePalette.positionSelbox();
            }
        }

    }

}