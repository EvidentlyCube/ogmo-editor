package editor.tools.tile 
{
    import editor.events.TileSelectEvent;
    import editor.layers.Layer;
    import editor.events.OgmoEvent;
    import editor.layers.tile.TileLayer;
    import editor.tools.Tool;
    import editor.ui.windows.TilePaletteWindow;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.geom.ColorTransform;


    public class TileTool extends Tool
    {
        protected var tileLayer:TileLayer;
        protected var tileImage:Bitmap;

        public function TileTool(layer:Layer)
        {
            super(layer);
            tileLayer = layer as TileLayer;

            addChild(tileImage = new Bitmap);
            tileImage.visible = false;
            updateTileImage();
        }

        override protected function activate(e:Event):void
        {
            super.activate(e);
            stage.addEventListener(OgmoEvent.SELECT_TILE, onSelectTile);
        }

        override protected function deactivate(e:Event):void
        {
            super.deactivate(e);
            stage.removeEventListener(OgmoEvent.SELECT_TILE, onSelectTile);
        }

        protected function onSelectTile(e:TileSelectEvent):void
        {
            updateTileImage();
        }

        private function updateTileImage(e:Event = null):void
        {
            if (tileImage.bitmapData != null)
                tileImage.bitmapData.dispose();

            if (!Ogmo.level.selectedTileset.loaded)
            {
                tileImage.bitmapData = new BitmapData(Ogmo.level.selectedTileset.tileWidth, Ogmo.level.selectedTileset.tileHeight, true, 0xAA00FF00);
                Ogmo.level.selectedTileset.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, updateTileImage, false, 0, true);
                return;
            }

            tileImage.bitmapData = new BitmapData(Ogmo.level.selectedTileset.tileWidth, Ogmo.level.selectedTileset.tileHeight);

            Ogmo.rect.x = Ogmo.level.selectedTilePoint.x;
            Ogmo.rect.y = Ogmo.level.selectedTilePoint.y;
            Ogmo.rect.width = Ogmo.level.selectedTileset.tileWidth;
            Ogmo.rect.height = Ogmo.level.selectedTileset.tileHeight;

            Ogmo.point.x = 0;
            Ogmo.point.y = 0;

            tileImage.bitmapData.copyPixels(Ogmo.level.selectedTileset.bitmapData, Ogmo.rect, Ogmo.point);

            Ogmo.rect.x = Ogmo.rect.y = 0;
            tileImage.bitmapData.colorTransform(Ogmo.rect, new ColorTransform(1, 1, 1, 0.5));
        }

    }

}