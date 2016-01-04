package editor.ui.valueModifiers {
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;

    public class ValueModifierText extends ValueModifier {
        static private const HEIGHT:uint = 18;
        static private const C_TEXT:uint = 0x000000;
        static private const C_BG:uint = 0xFFFFFF;
        static private const C_TEXTH:uint = 0xFFFFFF;
        static private const C_BGH:uint = 0x448844;
        static private const C_TEXTS:uint = 0x000000;
        static private const C_BGS:uint = 0x33FF33;

        protected var _text:TextField;
        private var _hasFocus:Boolean;
        private var _defaultValue:String;

        protected var _captureEnterKey:Boolean = true;

        public function ValueModifierText(x:int, y:int, width:int, callback:Function = null, defText:String = "", maxChars:int = -1) {
            super(callback);

            this.x = x;
            this.y = y;

            _defaultValue = defText;

            _text = new TextField;
            _text.background = true;
            _text.backgroundColor = C_BG;
            _text.textColor = C_TEXT;
            _text.selectable = true;
            _text.type = TextFieldType.INPUT;
            _text.text = defText;
            _text.width = width;
            _text.focusRect = 0xFFFF0000;
            addChild(_text);

            if (maxChars > 0) {
                _text.maxChars = maxChars;
            }

            _text.height = HEIGHT;

            _hasFocus = false;
            addEventListener(Event.REMOVED_FROM_STAGE, destroy);
            _text.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
            _text.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
            _text.addEventListener(Event.CHANGE, onChanged);
            addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        private function destroy(e:Event):void {
            removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
            _text.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
            _text.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
            removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        protected function onKeyDown(e:KeyboardEvent):void {
            //on ENTER press
            if (_captureEnterKey && _hasFocus && e.keyCode == 13) {
                stage.focus = null;
                doCallback();
            }
        }

        private function onFocusIn(e:Event):void {
            _hasFocus = true;
            Ogmo.missKeys = true;
        }

        private function onFocusOut(e:Event):void {
            _hasFocus = false;
            Ogmo.missKeys = false;
            doCallback();
        }

        /* ================ VALUE STUFF ================ */

        override public function get value():* {
            return _text.text;
        }

        override public function set value(to:*):void {
            _text.text = to;
        }

        override public function giveValue():void {
            valueObject.value = _text.text;
        }

        override public function takeValue():void {
            _text.text = valueObject.value;
        }

        private function onChanged(event:Event):void {
            if (isValidValue(value)) {
                doCallback();
            }
        }


        public function get hasFocus():Boolean {
            return _hasFocus;
        }

        protected function isValidValue(value:String):Boolean {
            return true;
        }

        public function get defaultValue():String {
            return _defaultValue;
        }
    }
}