package editor.ui.elements
{
    import editor.layers.Layer;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class LayerButtonAlpha extends Sprite
    {
        [Embed(source='../../../../assets/transparent.png')]
        static private const ImgRenderOpaque:Class;
        [Embed(source='../../../../assets/transparentNot.png')]
        static private const ImgRenderTransparent:Class;

        public var layerNum:uint;
        private var image:Bitmap;

        public function LayerButtonAlpha(layerNum:uint)
        {
            this.layerNum = layerNum;

            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            addEventListener(MouseEvent.CLICK, onClick);
            addEventListener(Event.REMOVED_FROM_STAGE, destroy);
        }

        private function destroy(e:Event):void
        {
            removeEventListener(MouseEvent.CLICK, onClick);
            removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
        }

        private function onClick(e:MouseEvent):void
        {
            var layer:Layer = Ogmo.level.layersContainer.getChildAt(layerNum) as Layer;
            layer.renderTransparent = !layer.renderTransparent;
            setImage();

            Ogmo.level.resetLayersAlpha();
        }

        public function setImage():void
        {
            if (image){
                removeChild(image);
            }

            var layer:Layer = Ogmo.level.layersContainer.getChildAt(layerNum) as Layer;

            if (!layer.renderTransparent){
                addChild(image = new ImgRenderTransparent);
            } else {
                addChild(image = new ImgRenderOpaque);
            }
        }

    }

}