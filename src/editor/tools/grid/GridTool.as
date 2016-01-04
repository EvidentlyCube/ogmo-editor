package editor.tools.grid 
{
    import editor.layers.grid.GridLayer;
    import editor.layers.Layer;
    import editor.tools.Tool;


    public class GridTool extends Tool
    {
        protected var gridLayer:GridLayer;

        public function GridTool(layer:Layer)
        {
            super(layer);
            gridLayer = layer as GridLayer;
        }

    }

}