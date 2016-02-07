package editor.layers.object {
    import editor.layers.*;
    import editor.tools.*;
    import editor.tools.object.*;
    import editor.ui.*;
    import editor.definitions.*;

    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.system.System;

    public class ObjectLayer extends Layer {
        public var bg:Sprite;

        private var _objectsContainer:Sprite;
        private var _objects:Vector.<GameObject>;

        private var _selection:Vector.<GameObject>;

        public function ObjectLayer(layerName:String, gridSize:int, gridColor:uint, drawGridSize:uint) {
            super(ToolObjectPaint, layerName, gridSize, gridColor, drawGridSize);

            _selection = new Vector.<GameObject>;
            _objects = new Vector.<GameObject>();

            bg = new Sprite;
            bg.graphics.beginFill(0x000000, 0);
            bg.graphics.drawRect(0, 0, Ogmo.level.levelWidth, Ogmo.level.levelHeight);
            bg.graphics.endFill();
            addChild(bg);

            addChild(_objectsContainer = new Sprite);
            _objectsContainer.mouseChildren = _objectsContainer.mouseEnabled = false;
        }

        public function getObjectsAtPoint(x:Number, y:Number):Vector.<GameObject> {
            var v:Vector.<GameObject> = new Vector.<GameObject>;
            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                if ((_objectsContainer.getChildAt(i) as GameObject).collidesWithPoint(x, y)) {
                    v.push(_objectsContainer.getChildAt(i) as GameObject);
                }
            }
            return v;
        }

        public function getFirstAtPoint(x:Number, y:Number):GameObject {
            for (var i:int = _objectsContainer.numChildren - 1; i >= 0; i--) {
                if ((_objectsContainer.getChildAt(i) as GameObject).collidesWithPoint(x, y)) {
                    return (_objectsContainer.getChildAt(i) as GameObject);
                }
            }
            return null;
        }

        public function getObjectsAtRect(rect:Rectangle):Vector.<GameObject> {
            var v:Vector.<GameObject> = new Vector.<GameObject>;
            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                if ((_objectsContainer.getChildAt(i) as GameObject).collidesWithRectangle(rect)) {
                    v.push(_objectsContainer.getChildAt(i) as GameObject);
                }
            }
            return v;
        }

        public function getAmountType(name:String):int {
            var ret:int = 0;
            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                if ((_objectsContainer.getChildAt(i) as GameObject).definition.name == name) {
                    ret++;
                }
            }
            return ret;
        }

        override public function moveEverything(x:int, y:int):void {
            x *= gridSize;
            y *= gridSize;

            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                var object:GameObject = _objectsContainer.getChildAt(i) as GameObject;

                object.x = (object.x + x + Ogmo.level.levelWidth) % Ogmo.level.levelWidth;
                object.y = (object.y + y + Ogmo.level.levelHeight) % Ogmo.level.levelHeight;
            }
        }

        private function setSelboxVisibility(to:Boolean):void {
            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                (_objectsContainer.getChildAt(i) as GameObject).selBox.visible = to;
            }
        }

        public function moveObjects(vec:Vector.<GameObject>, h:int, v:int):void {
            for each(var o:GameObject in vec) {
                o.move(h, v);
            }
        }

        public function resizeObjects(vec:Vector.<GameObject>, w:int, h:int):void {
            for each (var o:GameObject in vec) {
                o.setSize(w, h);
            }
        }

        public function resizeObjectsRelative(vec:Vector.<GameObject>, w:int, h:int):void {
            for each (var o:GameObject in vec) {
                o.setSize(o.width + w, o.height + h);
            }
        }

        public function rotateObjects(vec:Vector.<GameObject>, dir:int = 1):void {
            for each (var o:GameObject in vec) {
                o.rotate(dir);
            }
        }

        public function resetObjectsRotation(vec:Vector.<GameObject>):void {
            for each (var o:GameObject in vec) {
                o.setAngle(0);
            }
        }

        public function duplicateObjects():void {
            for each (var o:GameObject in _selection) {
                addExistingObject(o.deepCopy());
            }
        }

        /* ========================== ADDING/REMOVING OBJECTS ========================== */

        public function addObject(obj:ObjectDefinition, x:int, y:int):GameObject {
            var o:GameObject = new GameObject(this, obj);
            o.x = x;
            o.y = y;
            _objectsContainer.addChild(o);

            return o;
        }

        public function addExistingObject(obj:GameObject):void {
            _objectsContainer.addChild(obj);
        }

        private function addObjectFromJson(json:Object):GameObject {
            var o:GameObject = new GameObject(this);
            o.json = json;
            _objectsContainer.addChild(o);

            return o;
        }

        private function addObjectFromXML(xml:XML):GameObject {
            var o:GameObject = new GameObject(this);
            o.xml = xml;
            _objectsContainer.addChild(o);

            return o;
        }

        public function removeObject(obj:GameObject):void {
            if (obj == null || !_objectsContainer.contains(obj)) {
                return;
            }

            _objectsContainer.removeChild(obj);
            if (obj.selected) {
                deselectObject(obj);
            }
        }

        public function removeObjects(objs:Vector.<GameObject>):void {
            var o:GameObject;

            if (objs == _selection) {
                var v:Vector.<GameObject> = new Vector.<GameObject>;

                for each (o in objs) {
                    v.push(o);
                }

                for each (o in v) {
                    removeObject(o);
                }
            }
            else {
                for each (o in objs) {
                    removeObject(o);
                }
            }
        }

        public function removeType(name:String, amount:int = 1):void {
            if (amount < 1) {
                throw new Error("Cannot remove less than one of an object type.");
            }

            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                if ((_objectsContainer.getChildAt(i) as GameObject).definition.name == name) {
                    amount--;
                    removeObject(_objectsContainer.getChildAt(i) as GameObject);
                    i--;
                    if (amount <= 0) {
                        return;
                    }
                }
            }
        }

        /* ========================== SELECTION STUFF ========================== */

        public function get selection():Vector.<GameObject> {
            return _selection;
        }

        private function selectObjectUtility(obj:GameObject):void {
            if (obj.selected) {
                return;
            }

            obj.selected = true;
            _selection.push(obj);
        }

        public function selectObject(obj:GameObject):void {
            selectObjectUtility(obj);

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        public function selectObjects(objs:Vector.<GameObject>):void {
            for each (var o:GameObject in objs) {
                selectObjectUtility(o);
            }

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        public function selectAll():void {
            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                selectObjectUtility(_objectsContainer.getChildAt(i) as GameObject);
            }

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        public function selectType(name:String):void {
            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                var obj:GameObject = _objectsContainer.getChildAt(i) as GameObject;
                if (obj.definition.name == name) {
                    selectObjectUtility(obj);
                }
            }

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        private function deselectObjectUtility(obj:GameObject):void {
            if (obj.selected) {
                var index:int = _selection.indexOf(obj);
                _selection[index].selected = false;
                _selection.splice(index, 1);
            }
        }

        public function deselectObject(obj:GameObject):void {
            deselectObjectUtility(obj);

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        public function deselectObjects(objs:Vector.<GameObject>):void {
            for each (var o:GameObject in objs) {
                deselectObjectUtility(o);
            }

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        public function deselectAll():void {
            while (_selection.length > 0) {
                deselectObjectUtility(_selection[0]);
            }

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        public function deselectType(name:String):void {
            for (var i:int = 0; i < _selection.length; i++) {
                if (_selection[i].definition.name == name) {
                    deselectObjectUtility(_selection[i]);
                    i--;
                }
            }

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        private function toggleSelectObjectUtility(obj:GameObject):void {
            if (obj.selected) {
                deselectObjectUtility(obj);
            } else {
                selectObjectUtility(obj);
            }
        }

        public function toggleSelectObject(obj:GameObject):void {
            toggleSelectObjectUtility(obj);

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        public function toggleSelectObjects(objs:Vector.<GameObject>):void {
            for each (var o:GameObject in objs) {
                toggleSelectObjectUtility(o);
            }

            Ogmo.windows.windowObjectInfo.setTarget(_selection);
            Ogmo.windowMenu.refreshState();
        }

        public function anyObjectSelected(objs:Vector.<GameObject>):Boolean {
            for each (var o:GameObject in objs) {
                if (o.selected) {
                    return true;
                }
            }

            return false;
        }

        /* ========================== LAYER STUFF ========================== */

        override public function resizeLevel(width:int, height:int):void {
            //Remove objects out of bounds
            if (width < Ogmo.level.levelWidth || height < Ogmo.level.levelHeight) {
                for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                    var obj:GameObject = _objectsContainer.getChildAt(i) as GameObject;
                    if (obj.x >= width || obj.y >= height) {
                        removeObject(obj);
                        i--;
                    }
                }
            }

            //Redraw the background
            bg.graphics.clear();
            bg.graphics.beginFill(0x000000, 0);
            bg.graphics.drawRect(0, 0, width, height);
            bg.graphics.endFill();

            super.resizeLevel(width, height);
        }

        override public function clear():void {
            deselectAll();

            removeChild(_objectsContainer);
            addChild(_objectsContainer = new Sprite);

            System.gc();
        }

        override protected function activate():void {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

            setSelboxVisibility(true);
        }

        override protected function deactivate():void {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

            deselectAll();
            setSelboxVisibility(false);
        }

        /* ========================== GETS/SETS ========================== */


        override public function get json():Object {
            var json:Object = {};

            json.objects = [];
            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                var gameObject:GameObject = _objectsContainer.getChildAt(i) as GameObject;
                json.objects.push(gameObject.json);
            }

            return json;
        }

        override public function set json(value:Object):void {
            clear();

            for each (var o:Object in value.objects) {
                addObjectFromJson(o);
            }

            setSelboxVisibility(active);
        }

        override public function get xml():XML {
            if (_objectsContainer.numChildren == 0) {
                return null;
            }

            var ret:XML = <layer></layer>;
            ret.setName(layerName);

            for (var i:int = 0; i < _objectsContainer.numChildren; i++) {
                ret.appendChild((_objectsContainer.getChildAt(i) as GameObject).xml);
            }

            return ret;
        }

        override public function set xml(to:XML):void {
            clear();

            for each (var o:XML in to.children()) {
                addObjectFromXML(o);
            }

            setSelboxVisibility(active);
        }

        /* ========================== EVENTS ========================== */

        private function onKeyDown(e:KeyboardEvent):void {
            if (Ogmo.missKeys) {
                return;
            }

            if (e.keyCode == 46) {
                //DELETE
                if (!(tool is ToolObjectNodes)) {
                    removeObjects(_selection);
                }
            }
            else if (e.keyCode == 37) {
                //LEFT
                if (e.ctrlKey) {
                    resizeObjectsRelative(_selection, -gridSize, 0);
                } else if (e.shiftKey) {
                    rotateObjects(_selection, -1);
                } else {
                    moveObjects(_selection, -gridSize, 0);
                }
                Ogmo.windows.windowObjectInfo.setTarget(_selection);
            }
            else if (e.keyCode == 38) {
                //UP
                if (e.ctrlKey) {
                    resizeObjectsRelative(_selection, 0, -gridSize);
                } else {
                    moveObjects(_selection, 0, -gridSize);
                }
                Ogmo.windows.windowObjectInfo.setTarget(_selection);
            }
            else if (e.keyCode == 39) {
                //RIGHT
                if (e.ctrlKey) {
                    resizeObjectsRelative(_selection, gridSize, 0);
                } else if (e.shiftKey) {
                    rotateObjects(_selection, 1);
                } else {
                    moveObjects(_selection, gridSize, 0);
                }
                Ogmo.windows.windowObjectInfo.setTarget(_selection);
            }
            else if (e.keyCode == 40) {
                //DOWN
                if (e.ctrlKey) {
                    resizeObjectsRelative(_selection, 0, gridSize);
                } else if (e.shiftKey) {
                    resetObjectsRotation(_selection);
                } else {
                    moveObjects(_selection, 0, gridSize);
                }
                Ogmo.windows.windowObjectInfo.setTarget(_selection);
            }
        }

    }
}