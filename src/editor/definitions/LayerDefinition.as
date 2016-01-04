package editor.definitions 
{
    import editor.layers.tile.Tileset;

    public class LayerDefinition
    {

        static public const TILES:uint         = 0;
        static public const GRID:uint        = 1;
        static public const OBJECTS:uint    = 2;

        public var type:uint;
        public var name:String;
        public var gridSize:uint;
        public var gridColor:uint;
        public var drawGridSize:uint;
        public var color:uint;
        public var bgColor:uint;
        public var exportAsObjects:Boolean;
        public var newLine:String;
        public var tileset:Tileset;

        public function LayerDefinition( type:uint, name:String, gridSize:uint, gridColor:uint, drawGridSize:uint )
        {
            this.type             = type;
            this.name            = name;
            this.gridSize        = gridSize;
            this.gridColor        = gridColor;
            this.drawGridSize    = drawGridSize;
        }

    }

}