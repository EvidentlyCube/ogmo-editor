package editor.commons {
    import editor.definitions.*;
    import editor.events.*;
    import editor.layers.grid.GridLayer;
    import editor.layers.Layer;
    import editor.layers.object.ObjectFolder;
    import editor.layers.object.ObjectLayer;
    import editor.layers.tile.TileLayer;
    import editor.layers.tile.Tileset;
    import editor.ui.windows.MouseCoordsWindow;
    import editor.utils.PNGEncoder;
    import editor.utils.Utils;

    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filesystem.File;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class Level extends Sprite {
        //Zoom levels
        static public const ZOOMS:Array = [ 0.1, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4 ];

        //Palettes
        public var selectedTileset:Tileset;
        public var selectedTilePoint:Point;
        public var selectedObject:ObjectDefinition;
        public var selectedObjectFolder:ObjectFolder;

        //The general stuff
        public var values:Vector.<Value>;
        public var levelName:String;
        public var saved:Boolean;
        public var layersContainer:Sprite;        //Parent of all the layers
        public var bg:Sprite;            //The background color layer
        private var _levelWidth:int;
        private var _levelHeight:int;

        //The holder, which holds the layers and the bg
        private var _selectedLayerIndex:int = 0;
        private var _layers:Vector.<Layer>;
        private var holder:Sprite;        //Holds the layers AND the background

        //For middle-click panning
        private var spaceHeld:Boolean;
        private var moving:Boolean;
        private var moveX:Number;
        private var moveY:Number;

        public function Level(name:String) {
            //Init name
            levelName = name;
            saved = false;

            //Init palettes
            selectedTilePoint = new Point;
            selectedTileset = null;
            selectedObject = null;

            //Not scrolling the view
            moving = false;
            spaceHeld = false;

            _layers = new Vector.<Layer>();

            //Set up to initialize
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        public function initListeners():void {
            //Add the new event listeners
            addEventListener(Event.REMOVED_FROM_STAGE, destroy);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
            stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }

        public function toggleGrid():void {
            Ogmo.gridOn = !Ogmo.gridOn;

            selectedLayer.handleGridMode();

            Ogmo.windowMenu.refreshState();
        }

        public function moveEverything(x:int, y:int):void {
            for each(var layer:Layer in _layers) {
                layer.moveEverything(x, y);
            }
        }

        public function centerView():void {
            holder.x = 400;
            holder.y = 300;
        }

        public function saveScreenshot():void {
            selectedLayer.active = false;

            var bd:BitmapData = new BitmapData(_levelWidth, _levelHeight);
            bd.fillRect(new Rectangle(0, 0, _levelWidth, _levelHeight), 0xFF000000 + Ogmo.project.bgColor);

            for (var i:int = 0; i < layersContainer.numChildren; i++) {
                bd.draw(layersContainer.getChildAt(i));
            }

            var file:File = File.desktopDirectory;
            file.save(PNGEncoder.encode(bd), "screenshot.png");

            selectedLayer.active = true;
        }

        public function setLayer(target:int):void {
            //Error if invalid layer
            if (target >= layersContainer.numChildren || target < 0) {
                throw new Error("Switching to non-existent layer!");
            }

            //Deactivate old active layer
            if (selectedLayerIndex != -1) {
                selectedLayer.active = false;
            }

            //Activate the new one
            _selectedLayerIndex = target;
            selectedLayer.active = true;

            resetLayersAlpha();

            Ogmo.windows.setLayer(target);

            //If the layer is a tile layer not allowed multiple tilesets, switch to its current tileset
            if (selectedLayer is TileLayer) {
                var layer:TileLayer = selectedLayer as TileLayer;
                if (layer.tileset) {
                    setTileset(Ogmo.project.getTilesetNumFromName(layer.tileset.tilesetName));
                }
            }

            //Refresh menus for undo/redo
            Ogmo.windowMenu.refreshState();

            //dispatch the event
            stage.dispatchEvent(new LayerSelectEvent(selectedLayer));
        }

        public function resetLayersAlpha():void {
            var i:int;
            var after:Boolean = false;
            for (i = 0; i < layersContainer.numChildren; i++) {
                layersContainer.getChildAt(i).alpha = 1;
                if (i == _selectedLayerIndex) {
                    after = true;
                    continue;
                }
                if (after) {
                    var layer:Layer = layersContainer.getChildAt(i) as Layer;
                    layer.alpha = layer.renderTransparent ? 0.2 : 1;

                }
            }
        }

        public function setTileset(value:int):void {
            //Do nothing if that's the current tileset
            if (Ogmo.project.tilesets[ value ] == selectedTileset) {
                return;
            }

            //Error if invalid tileset
            if (value >= Ogmo.project.tilesetsCount || value < 0) {
                throw new Error("Switching to non-existent tileset!");
            }

            selectedTileset = Ogmo.project.tilesets[ value ];
            selectedTilePoint.x = 0;
            selectedTilePoint.y = 0;

            //Set the tileset in the windows
            Ogmo.windows.setTileset(value);

            stage.dispatchEvent(new TilesetSelectEvent(selectedTileset));
        }

        /* ========================== SETTING THINGS ========================== */

        public function setSize(newWidth:int, newHeight:int):void {
            //Exit if no change
            if (newWidth == _levelWidth && newHeight == _levelHeight) {
                return;
            }

            //Resize all layers
            for (var i:int = 0; i < layersContainer.numChildren; i++) {
                (layersContainer.getChildAt(i) as Layer).resizeLevel(newWidth, newHeight);
            }

            //Change the actual values
            _levelWidth = newWidth;
            _levelHeight = newHeight;

            //Readjust positions
            layersContainer.x = -_levelWidth / 2;
            layersContainer.y = -_levelHeight / 2;
            bg.x = -_levelWidth / 2;
            bg.y = -_levelHeight / 2;

            //Redraw the stage background
            drawBackground();
        }

        private function drawBackground():void {
            bg.graphics.clear();
            bg.graphics.beginFill(0x000000, 0.5);
            bg.graphics.drawRect(6, 6, _levelWidth, _levelHeight);
            bg.graphics.endFill();
            bg.graphics.beginFill(Ogmo.project.bgColor);
            bg.graphics.drawRect(0, 0, _levelWidth, _levelHeight);
            bg.graphics.endFill();
        }

        private function init(e:Event):void {
            //Delete the event listener
            removeEventListener(Event.ADDED_TO_STAGE, init);

            initListeners();

            //Init to default size properties
            _levelWidth = Ogmo.project.defaultWidth;
            _levelHeight = Ogmo.project.defaultHeight;

            //Set tileset and object to the defaults (first ones)
            if (Ogmo.project.tilesets.length > 0) {
                setTileset(0);
            }
            if (Ogmo.project.objects.length > 0) {
                Ogmo.windows.setObjectFolder(Ogmo.project.objects);
            }

            //Init the holder
            holder = new Sprite;
            holder.x = stage.stageWidth / 2;
            holder.y = stage.stageHeight / 2;
            addChild(holder);

            //Init the bg color
            bg = new Sprite;
            drawBackground();
            bg.x = -_levelWidth / 2;
            bg.y = -_levelHeight / 2;
            holder.addChild(bg);

            //Init layer holder
            holder.addChild(layersContainer = new Sprite);
            layersContainer.x = -_levelWidth / 2;
            layersContainer.y = -_levelHeight / 2;

            //Init layers
            var layer:Layer;
            var l:LayerDefinition;
            for (var i:int = 0; i < Ogmo.project.layers.length; i++) {
                l = Ogmo.project.layers[ i ];
                if (l.type == LayerDefinition.TILES) {
                    layer = new TileLayer(l.name, l.gridSize, l.gridColor, l.drawGridSize, l.tileset);
                }
                else if (l.type == LayerDefinition.GRID) {
                    layer = new GridLayer(l.name, l.gridSize, l.gridColor, l.drawGridSize, l.color, l.bgColor, l.exportAsObjects, l.newLine);
                }
                else if (l.type == LayerDefinition.OBJECTS) {
                    layer = new ObjectLayer(l.name, l.gridSize, l.gridColor, l.drawGridSize);
                }

                _layers.push(layer);
                layersContainer.addChild(layer);
            }

            //Init values
            if (Ogmo.project.levelValues) {
                values = new Vector.<Value>;
                var value:Value;
                for each (var v:ValueDefinition in Ogmo.project.levelValues) {
                    value = v.getValue();
                    values.push(value);
                }
            }

            //Init the mouse co-ords
            addChild(new MouseCoordsWindow());

            //Set the layer to the first one
            setLayer(0);

            Ogmo.windows.updateVisibilities();
        }

        private function destroy(e:Event):void {
            removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
            stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
            stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        }

        /* ========================== GETS/SETS ========================== */

        private function onMouseWheel(e:MouseEvent):void {
            zoom += (e.delta < 0) ? ( -1) : (1);
        }

        private function onMouseDown(e:MouseEvent):void {
            if (spaceHeld) {
                moving = true;
                moveX = e.stageX - holder.x;
                moveY = e.stageY - holder.y;
            }
        }

        private function onMouseUp(e:MouseEvent = null):void {
            moving = false;
        }

        private function onMiddleMouseDown(e:MouseEvent):void {
            moving = true;
            moveX = e.stageX - holder.x;
            moveY = e.stageY - holder.y;
        }

        private function onMiddleMouseUp(e:MouseEvent = null):void {
            moving = false;
        }

        private function onMouseMove(e:MouseEvent):void {
            if (moving) {
                holder.x = e.stageX - moveX;
                holder.y = e.stageY - moveY;
            }
        }

        private function onMouseLeave(e:Event):void {
            onMiddleMouseUp();
        }

        private function onKeyDown(e:KeyboardEvent):void {
            if (Ogmo.missKeys) {
                return;
            }

            //NUMBER KEYS
            if (e.ctrlKey) {
                if (e.keyCode >= 49 && e.keyCode <= 57 && Ogmo.project.layers.length >= e.keyCode - 48) {
                    setLayer(e.keyCode - 49);
                }
                else if (e.keyCode == 38) {
                    moveEverything(0, -1)
                }
                else if (e.keyCode == 39) {
                    moveEverything(1, 0)
                }
                else if (e.keyCode == 37) {
                    moveEverything(-1, 0)
                }
                else if (e.keyCode == 40) {
                    moveEverything(0, 1)
                }
            }
            else if (e.keyCode == 32) {
                layersContainer.mouseChildren = false;
                spaceHeld = true;
            }
        }

        private function onKeyUp(e:KeyboardEvent):void {
            if (e.keyCode == 32) {
                layersContainer.mouseChildren = true;
                spaceHeld = false;
            }
        }

        public function get zoom():int {
            for (var i:int = 0; i < ZOOMS.length; i++) {
                if (ZOOMS[ i ] == holder.scaleX) {
                    return i;
                }
            }
            return -1;
        }

        /* ========================== EVENTS ========================== */

        public function set zoom(value:int):void {
            var cur:int;
            cur = Utils.within(0, value, ZOOMS.length - 1);

            holder.scaleX = ZOOMS[ cur ];
            //noinspection JSSuspiciousNameCombination
            holder.scaleY = holder.scaleX;

            Ogmo.showMessage("Zoom: " + (ZOOMS[ cur ] * 100) + "%");
            Ogmo.windowMenu.refreshState();
        }

        public function get jsonString():String {
            return JSON.stringify(this.json);
        }

        public function get json():Object{
            var json:Object = {};

            json.options = Reader.writeValuesToJson(values);

            if (Ogmo.project.exportLevelSize) {
                json.width = _levelWidth;
                json.height = _levelHeight;
            }

            //Layers
            json.layers = {};
            for (var i:int = 0; i < layersContainer.numChildren; i++) {
                var layer:Layer = layersContainer.getChildAt(i) as Layer;
                json.layers[layer.layerName] = layer.json;
            }

            return json;
        }

        public function set json(value:Object):void {
            //values
            Reader.readValuesJson(value.options, values);

            setSize(
                Reader.readIntJson(value.width, Ogmo.project.defaultWidth, "width", Ogmo.project.minWidth, Ogmo.project.maxWidth),
                Reader.readIntJson(value.height, Ogmo.project.defaultHeight, "height", Ogmo.project.minHeight, Ogmo.project.maxHeight)
            );

            for (var layerName:String in value.layers) {
                if (!value.layers.hasOwnProperty(layerName)){
                    continue;
                }

                var isValidLayer:Boolean = false;
                for (var i:int = 0; i < layersContainer.numChildren; i++) {
                    var layer:Layer = layersContainer.getChildAt(i) as Layer;
                    if (layerName == layer.layerName) {
                        layer.json = value.layers[layerName];
                        isValidLayer = true;
                        break;
                    }
                }

                if (!isValidLayer) {
                    throw new Error("Layer \"" + layerName + "\" not defined for this project!");
                }
            }
        }

        public function get xml():XML {
            var temp:XML;
            var ret:XML = <level></level>;
            ret.setName("level");

            //values
            Reader.writeValuesToXml(ret, values);

            if (Ogmo.project.exportLevelSize) {
                //Stage width
                temp = <width></width>;
                temp.setChildren(_levelWidth);
                ret.appendChild(temp);

                //Stage height
                temp = <height></height>;
                temp.setChildren(_levelHeight);
                ret.appendChild(temp);
            }

            //Layers
            for (var i:int = 0; i < layersContainer.numChildren; i++) {
                temp = (layersContainer.getChildAt(i) as Layer).xml;
                if (temp) {
                    ret.appendChild(temp);
                }
            }

            return ret;
        }

        public function set xml(targetXml:XML):void {
            //values
            Reader.readValuesXml(targetXml, values);

            for each (var xmlNode:XML in targetXml.children()) {
                var nodeName:String = QName(xmlNode.name()).localName;

                if (nodeName == "width") {
                    //<WIDTH>
                    setSize(Reader.readIntXml(xmlNode, Ogmo.project.defaultWidth, "width", Ogmo.project.minWidth, Ogmo.project.maxWidth), levelHeight);
                }
                else if (nodeName == "height") {
                    //<HEIGHT>
                    setSize(levelWidth, Reader.readIntXml(xmlNode, Ogmo.project.defaultHeight, "height", Ogmo.project.minHeight, Ogmo.project.maxHeight));
                }
                else {
                    //Layers!
                    var isValidLayer:Boolean = false;
                    for (var i:int = 0; i < layersContainer.numChildren; i++) {
                        var layer:Layer = layersContainer.getChildAt(i) as Layer;
                        if (nodeName == layer.layerName) {
                            layer.xml = xmlNode;
                            isValidLayer = true;
                            break;
                        }
                    }

                    if (!isValidLayer) {
                        throw new Error("Layer \"" + nodeName + "\" not defined for this project!");
                    }
                }
            }
        }

        public function get selectedLayer():Layer {
            if (!layersContainer) {
                return null;
            }
            else {
                return layersContainer.getChildAt(_selectedLayerIndex) as Layer;
            }
        }

        public function get selectedLayerIndex():int {
            return _selectedLayerIndex;
        }

        public function get levelWidth():int {
            return _levelWidth;
        }

        public function get levelHeight():int {
            return _levelHeight;
        }

        public function get levelWidthInTiles():int {
            return _levelWidth / Ogmo.project.tileWidth;
        }

        public function get levelHeightInTiles():int {
            return _levelHeight / Ogmo.project.tileHeight;
        }
    }
}