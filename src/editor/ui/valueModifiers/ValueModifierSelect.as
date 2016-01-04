package editor.ui.valueModifiers {
    import editor.commons.SelectOption;
    import editor.commons.Value;
    import editor.ui.valueModifiers.ValueModifier;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    public class ValueModifierSelect extends ValueModifier {
        static private const HEIGHT:uint = 18;
        static private const C_TEXT:uint = 0x000000;
        static private const C_BG:uint = 0xFFFFFF;
        static private const C_TEXTH:uint = 0xFFFFFF;
        static private const C_BGH:uint = 0x448844;
        static private const C_TEXTS:uint = 0x000000;
        static private const C_BGS:uint = 0x33FF33;
        static private const ICON_WIDTH:int = HEIGHT;
        protected var text:TextField;
        private var options:Vector.<SelectOption>;
        private var focus:Boolean;
        private var button:Sprite;
        private var selectedOption:SelectOption;

        public function ValueModifierSelect(x:int, y:int, width:int, callback:Function, options:Vector.<SelectOption>) {
            super(callback);

            this.x = x;
            this.y = y;

            this.options = options;

            text = new TextField;
            text.background = true;
            text.backgroundColor = C_BG;
            text.textColor = C_TEXT;
            text.selectable = true;
            text.width = width - ICON_WIDTH;
            text.focusRect = 0xFFFF0000;
            addChild(text);

            button = new Sprite();
            button.graphics.beginFill(C_BG);
            button.graphics.drawRect(0, 0, ICON_WIDTH, HEIGHT);
            button.graphics.beginFill(C_BGH);
            button.graphics.moveTo(2, 2);
            button.graphics.lineTo(16, 9);
            button.graphics.lineTo(2, 16);
            button.graphics.endFill();
            addChild(button);

            button.x = width - ICON_WIDTH;
            button.buttonMode = true;

            text.height = HEIGHT;

            focus = false;
            addEventListener(Event.REMOVED_FROM_STAGE, destroy);
            addEventListener(MouseEvent.CLICK, onClick);
        }

        override public function giveValue():void {
            valueObject.value = selectedOption.value;
        }

        override public function takeValue():void {
            value = valueObject.value;
        }

        private function onClick(e:Event):void {
            var currentOptionIndex:int = options.indexOf(selectedOption);

            selectedOption = options[(currentOptionIndex + 1) % options.length];
            text.text = selectedOption.display;

            giveValue();
        }

        private function destroy(e:Event):void {
            removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
            removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        /* ================ VALUE STUFF ================ */

        private function onKeyDown(e:KeyboardEvent):void {
            //on ENTER press
            if (focus && e.keyCode == 13) {
                stage.focus = null;
                doCallback();
            }
        }

        override public function set valueObject(value:Value):void {
            super.valueObject = value;
            selectedOption = value.definition.getOptionForValue(value.value);
            text.text = selectedOption.display;
        }

        override public function get value():* {
            return selectedOption.value;
        }

        override public function set value(to:*):void {
            var selectOption:SelectOption = valueObject.definition.getOptionForValue(to);

            if (!selectOption) {
                selectOption = valueObject.definition.def;
            }

            selectedOption = selectOption;
            text.text = selectOption.display;
        }
    }
}