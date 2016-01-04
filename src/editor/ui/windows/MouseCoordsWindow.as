package editor.ui.windows
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class MouseCoordsWindow extends Sprite
    {
        private const C_BG:uint        = 0xBB8888;
        private const C_BORDER:uint    = 0x000000;
        private const C_TEXT:uint    = 0xFFFFFF;
        private const WIDTH:int        = 220;
        private const HEIGHT:int    = 16;

        private var mX:int;
        private var mY:int;
        private var bg:Sprite;
        private var text:TextField;
        private var format:TextFormat;

        public function MouseCoordsWindow()
        {
            addEventListener( Event.ADDED_TO_STAGE, init );
        }

        private function init( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, init );

            addEventListener( Event.REMOVED_FROM_STAGE, destroy );
            stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
            stage.addEventListener( Event.RESIZE, onResize );

            visible = false;

            //Set position
            updatePosition();

            //Background
            bg = new Sprite;
            bg.graphics.beginFill( C_BG );
            bg.graphics.drawRect( 0, 0, WIDTH, HEIGHT );
            bg.graphics.endFill();

            //Border
            bg.graphics.lineStyle(1, C_BORDER);
            bg.graphics.drawRect( 0, 0, WIDTH, HEIGHT );
            bg.graphics.endFill();
            addChild( bg );

            //Init text
            text = new TextField;
            text.selectable     = false;
            text.textColor         = C_TEXT;
            text.width            = WIDTH;
            text.height            = HEIGHT;
            text.x                 = 4;
            text.y                = -1;

            addChild( text );
        }

        private function destroy( e:Event ):void
        {
            removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
            stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
            stage.removeEventListener( Event.RESIZE, onResize );
        }

        private function updatePosition():void
        {
            x = 0;//((stage.stageWidth - Ogmo.STAGE_DEFAULT_WIDTH) / 2) + Ogmo.STAGE_DEFAULT_WIDTH - WIDTH;
            y = stage.stageHeight - HEIGHT;//((stage.stageHeight - Ogmo.STAGE_DEFAULT_HEIGHT) / 2) + Ogmo.STAGE_DEFAULT_HEIGHT - HEIGHT;
        }

        private function updateText():void
        {
            var textContent:String = "(" + mX + ":" + mY + ")";
            
            if (Ogmo.project.sizeInTiles == true){
                var tileX:int = (mX / Ogmo.project.tileWidth) | 0;
                var tileY:int = (mY / Ogmo.project.tileHeight) | 0;
                
                textContent += " / (" + tileX + ":" + tileY + ")";
            }

            text.width = 999;
            text.text = textContent;
            text.x = (WIDTH - text.textWidth) / 2;
        }

        private function onMouseMove( e:MouseEvent ):void
        {
            var obj:Object     = e.target;
            var ax:Number     = e.localX;
            var ay:Number     = e.localY;

            while ( obj != stage && obj != Ogmo.level.layersContainer )
            {
                ax *= obj.scaleX;
                ay *= obj.scaleY;
                ax += obj.x;
                ay += obj.y;
                obj = obj.parent;
            }

            if (obj == stage)
                visible = false;
            else
            {
                visible = true;
                mX = Ogmo.level.selectedLayer.convertX( ax );
                mY = Ogmo.level.selectedLayer.convertY( ay );
                updateText();
            }
        }

        private function onResize( e:Event ):void
        {
            updatePosition();
        }

    }

}