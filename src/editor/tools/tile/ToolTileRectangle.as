package editor.tools.tile 
{
    import editor.layers.Layer;
    import editor.layers.tile.Tile;
    import editor.undo.TileUndoState;
    import editor.utils.Utils;
    import editor.tools.QuickTool;

    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class ToolTileRectangle extends TileTool
    {
        private var placing:Boolean;
        private var drawMode:Boolean;
        private var startAt:Point = new Point;

        public function ToolTileRectangle(layer:Layer)
        {
            super(layer);

            placing = false;
        }

        override protected function activate(e:Event):void
        {
            super.activate(e);
            layer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            layer.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
            layer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        override protected function deactivate(e:Event):void
        {
            super.deactivate(e);
            layer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            layer.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
            layer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        private function onMouseDown(e:MouseEvent):void
        {
            var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
            var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;

            if (ax >= 0 && ax < Ogmo.level.levelWidth && ay >= 0 && ay < Ogmo.level.levelHeight)
            {
                Ogmo.windows.mouse = false;
                drawMode = true;
                placing = true;
                startAt.x = ax;
                startAt.y = ay;
            }
        }

        private function onRightMouseDown(e:MouseEvent):void
        {
            var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
            var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;

            if (ax >= 0 && ax < Ogmo.level.levelWidth && ay >= 0 && ay < Ogmo.level.levelHeight)
            {
                Ogmo.windows.mouse = false;
                drawMode = false;
                placing = true;
                startAt.x = ax;
                startAt.y = ay;
            }
        }

        private function onMouseUp(e:MouseEvent):void
        {
            if (placing)
            {
                var t:Tile;
                
                Ogmo.windows.mouse = true;

                var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
                var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;

                var undoState:TileUndoState = new TileUndoState;
                var vec:Vector.<Tile>;

                if (drawMode)
                {
                    //if (e.ctrlKey){
                    Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, tileLayer.gridSize);
                    vec = tileLayer.tilemap.getTilesAtRectangle(Ogmo.rect);
                    tileLayer.tilemap.removeTiles(vec);
                    
                    for each (t in vec)
                        undoState.pushRemoved(t);
                    
                    Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, tileLayer.gridSize, Ogmo.level.selectedTileset.tileWidth, Ogmo.level.selectedTileset.tileHeight);
                    var l:int = Ogmo.rect.width / layer.gridSize;
                    var k:int = Ogmo.rect.height / layer.gridSize;
                    var offX:int = Ogmo.rect.x;
                    var offY:int = Ogmo.rect.y;
                    for(var i:int = 0; i < l; i++){
                        for(var j:int = 0; j < k; j++){
                            t = new Tile(Ogmo.level.selectedTileset, Ogmo.level.selectedTilePoint, offX + i * layer.gridSize, offY + j * layer.gridSize);
                            tileLayer.tilemap.addTile(t);
                            undoState.pushAdded(t);
                        }
                    }
                    

                }
                else
                {
                    Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, tileLayer.gridSize);
                    vec = tileLayer.tilemap.getTilesAtRectangle(Ogmo.rect);
                    tileLayer.tilemap.removeTiles(vec);

                    for each (t in vec)
                        undoState.pushRemoved(t);
                }

                tileLayer.storeUndo(undoState);
                placing = false;
                graphics.clear();
            }
        }

        private function onMouseMove(e:MouseEvent):void
        {
            if (placing)
            {
                var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
                var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;

                graphics.clear();
                if (drawMode)
                {
                    Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, tileLayer.gridSize, Ogmo.level.selectedTileset.tileWidth, Ogmo.level.selectedTileset.tileHeight);
                    graphics.beginBitmapFill(tileImage.bitmapData);
                }
                else
                {
                    Utils.setRectForFill(Ogmo.rect, startAt.x, startAt.y, ax, ay, tileLayer.gridSize);
                    graphics.beginFill(0xFF0000, 0.5);
                }
                graphics.drawRect(Ogmo.rect.x, Ogmo.rect.y, Ogmo.rect.width, Ogmo.rect.height);
                graphics.endFill();
            }
        }

        private function onKeyDown(e:KeyboardEvent):void
        {
            if (e.keyCode == Ogmo.keycode_ctrl)
                layer.setTool(
                    new ToolTileEyedrop(layer), 
                    new QuickTool(ToolTileRectangle, QuickTool.CTRL)
                );
        }
    }

}