package editor.events 
{
    import editor.layers.Layer;

    public class LayerSelectEvent extends OgmoEvent
    {
        public var layer:Layer;

        public function LayerSelectEvent(layer:Layer)
        {
            super(OgmoEvent.SELECT_LAYER);
            this.layer = layer;
        }

    }

}