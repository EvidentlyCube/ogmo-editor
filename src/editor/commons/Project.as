/*

 XML Structure:

 <project>
 <name></name>
 <settings>
 <bgColor></bgColor>
 <defaultWidth></defaultWidth>
 <defaultHeight></defaultHeight>
 <minWidth></minWidth>
 <minHeight></minHeight>
 <maxWidth></maxWidth>
 <maxHeight></maxHeight>
 <sizeInTiles></sizeInTiles>
 <tileWidth></tileWidth>
 <tileHeight></tileHeight>
 <workingDirectory></workingDirectory>
 <savingDirectory></savingDirectory>
 <id></id>
 </settings>
 <values>
 <boolean name="" default=""/>
 <integer name="" default="" min="" max=""/>
 <number name="" default="" min="" max="" />
 <string name="" default="" maxLength="" />
 <text name="" default="" maxLength="" />
 </values>
 <tilesets>
 <tileset name="" image="" tileWidth="" tileHeight="" paletteScale=""/>
 </tilesets>
 <objects>
 <folder name="" image="" imageWidth="" imageHeight="" imageOffsetX="" imageOffsetY="">
 <object name="" image="" width="" height="" imageWidth="" imageHeight="" imageOffsetX=""
 imageOffsetY="" originX="" originY="" resizableX="" resizableY="" rotatable=""
 rotationPrecision="" exportRadians="" limit="" tile="">
 <values />
 <nodes drawObject="" limit="" lineMode="" color="" />
 </object
 </folder>
 </objects>
 <layers>
 <grid name="" exportAsObjects="" color="" newLine="" gridSize="" gridColor="" drawGridSize="" />
 <tiles name="" tileset="" gridSize="" gridColor="" drawGridSize="" />
 <objects name="" gridSize="" gridColor="" drawGridSize="" />
 </layers>
 </project>

 */

package editor.commons {
    import editor.definitions.*;
    import editor.layers.object.ObjectFolder;
    import editor.layers.tile.Tileset;

    public class Project extends ProjectLoader {


        public function Project() {
            //Init project arrays
            layers = new Vector.<LayerDefinition>;
            tilesets = new Vector.<Tileset>;
            objects = new ObjectFolder("Objects");
        }

        public function getTileset(name:String):Tileset {
            return getTilesetByName(name);
        }

        public function getTilesetNumFromName(name:String):int {
            for (var i:int = 0; i < tilesets.length; i++) {
                if (tilesets[ i ].tilesetName == name) {
                    return i;
                }
            }
            return -1;
        }

        public function getObjectDefinitionByName(name:String):ObjectDefinition {
            return getObjectDefinitionByNameHelper(name, objects);
        }

        private function getObjectDefinitionByNameHelper(name:String, folder:ObjectFolder):ObjectDefinition {
            for (var i:int = 0; i < folder.length; i++) {
                if (folder.contents[ i ] is ObjectFolder) {
                    var obj:ObjectDefinition = getObjectDefinitionByNameHelper(name, folder.contents[ i ]);
                    if (obj) {
                        return obj;
                    }
                }
                else if (folder.contents[ i ].name == name) {
                    return folder.contents[ i ];
                }
            }
            return null;
        }

        public function get minTilesWidth():int {
            return minWidth / tileWidth;
        }

        public function get minTilesHeight():int {
            return minHeight / tileHeight;
        }

        public function get maxTilesWidth():int {
            return maxWidth / tileWidth;
        }

        public function get maxTilesHeight():int {
            return maxHeight / tileHeight;
        }

        public function get defaultTilesWidth():int {
            return defaultWidth / tileWidth;
        }

        public function get defaultTilesHeight():int {
            return defaultHeight / tileHeight;
        }

    }

}