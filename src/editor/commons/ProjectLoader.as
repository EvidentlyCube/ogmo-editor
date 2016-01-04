/**
 * Created with IntelliJ IDEA.
 * User: Ryc
 * Date: 18.05.13
 * Time: 11:40
 * To change this template use File | Settings | File Templates.
 */
package editor.commons {
    import editor.definitions.LayerDefinition;
    import editor.definitions.NodesDefinition;
    import editor.definitions.ObjectDefinition;
    import editor.definitions.ValueDefinition;
    import editor.layers.object.ObjectFolder;
    import editor.layers.tile.Tileset;
    import editor.ui.elements.ObjectLayerElementButton;
    import editor.ui.windows.ObjectPaletteWindow;
    import editor.utils.Utils;

    import flash.filesystem.File;

    public class ProjectLoader {
        static private const DEFAULT_BG_COLOR:uint = 0x555599;
        static public const DEFAULT_GRID_COLOR:uint = 0x33FFFFFF;

        //Project Settings
        public var name:String;
        public var defaultWidth:int;
        public var defaultHeight:int;
        public var minWidth:int;
        public var minHeight:int;
        public var maxWidth:int;
        public var maxHeight:int;
        public var sizeInTiles:Boolean;
        public var tileWidth:int;
        public var tileHeight:int;
        public var bgColor:uint;
        public var workingDirectory:File;
        public var savingDirectory:String;
        public var exportLevelSize:Boolean;
        public var file:File;
        public var tilesets:Vector.<Tileset>;
        public var layers:Vector.<LayerDefinition>;
        public var levelValues:Vector.<ValueDefinition>;
        public var objects:ObjectFolder;
        public var tilesetsCount:uint = 0;

        //Project Assets
        public var objectsCount:uint = 0;
        public var xmlSubdefinitions:Array = [];

        public function constructProject(file:File):void {
            var o:XML;
            var lay:LayerDefinition;

            //Set the project file
            this.file = file;

            var xml:XML = Utils.readXmlFromFile(file);

            //Error checking
            if (QName(xml.name()).localName != "project") {
                throw new Error("Root element is not a <project> tag.");
            }
            if (xml.settings.length() == 0) {
                throw new Error("Project has no <settings> tag.");
            }
            if (xml.settings[0].defaultWidth.length() == 0) {
                throw new Error("Project has no <defaultWidth> tag.");
            }
            if (xml.settings[0].defaultHeight.length() == 0) {
                throw new Error("Project has no <defaultHeight> tag.");
            }
            if (xml.layers.length() == 0) {
                throw new Error("Project has no layers.");
            }

            //Name
            name = Reader.readString(xml.name, "Untitled Project");

            //Settings
            defaultWidth = Reader.readInt(xml.settings[0].defaultWidth, 0, "defaultWidth", 1);
            defaultHeight = Reader.readInt(xml.settings[0].defaultHeight, 0, "defaultHeight", 1);

            minWidth = Reader.readInt(xml.settings[0].minWidth, defaultWidth, "minWidth", 1, defaultWidth);
            minHeight = Reader.readInt(xml.settings[0].minHeight, defaultHeight, "minHeight", 1, defaultHeight);

            maxWidth = Reader.readInt(xml.settings[0].maxWidth, defaultWidth, "maxWidth", defaultWidth);
            maxHeight = Reader.readInt(xml.settings[0].maxHeight, defaultHeight, "maxHeight", defaultHeight);

            bgColor = Reader.readColor24(xml.settings[0].bgColor, DEFAULT_BG_COLOR, "bgColor");
            exportLevelSize = Reader.readBoolean(xml.settings[0].exportLevelSize, true, "exportLevelSize");

            sizeInTiles = Reader.readBoolean(xml.settings[0].sizeInTiles, false, 'sizeInTiles');
            tileWidth = Reader.readInt(xml.settings[0].tileWidth, 16, 'tileWidth', 2, 1024);
            tileHeight = Reader.readInt(xml.settings[0].tileHeight, 16, 'tileHeight', 2, 1024);

            ObjectLayerElementButton.gridSize = Reader.readInt(xml.settings[0].objectGridSize, 24, "objectGridSize", 8, 128);
            ObjectPaletteWindow.windowWidth = Reader.readInt(xml.settings[0].objectsWindowWidth, 128, "objectsWindowWidth", 32, 1920);

            for each(var xmlDefinition:XML in xml..definition) {
                xmlSubdefinitions[xmlDefinition.@name.toString()] = xmlDefinition.children();
            }

            for each(var xmlSubstitution:XML in xml..substitution) {
                xmlSubstitution.parent().replace('substitution', xmlSubdefinitions[xmlSubstitution.@name.toString()]);
            }

            if (sizeInTiles) {
                defaultWidth = (defaultWidth / tileWidth | 0) * tileWidth;
                defaultHeight = (defaultHeight / tileHeight | 0) * tileHeight;

                minWidth = (minWidth / tileWidth | 0) * tileWidth;
                minHeight = (minHeight / tileHeight | 0) * tileHeight;

                maxWidth = Math.ceil(maxWidth / tileWidth) * tileWidth;
                maxHeight = Math.ceil(maxHeight / tileHeight) * tileHeight;
            }

            //Working directory (has to exist)
            workingDirectory = file.resolvePath("..");
            if (xml.settings[0].workingDirectory.length()) {
                workingDirectory = workingDirectory.resolvePath(xml.settings[0].workingDirectory[0]);
            }
            if (!workingDirectory.exists) {
                throw new Error("Specified working directory does not exist.");
            }

            //Saving directory
            var saveDir:File = file.resolvePath("..");
            if (xml.settings[0].savingDirectory.length()) {
                saveDir = saveDir.resolvePath(xml.settings[0].savingDirectory[0]);
                if (!saveDir.exists) {
                    throw new Error("Specified saving directory does not exist.");
                }
            }
            savingDirectory = saveDir.url;

            //Level values
            if (xml.values[0]) {
                constructLevelValues(xml.values[0]);
            }

            //Tilesets
            tilesetsCount = 0;
            if (xml.tilesets[0]) {
                for each (o in xml.tilesets[0].tileset) {
                    if (o.@name.length() == 0) {
                        throw new Error("A tileset has no name attribute.");
                    }
                    if (o.@tileWidth.length() == 0) {
                        throw new Error("Tileset " + o.@name + " has no tileWidth attribute.");
                    }
                    if (o.@tileHeight.length() == 0) {
                        throw new Error("Tileset " + o.@name + " has no tileHeight attribute.");
                    }
                    if (o.@image.length() == 0) {
                        throw new Error("Tileset " + o.@name + " has no image attribute.");
                    }

                    var tilesetTileWidth:int = Reader.readInt(o.@tileWidth, 0, "tileset -> tileWidth", 1);
                    var tilesetTileHeight:int = Reader.readInt(o.@tileHeight, 0, "tileset -> tileHeight", 1);
                    var paletteScale:Number = Reader.readNumber(o.@paletteScale, 1, "tileset -> paletteScale", 0.1, 10);

                    addTileset(o.@name, o.@image, tilesetTileWidth, tilesetTileHeight, paletteScale);
                }
            }

            //Objects
            objectsCount = 0;
            if (xml.objects[0]) {
                constructObjects(xml.objects[0].children(), objects);
            }

            //Layers
            for each (o in xml.layers[0].children()) {
                //Error checking
                if (o.@name.length() == 0) {
                    throw new Error("A layer has no name attribute.");
                }
                if (o.@name.indexOf(" ") != -1) {
                    throw new Error("Layers may not have names with spaces.");
                }
                if (layerNameUsed(o.@name)) {
                    throw new Error("Two or more layers defined with name \"" + o.@name + "\".");
                }
                if (o.@gridSize.length() == 0) {
                    throw new Error("Layer " + o.@name + " has no gridSize attribute.");
                }

                var gridSize:uint = Reader.readInt(o.@gridSize, 16, o.@name.localName + " -> gridSize", 1);
                var gridColor:uint = Reader.readColor32(o.@gridColor, DEFAULT_GRID_COLOR, o.@name.localName + " -> gridColor");
                var drawGridSize:uint = Reader.readInt(o.@drawGridSize, gridSize, o.@name.localName + " -> drawGridSize", 1);

                if (o.name().localName == "tiles") {
                    //DEFINE TILES LAYER
                    if (tilesetsCount == 0) {
                        throw new Error("Tiles layer but no tilesets defined.");
                    }

                    var tilesetName:String = Reader.readString(o.@tileset, '');

                    if (!getTilesetByName(tilesetName)) {
                        throw new Error("Tileset '" + tilesetName + "' is not defined");
                    }

                    lay = new LayerDefinition(LayerDefinition.TILES, o.@name, gridSize, gridColor, drawGridSize);
                    lay.tileset = getTilesetByName(tilesetName);
                    layers.push(lay);
                }
                else if (o.name().localName == "grid") {
                    // DEFINE GRID LAYER
                    lay = new LayerDefinition(LayerDefinition.GRID, o.@name, gridSize, gridColor, drawGridSize);
                    lay.bgColor = Reader.readColor32(o.@bgColor, 0xFF000000, "grid -> bgcolor");
                    lay.exportAsObjects = Reader.readBoolean(o.@exportAsObjects, false, "grid -> exportAsObjects");
                    lay.color = Reader.readColor32(o.@color, 0xFF000000, "grid -> color");

                    if (!lay.exportAsObjects) {
                        lay.newLine = Reader.readString(o.@newLine, "\n");
                    } else {
                        lay.newLine = "\n";
                    }
                    layers.push(lay);
                }
                else if (o.name().localName == "objects") {
                    //DEFINE OBJECTS LAYER
                    if (objectsCount == 0) {
                        throw new Error("Objects layer but no objects defined.");
                    }

                    lay = new LayerDefinition(LayerDefinition.OBJECTS, o.@name, gridSize, gridColor, drawGridSize);
                    layers.push(lay);
                }
                else {
                    throw new Error("Unknown layer type \"" + o.name().localName + "\".");
                }
            }

            //More error checking
            if (layers.length == 0) {
                throw new Error("Project has no layers.");
            }
        }

        protected function getTilesetByName(name:String):Tileset {
            for (var i:int = 0; i < tilesets.length; i++) {
                if (tilesets[i].tilesetName == name) {
                    return tilesets[i];
                }
            }
            return null;
        }

        private function constructLevelValues(xml:XML):void {
            levelValues = new Vector.<ValueDefinition>;
            for each (var o:XML in xml.children()) {
                var variableName:String = o.@name;
                if (o.@name.length() == 0) {
                    throw new Error("A level value has no name attribute.");
                }
                if (valueNameUsed(variableName, levelValues)) {
                    throw new Error("Two or more level values have the name \"" + o.@name + "\".");
                }

                var variableType:String = o.name().localName;
                if (variableType === "angle" || variableType === "radius"){
                    throw new Error("Angle and Radius can't be used for level values");
                }

                var v:ValueDefinition = constructValue(o);

                levelValues.push(v);
            }
        }

        private function layerNameUsed(str:String):Boolean {
            for each (var l:LayerDefinition in layers) {
                if (l.name == str) {
                    return true;
                }
            }
            return false;
        }

        private function valueNameUsed(str:String, valueDefs:Vector.<ValueDefinition>):Boolean {
            for each (var v:ValueDefinition in valueDefs) {
                if (v.name == str) {
                    return true;
                }
            }
            return false;
        }

        private function addTileset(name:String, url:String, tileWidth:int, tileHeight:int, paletteScale:Number):Tileset {
            if (getTilesetByName(name) != null) {
                throw new Error("Two or more Tilesets defined with name \"" + name + "\".");
            }

            tilesetsCount++;

            var t:Tileset = new Tileset(name, url, tileWidth, tileHeight, paletteScale);
            tilesets.push(t);
            return t;
        }

        private function constructObjects(xml:XMLList, folder:ObjectFolder):void {
            var o:XML;
            for each (o in xml) {
                if (o.name().localName == "object") {
                    if (o.@name.length() == 0) {
                        throw new Error("An object has no name attribute.");
                    }
                    if (o.@name.indexOf(" ") != -1) {
                        throw new Error("Objects may not have names with spaces.");
                    }
                    if (o.@image.length() == 0) {
                        throw new Error("Object " + o.@name + " has no image attribute.");
                    }
                    if (o.@width.length() == 0) {
                        throw new Error("Object " + o.@name + " has no width attribute.");
                    }
                    if (o.@height.length() == 0) {
                        throw new Error("Object " + o.@name + " has no height attribute.");
                    }

                    var width:uint = Reader.readInt(o.@width, 1, "object -> width", 1);
                    var height:uint = Reader.readInt(o.@height, 1, "object -> height", 1);
                    var imageWidth:uint = Reader.readInt(o.@imageWidth, -1, "object -> imageWidth");
                    var imageHeight:uint = Reader.readInt(o.@imageHeight, -1, "object -> imageHeight");
                    var imageOffsetX:int = Reader.readInt(o.@imageOffsetX, 0, "object -> imageOffsetX");
                    var imageOffsetY:int = Reader.readInt(o.@imageOffsetY, 0, "object -> imageOffsetY");

                    var objDef:ObjectDefinition;
                    objDef = new ObjectDefinition(o.@name, o.@image, width, height, imageWidth, imageHeight, imageOffsetX, imageOffsetY);
                    objDef.originX = Reader.readInt(o.@originX, 0, "object -> originX");
                    objDef.originY = Reader.readInt(o.@originY, 0, "object -> originY");
                    objDef.resizableX = Reader.readBoolean(o.@resizableX, false, "object -> resizableX");
                    objDef.resizableY = Reader.readBoolean(o.@resizableY, false, "object -> resizableY");
                    objDef.rotatable = Reader.readBoolean(o.@rotatable, false, "object -> rotatable");
                    objDef.rotationPrecision = Reader.readNumber(o.@rotationPrecision, 45, "object -> rotationPrecision", 0.1, 359.9);
                    objDef.exportRadians = Reader.readBoolean(o.@exportRadians, false, "object -> exportRadians");
                    objDef.limit = Reader.readInt(o.@limit, 0, "object -> limit", 0);
                    objDef.tile = Reader.readBoolean(o.@tile, false, "object -> tile");
                    folder.contents.push(objDef);

                    //Values
                    if (o.values[0]) {
                        constructObjectValues(o.values[0], objDef);
                    }

                    //Nodes
                    if (o.nodes[0]) {
                        var drawObject:Boolean = Reader.readBoolean(o.nodes[0].@drawObject, false, "nodes -> drawObject");
                        var limit:uint = Reader.readInt(o.nodes[0].@limit, -1, "nodes -> limit", 0);
                        var lineMode:uint = Reader.readInt(o.nodes[0].@lineMode, NodesDefinition.NONE, "nodes -> lineMode", NodesDefinition.NONE, NodesDefinition.FAN);
                        var color:uint = Reader.readColor24(o.nodes[0].@color, NodesDefinition.DEFAULT_COLOR, "nodes -> color");
                        objDef.nodesDefinition = new NodesDefinition(drawObject, limit, lineMode, color);
                    }

                    objectsCount++;
                }
                else if (o.name().localName == "folder") {
                    if (o.@name.length() == 0) {
                        throw new Error("An object folder has no name attribute!");
                    }

                    var image:String = Reader.readString(o.@image, "");
                    var imgWidth:int = Reader.readInt(o.@imageWidth, -1, "folder -> imageWidth", 1);
                    var imgHeight:int = Reader.readInt(o.@imageHeight, -1, "folder -> imageHeight", 1);
                    var imgOffsetX:int = Reader.readInt(o.@imageOffsetX, 0, "folder -> imageOffsetX", 0);
                    var imgOffsetY:int = Reader.readInt(o.@imageOffsetY, 0, "folder -> imageOffsetY", 0);

                    var newFolder:ObjectFolder = new ObjectFolder(o.@name, image, imgWidth, imgHeight, imgOffsetX, imgOffsetY, folder);
                    folder.contents.push(newFolder);
                    constructObjects(o.children(), newFolder);
                }
            }
        }

        private function constructValue(o:XML):ValueDefinition {
            var v:ValueDefinition;
            var name:String = Reader.readString(o.@name);
            var prettyName:String = Reader.readString(o.@display, name);

            switch (String(o.name().localName)) {
                case("boolean"):
                    v = new ValueDefinition(name, prettyName, ValueDefinition.TYPE_BOOL, Reader.readBoolean(o.attribute("default"), false, "boolean -> default"));
                    break;

                case("integer"):
                    v = new ValueDefinition(name, prettyName, ValueDefinition.TYPE_INT, Reader.readInt(o.attribute("default"), 0, "integer -> default"));
                    v.min = Reader.readInt(o.@min, int.MIN_VALUE, "integer -> min");
                    v.max = Reader.readInt(o.@max, int.MAX_VALUE, "integer -> max");
                    v.wraps = Reader.readBoolean(o.@wraps, false, "integer -> max");
                    break;

                case("number"):
                    v = new ValueDefinition(name, prettyName, ValueDefinition.TYPE_NUMBER, Reader.readNumber(o.attribute("default"), 0, "number -> default"));
                    v.min = Reader.readNumber(o.@min, int.MIN_VALUE, "number -> min");
                    v.max = Reader.readNumber(o.@max, int.MAX_VALUE, "number -> max");
                    v.wraps = Reader.readBoolean(o.@wraps, false, "integer -> max");
                    break;

                case("string"):
                    v = new ValueDefinition(name, prettyName, ValueDefinition.TYPE_STRING, Reader.readString(o.attribute("default")));
                    v.maxLength = Reader.readInt(o.@maxLength, -1, "string -> maxLength");
                    break;
                case("text"):
                    v = new ValueDefinition(name, prettyName, ValueDefinition.TYPE_TEXT, Reader.readString(o.attribute("default")));
                    v.maxLength = Reader.readInt(o.@maxLength, -1, "text -> maxLength");
                    break;

                case("select"):
                    v = new ValueDefinition(name, prettyName, ValueDefinition.TYPE_SELECT, null);
                    v.selectOptions = Reader.readOptions(o);

                    if (v.selectOptions.length < 1) {
                        throw new Error("No options for <select> variable \"" + o.name().localName + '"');
                    }

                    var selectOptions:SelectOption = v.getOptionForValue(Reader.readString(o.attribute("default")));

                    if (!selectOptions) {
                        throw new Error("Default value for select \"" + o.name().localName + '" was not found in the options.');
                    }
                    v.def = selectOptions.value;
                    break;

                case("radius"):
                    v = new ValueDefinition("rotationRadius", prettyName, ValueDefinition.TYPE_RADIUS, Reader.readNumber(o.attribute("default"), 0, "radius -> default"));
                    v.min = Reader.readNumber(o.@min, int.MIN_VALUE, "radius -> min");
                    v.max = Reader.readNumber(o.@max, int.MAX_VALUE, "radius -> max");
                    break;

                case("angle"):
                    v = new ValueDefinition("rotationAngle", prettyName, ValueDefinition.TYPE_ANGLE, Reader.readNumber(o.attribute("default"), 0, "angle -> default"));
                    v.min = -360;
                    v.max = 360;
                    v.wraps = true;
                    break;

                default:
                    throw new Error("Unrecognized value type \"" + o.name().localName + "\" in level values.");
            }

            return v;
        }

        private function constructObjectValues(xml:XML, objDef:ObjectDefinition):void {
            objDef.values = new Vector.<ValueDefinition>;
            for each (var o:XML in xml.children()) {
                var name:String = o.@name;
                var type:String = o.name().localName;
                if (o.@name.length() == 0 && type !== "radius" && type !== "angle") {
                    throw new Error("An object value has no name attribute for object \"" + objDef.name + "\".");
                }
                if (name == "x") {
                    throw new Error("Object \"" + objDef.name + "\" has a value with name \"x\".");
                }
                if (name == "y") {
                    throw new Error("Object \"" + objDef.name + "\" has a value with name \"y\".");
                }
                if (name == "width" && objDef.resizableX) {
                    throw new Error("Object \"" + objDef.name + "\" is resizableX and has a value with name \"width\".");
                }
                if (name == "height" && objDef.resizableY) {
                    throw new Error("Object \"" + objDef.name + "\" is resizableY and has a value with name \"height\".");
                }
                if (valueNameUsed(name, objDef.values)) {
                    throw new Error("Two or more object values have the name \"" + name + "\" for object \"" + objDef.name + "\".");
                }
                if (name === "rotationAngle" || name === "rotationRadius"){
                    throw new Error("rotationAngle and rotationRadius are reserved variable names.");
                }

                var v:ValueDefinition = constructValue(o);

                objDef.values.push(v);
            }
        }
    }
}
