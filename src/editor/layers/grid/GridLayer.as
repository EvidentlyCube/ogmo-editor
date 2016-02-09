package editor.layers.grid {
    import editor.layers.*;
    import editor.tools.grid.*;
    import editor.undo.Undoes;

    import flash.display.BitmapData;
    import flash.events.KeyboardEvent;
    import flash.geom.Rectangle;
    import flash.system.System;

    public class GridLayer extends Layer implements Undoes {
        static private const UNDO_LIMIT:uint = 30;

        public var grid:GridMap;
        private var exportAsObjects:Boolean;
        private var newLine:String;
        private var drawColor:uint;
        private var bgColor:uint;

        private var undoStack:Vector.<BitmapData>;
        private var redoStack:Vector.<BitmapData>;

        public function GridLayer(layerName:String, gridSize:int, gridColor:uint, drawGridSize:uint, drawColor:uint, bgColor:uint, exportAsObjects:Boolean, newLine:String) {
            super(ToolGridPencil, layerName, gridSize, gridColor, drawGridSize);

            this.gridSize = gridSize;
            this.exportAsObjects = exportAsObjects;
            this.newLine = newLine;
            this.drawColor = drawColor;
            this.bgColor = bgColor;

            //init undo/redo
            undoStack = new Vector.<BitmapData>;
            redoStack = new Vector.<BitmapData>;

            grid = new GridMap(Ogmo.level.levelWidth / gridSize, Ogmo.level.levelHeight / gridSize, drawColor, bgColor, newLine);
            grid.scaleX = grid.scaleY = gridSize;
            addChild(grid);
        }

        /* ========================== UNDO / REDO ========================== */

        public function canUndo():Boolean {
            return (undoStack.length > 0);
        }

        public function canRedo():Boolean {
            return (redoStack.length > 0);
        }

        public function storeUndo():void {
            clearRedo();
            undoStack.push(grid.getCopyOfBitmapData());

            if (undoStack.length > UNDO_LIMIT) {
                undoStack.splice(0, undoStack.length - UNDO_LIMIT);
            }

            Ogmo.windowMenu.refreshWithDelay();
        }

        public function undo():void {
            if (undoStack.length == 0) {
                return;
            }

            redoStack.push(grid.getCopyOfBitmapData());
            if (redoStack.length > UNDO_LIMIT) {
                redoStack.splice(0, redoStack.length - UNDO_LIMIT);
            }

            grid.bitmapData = undoStack.pop();

            Ogmo.windowMenu.refreshWithDelay();
        }

        public function redo():void {
            if (redoStack.length == 0) {
                return;
            }

            undoStack.push(grid.getCopyOfBitmapData());

            grid.bitmapData = redoStack.pop();

            Ogmo.windowMenu.refreshWithDelay();
        }

        private function clearUndo():void {
            undoStack.splice(0, undoStack.length);
        }

        private function clearRedo():void {
            redoStack.splice(0, redoStack.length);
        }

        /* ========================== LAYER STUFF ========================== */

        override public function resizeLevel(width:int, height:int):void {
            clearUndo();
            clearRedo();

            var w:int, h:int;
            w = width / gridSize;
            h = height / gridSize;

            //Make the new arrays
            grid.resize(w, h);

            super.resizeLevel(width, height);

            handleGridMode();
        }

        override public function clear():void {
            storeUndo();
            grid.clear();

            System.gc();
        }

        override protected function activate():void {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        override protected function deactivate():void {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        /* ========================== GETS/SETS ========================== */


        override public function get json():Object {
            var layer:Object = {};

            if (exportAsObjects) {
                var rects:Vector.<Rectangle> = grid.rectangles;

                if (rects.length == 0) {
                    return layer;
                }

                var blocks:Object = [];
                for each (var r:Rectangle in rects) {
                    blocks.push({
                        x: r.x * gridSize,
                        y: r.y * gridSize,
                        w: r.width * gridSize,
                        h: r.height * gridSize
                    });
                }
                layer.blocks = blocks;
            } else {
                layer.bits = grid.bits;
            }

            return layer;
        }

        override public function set json(value:Object):void {
            clear();

            if (exportAsObjects) {
                var rects:Vector.<Rectangle> = new Vector.<Rectangle>;
                for each (var block:Object in value.blocks) {
                    rects.push(new Rectangle(
                        block.x / gridSize,
                        block.y / gridSize,
                        block.w / gridSize,
                        block.h / gridSize
                    ));
                }
                grid.rectangles = rects;
            }
            else {
                grid.bits = value.bits;
            }
        }

        override public function get xml():XML {
            var ret:XML = <layer></layer>;
            ret.setName(layerName);

            if (exportAsObjects) {
                var temp:XML;
                var rects:Vector.<Rectangle> = grid.rectangles;

                if (rects.length == 0) {
                    return null;
                }

                for each (var r:Rectangle in rects) {
                    temp = <rect></rect>;
                    temp.@x = r.x * gridSize;
                    temp.@y = r.y * gridSize;
                    temp.@w = r.width * gridSize;
                    temp.@h = r.height * gridSize;
                    ret.appendChild(temp);
                }
            }
            else {
                ret.setChildren(grid.bits);
            }

            return ret;
        }

        override public function set xml(to:XML):void {
            clear();

            if (exportAsObjects) {
                var rects:Vector.<Rectangle> = new Vector.<Rectangle>;
                for each (var o:XML in to.rect) {
                    rects.push(new Rectangle(o.@x / gridSize, o.@y / gridSize, o.@w / gridSize, o.@h / gridSize));
                }
                grid.rectangles = rects;
            }
            else {
                grid.bits = to;
            }
        }

        /* ========================== EVENTS ========================== */

        private function onKeyDown(e:KeyboardEvent):void {
            if (Ogmo.missKeys || !e.ctrlKey) {
                return;
            }

            switch (e.keyCode) {
                //LEFT
                case (37):
                    if (!grid.empty()) {
                        storeUndo();
                        grid.shift(-1, 0);
                    }
                    break;
                //UP
                case (38):
                    if (!grid.empty()) {
                        storeUndo();
                        grid.shift(0, -1);
                    }
                    break;
                //RIGHT
                case (39):
                    if (!grid.empty()) {
                        storeUndo();
                        grid.shift(1, 0);
                    }
                    break;
                //DOWN
                case (40):
                    if (!grid.empty()) {
                        storeUndo();
                        grid.shift(0, 1);
                    }
                    break;
            }
        }

    }

}