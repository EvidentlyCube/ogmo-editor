package editor.layers.tile {
    import editor.layers.*;
    import editor.tools.tile.*;
    import editor.undo.TileUndoState;
    import editor.undo.Undoes;

    import flash.system.System;

    public class TileLayer extends Layer implements Undoes {
        static private const UNDO_LIMIT:uint = 15;
        public var tilemap:TileMap;
        private var _tileset:Tileset;
        private var undoStack:Vector.<TileUndoState>;
        private var redoStack:Vector.<TileUndoState>;

        public function TileLayer(layerName:String, gridSize:int, gridColor:uint, drawGridSize:uint, tileset:Tileset) {
            super(ToolTilePlace, layerName, gridSize, gridColor, drawGridSize);

            //Init the only tileset
            _tileset = tileset;

            //Init the tilemap
            tilemap = new TileMap(Ogmo.level.levelWidth, Ogmo.level.levelHeight, _tileset);
            addChild(tilemap);

            //init undo/redo
            undoStack = new Vector.<TileUndoState>;
            redoStack = new Vector.<TileUndoState>;
        }

        /* ========================== UNDO / REDO ========================== */

        override public function resizeLevel(width:int, height:int):void {
            clearUndo();
            clearRedo();

            tilemap.resize(width, height);

            super.resizeLevel(width, height);
        }

        override public function clear():void {
            tilemap.clear();

            System.gc();
        }

        override public function moveEverything(x:int, y:int):void {
            tilemap.moveEverything(x, y);
        }

        public function canUndo():Boolean {
            return (undoStack.length > 0);
        }

        public function canRedo():Boolean {
            return (redoStack.length > 0);
        }

        public function storeUndo(state:TileUndoState):void {
            if (state.empty) {
                return;
            }

            clearRedo();
            undoStack.push(state);

            if (undoStack.length > UNDO_LIMIT) {
                undoStack.splice(0, undoStack.length - UNDO_LIMIT);
            }

            Ogmo.windowMenu.refreshWithDelay();
        }

        public function undo():void {
            if (undoStack.length == 0) {
                return;
            }

            var t:TileUndoState = undoStack.pop();
            t.undo(tilemap);
            redoStack.push(t);

            if (redoStack.length > UNDO_LIMIT) {
                redoStack.splice(0, redoStack.length - UNDO_LIMIT);
            }

            if (_tileset) {
                _tileset = tilemap.tileset;
                Ogmo.level.setTileset(Ogmo.project.getTilesetNumFromName(tilemap.tileset.tilesetName));
            }

            Ogmo.windowMenu.refreshWithDelay();
        }

        /* ========================== LAYER STUFF ========================== */

        public function redo():void {
            if (redoStack.length == 0) {
                return;
            }

            var t:TileUndoState = redoStack.pop();
            t.redo(tilemap);
            undoStack.push(t);

            if (_tileset) {
                _tileset = tilemap.tileset;
                Ogmo.level.setTileset(Ogmo.project.getTilesetNumFromName(tilemap.tileset.tilesetName));
            }

            Ogmo.windowMenu.refreshWithDelay();
        }

        private function clearUndo():void {
            undoStack.splice(0, undoStack.length);
        }

        private function clearRedo():void {
            redoStack.splice(0, redoStack.length);
        }

        /* ========================== GETS/SETS ========================== */

        override public function get json():Object{
            var json:Object = {};
            if (tilemap.empty) {
                return json;
            }

            json.tileset = tileset.tilesetName;
            json.tiles = tilemap.json;

            return json;
        }

        override public function set json(value:Object):void {
            if (_tileset) {
                _tileset = Ogmo.project.getTileset(value.tileset);
                if (!_tileset) {
                    throw new Error("Tileset not defined: \"" + value.tileset + "\"");
                }

                tilemap.tileset = _tileset;
            }

            tilemap.json = value.tiles;
        }

        override public function get xml():XML {
            if (tilemap.empty) {
                return null;
            }

            var ret:XML = <layer></layer>;
            ret.setName(layerName);

            ret.@set = tileset.tilesetName;

            tilemap.getXML(ret);

            return ret;
        }

        override public function set xml(value:XML):void {
            if (_tileset) {
                _tileset = Ogmo.project.getTileset(value.@set);
                if (!_tileset) {
                    throw new Error("Tileset not defined: \"" + value.@set + "\"");
                }

                tilemap.tileset = _tileset;
            }

            tilemap.setXML(value);
        }

        public function get tileset():Tileset {
            return _tileset;
        }

    }
}