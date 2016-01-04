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
    
    
    public class ToolTilePlace extends TileTool
    {
        private var placing:Boolean;
        private var drawMode:Boolean;
        private var lastMouseX:Number;
        private var lastMouseY:Number;
        private var lastAdded:Tile;
        private var undoState:TileUndoState;
        
        public function ToolTilePlace(layer:Layer) 
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
            Ogmo.windows.mouse = false;
            
            drawMode     = true;
            placing     = true;
            
            undoState = new TileUndoState;
            
            var ax:int = Math.floor(e.localX / layer.gridSize) * layer.gridSize;
            var ay:int = Math.floor(e.localY / layer.gridSize) * layer.gridSize;
            
            var t:Tile = tileLayer.tilemap.getTileAtPosition(e.localX, e.localY);
            if (t){
                if (t.tileRect.x != Ogmo.level.selectedTilePoint.x || t.tileRect.y != Ogmo.level.selectedTilePoint.y){
                    tileLayer.tilemap.removeTile(t);
                    undoState.pushRemoved(t);
                } else {
                    return;
                }
            }
            
            if (ax >= 0 && ax < Ogmo.level.levelWidth && ay >= 0 && ay < Ogmo.level.levelHeight)
            {
                t = new Tile(Ogmo.level.selectedTileset, Ogmo.level.selectedTilePoint, ax, ay);
                lastAdded = tileLayer.tilemap.addTile(t);
                undoState.pushAdded(t);
            }
        }
        
        private function onMouseUp(e:MouseEvent):void
        {
            Ogmo.windows.mouse = true;
            
            //Store the undo state
            if (undoState)
                tileLayer.storeUndo(undoState);
            undoState = null;
            
            lastAdded = null;
            placing = false;
        }
        
        private function onRightMouseDown(e:MouseEvent):void
        {
            Ogmo.windows.mouse = false;
            
            drawMode     = false;
            placing     = true;
            
            undoState = new TileUndoState;
            
            var t:Tile = tileLayer.tilemap.getTileAtPosition(e.localX, e.localY);
            if (t)
            {
                tileLayer.tilemap.removeTile(t);
                undoState.pushRemoved(t);
            }
        }
        
        private function onMouseMove(e:MouseEvent):void
        {
            var p:Point = layer.convertPoint(new Point(e.localX, e.localY));
            
            if (placing)
            {
                var t:Tile;
                if (drawMode)
                {
                    t = tileLayer.tilemap.getTileAtPosition(e.localX, e.localY);
                    if (t){
                        if (t.tileRect.x != Ogmo.level.selectedTilePoint.x || t.tileRect.y != Ogmo.level.selectedTilePoint.y){
                            tileLayer.tilemap.removeTile(t);
                            undoState.pushRemoved(t);
                        } else {
                            return;
                        }
                    }
                    
                    t = new Tile(Ogmo.level.selectedTileset, Ogmo.level.selectedTilePoint, p.x, p.y);
                    
                    if (lastAdded && lastAdded.collidesWithTile(t))
                        return;
                    
                    lastAdded = tileLayer.tilemap.addTile(t);
                    undoState.pushAdded(t);
                }
                else
                {
                    t = tileLayer.tilemap.getTileAtPosition(e.localX, e.localY);
                    if (t)
                    {
                        tileLayer.tilemap.removeTile(t);
                        undoState.pushRemoved(t);
                    }
                }
            }
        }
        
        private function onKeyDown(e:KeyboardEvent):void
        {
            if (e.keyCode == Ogmo.keycode_ctrl)
                layer.setTool(new ToolTileEyedrop(layer), new QuickTool(ToolTilePlace, QuickTool.CTRL));
        }
        
    }
    
}