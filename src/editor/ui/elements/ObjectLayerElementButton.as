package editor.ui.elements
{
    import editor.layers.object.ObjectFolder;
    import editor.layers.object.ObjectLayer;
    import editor.definitions.*;
    import editor.tools.object.*;

    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;

    public class ObjectLayerElementButton extends Sprite
    {
        static public const FOLDER:int     = 0;
        static public const BACK:int     = 1;
        static public const OBJECT:int    = 2;

        static public var gridSize:int = 24;
        static public const FOLDER_IMAGE_SIZE:uint = 8;

        public var type:int;
        public var object:Object;
        private var _selected:Boolean;
        private var bitmap:Bitmap;
        private var selBox:SelectOutline;

        public function ObjectLayerElementButton( type:int, object:Object )
        {
            this.type     = type;
            this.object    = object;
            _selected = false;

            selBox = new SelectOutline( gridSize, gridSize );
            selBox.visible = false;
            addChild( selBox );

            if (type == FOLDER)
            {
                var of:ObjectFolder = object as ObjectFolder;
                bitmap = new Ogmo.ImgFolder;
                if (of.loaded)
                    loadedFolder();
                else
                    of.loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadedFolder, false, 0, true );
            }
            else if (type == BACK)
            {
                bitmap = new Ogmo.ImgArrow;
                init();
            }
            else if (type == OBJECT)
            {
                var od:ObjectDefinition = object as ObjectDefinition;
                if (od.loaded)
                    loadedObject();
                else
                    od.loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadedObject, false, 0, true );
            }
        }

        private function loadedFolder( e:Event = null ):void
        {
            var of:ObjectFolder = object as ObjectFolder;

            if (of.bitmapData)
            {
                var matrix:Matrix = new Matrix;
                matrix.scale( FOLDER_IMAGE_SIZE / of.bitmapData.width, FOLDER_IMAGE_SIZE / of.bitmapData.height );
                matrix.translate( 4, 5 );
                bitmap.bitmapData.draw( of.bitmapData, matrix );
            }

            init();
        }

        private function loadedObject( e:Event = null ):void
        {
            var od:ObjectDefinition = object as ObjectDefinition;
            bitmap = new Bitmap( od.bitmapData );

            init();

            if (od == Ogmo.level.selectedObject)
                selected = true;
        }

        private function init():void
        {
            bitmap.scaleX = gridSize / bitmap.bitmapData.width;
            bitmap.scaleY = gridSize / bitmap.bitmapData.height;
            addChildAt( bitmap, 0 );

            addEventListener( Event.REMOVED_FROM_STAGE, destroy );
            addEventListener( MouseEvent.CLICK, onClick );
            addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
            addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
        }

        private function destroy( e:Event ):void
        {
            removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
            removeEventListener( MouseEvent.CLICK, onClick );
            removeEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
            removeEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
        }

        public function get selected():Boolean
        {
            return _selected;
        }

        public function set selected( to:Boolean ):void
        {
            _selected = to;
            if (selBox)
            {
                selBox.setColor(0xFF00FF00);
                selBox.visible = to;
            }
        }

        public function select():void {
            if (type == FOLDER || type == BACK)
                Ogmo.windows.setObjectFolder( object as ObjectFolder );
            else
            {
                Ogmo.level.selectedObject = object as ObjectDefinition;
                Ogmo.windows.resetObjectsSelected();
                (Ogmo.level.selectedLayer as ObjectLayer).setTool(new ToolObjectPaint(Ogmo.level.selectedLayer as ObjectLayer));
                selected = true;
            }
        }

        private function onClick( e:MouseEvent ):void
        {
            select();
        }

        private function onMouseOver( e:MouseEvent ):void
        {
            if (object is ObjectFolder)
                Ogmo.windows.windowObjectPalette.mouseText = (object as ObjectFolder).name;
            else if (object is ObjectDefinition)
                Ogmo.windows.windowObjectPalette.mouseText = (object as ObjectDefinition).name;

            if (!_selected)
            {
                selBox.setColor(0xFFFFFF00);
                selBox.visible = true;
            }
        }

        private function onMouseOut( e:MouseEvent ):void
        {
            Ogmo.windows.windowObjectPalette.mouseText = "";

            if (!_selected)
                selBox.visible = false;
        }

    }

}