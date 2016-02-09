package editor.ui.windows
{
    import editor.ui.*;
    import editor.layers.object.ObjectFolder;
    import editor.ui.elements.Label;
    import editor.ui.elements.ObjectLayerElementButton;

    import flash.events.Event;
    import flash.events.KeyboardEvent;

    public class ObjectPaletteWindow extends Window
    {
        public static var windowWidth:uint = 128;

        private var _buttons:Vector.<ObjectLayerElementButton>;
        private var _label:Label;

        public function ObjectPaletteWindow(y:int)
        {
            super(windowWidth + 4, 100, "Objects");
            this.y = y;
            this.y = 20 + Window.BAR_HEIGHT;

            _label = new Label("", 66, bodyHeight - 14, "Center", "Center");
            ui.addChild(_label);

            _buttons = new Vector.<ObjectLayerElementButton>();
            addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
        }

        private function init(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            addEventListener(Event.REMOVED_FROM_STAGE, destroy);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        private function destroy(e:Event):void
        {
            removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        private function onKeyDown(e:KeyboardEvent):void
        {
            if (Ogmo.missKeys || !Ogmo.windows.windowObjectPalette.active || e.ctrlKey)
                return;

            switch (e.keyCode)
            {
                //LEFT / A
                case (65):
                case (37):
                    moveButtonSelection( -1, 0 );
                    break;
                //UP / W
                case (87):
                case (38):
                    moveButtonSelection( 0, -1 );
                    break;
                //RIGHT / D
                case (68):
                case (39):
                    moveButtonSelection( 1, 0 );
                    break;
                //DOWN / S
                case (83):
                case (40):
                    moveButtonSelection( 0, 1 );
                    break;
            }
        }

        public function moveButtonSelection(dx:int, dy:int):void {
            dx = sign(dx);
            dy = sign(dy);
            var button:ObjectLayerElementButton;
            var current:ObjectLayerElementButton;
            var closest:ObjectLayerElementButton;
            var closestDistance:Number = Number.MAX_VALUE;

            for each (button in _buttons) {
                if (button.selected){
                    current = button;
                    break;
                }
            }

            if (!current){
                current = _buttons[0];
                current.select();
                return;
            }

            for each (button in _buttons) {
                if (button === current){
                    continue;
                }
                if (sign(button.x - current.x) === dx && sign(button.y - current.y) === dy && dist(current, button) < closestDistance){
                    closest = button;
                    closestDistance = dist(current, button);
                }
            }

            if (closest){
                closest.select();
            }
        }

        public function setFolder(to:ObjectFolder):void
        {
            _buttons.length = 0;
            var button:ObjectLayerElementButton;
            var j:int = 0;
            var perRow:int = Math.floor( windowWidth / ObjectLayerElementButton.gridSize );

            //Empty the window
            while (ui.numChildren > 0)
                ui.removeChildAt( 0 );
            addChild(_label);

            //Set the title
            title = to.name;

            //Add the back button if necessary
            if (to != Ogmo.project.objects)
            {
                j = 1;
                button = new ObjectLayerElementButton( ObjectLayerElementButton.BACK, to.parent );
                button.x = 2;
                button.y = 2;
                ui.addChild( button );
                _buttons.push(button);
            }

            //Add all the buttons
            for ( var i:int = 0; i < to.length; i++ )
            {
                if (to.contents[ i ] is ObjectFolder)
                    button = new ObjectLayerElementButton( ObjectLayerElementButton.FOLDER, to.contents[ i ] );
                else
                    button = new ObjectLayerElementButton( ObjectLayerElementButton.OBJECT, to.contents[ i ] );

                button.x = 2 + (j % perRow) * ObjectLayerElementButton.gridSize;
                button.y = 2 + Math.floor( j / perRow ) * ObjectLayerElementButton.gridSize;
                ui.addChild( button );
                _buttons.push(button);
                j++;
            }

            //Adjust the height
            bodyHeight = 24 + (Math.floor( (j - 1) / perRow ) + 1) * ObjectLayerElementButton.gridSize;

            //Move the label
            _label.y = bodyHeight - 14;
        }

        public function set mouseText(to:String):void
        {
            _label.text = to;
        }

        private function sign(x:Number):int {
            if (x > 0){
                return 1;
            } else if (x < 0){
                return -1;
            } else {
                return 0;
            }
        }

        private function dist(b1:*, b2:*):Number {
            return (b1.x - b2.x) * (b1.x - b2.x) + (b1.y - b2.y) * (b1.y - b2.y);
        }
    }

}