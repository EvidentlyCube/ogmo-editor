package editor.tools.tile 
{
    import editor.layers.Layer;
    import editor.layers.tile.Tile;
    import editor.undo.TileUndoState;
    import editor.tools.QuickTool;
    import editor.ui.windows.TilePaletteWindow;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;


    public class ToolTileFill extends TileTool
    {
        private var lastMouseX:Number;
        private var lastMouseY:Number;
        private var lastAdded:Tile;
        private var undoState:TileUndoState;

        public function ToolTileFill(layer:Layer)
        {
            super(layer);
        }

        override protected function activate(e:Event):void
        {
            super.activate(e);
            layer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            layer.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        override protected function deactivate(e:Event):void
        {
            super.deactivate(e);
            layer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            layer.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        private function onMouseDown(e:MouseEvent):void
        {
            undoState = new TileUndoState;

            var points:Array = [];
            var vec:Vector.<Tile>;
            
            var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
            var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;
            
            vec = tileLayer.tilemap.getTilesAsFill(ax, ay, tileLayer.gridSize, points);
            
            tileLayer.tilemap.removeTiles(vec);
            undoState.pushRemovedVector(vec);
            
            for each(var p:Point in points){
                var t:Tile = new Tile(Ogmo.level.selectedTileset, Ogmo.level.selectedTilePoint, p.x, p.y);
                tileLayer.tilemap.addTile(t);
                undoState.pushAdded(t);
            }
            
            tileLayer.storeUndo(undoState);
        }

        private function onRightMouseDown(e:MouseEvent):void
        {
            undoState = new TileUndoState;
            
            var points:Array = [];
            var vec:Vector.<Tile>;
            
            var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
            var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;
            
            vec = tileLayer.tilemap.getTilesAsFill(ax, ay, tileLayer.gridSize, points);
            
            tileLayer.tilemap.removeTiles(vec);
            undoState.pushRemovedVector(vec);
            
            tileLayer.storeUndo(undoState);
        }

        private function onKeyDown(e:KeyboardEvent):void
        {
            if (e.keyCode == Ogmo.keycode_ctrl)
                layer.setTool(new ToolTileEyedrop(layer), new QuickTool(ToolTileFill, QuickTool.CTRL));
        }

    }

}