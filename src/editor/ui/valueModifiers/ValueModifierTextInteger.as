package editor.ui.valueModifiers {
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    public class ValueModifierTextInteger extends ValueModifierText {
        private var min:int;
        private var max:int;
        private var wrap:Boolean;

        public function ValueModifierTextInteger(x:int, y:int, width:int, callback:Function = null, def:int = 0, min:int = int.MIN_VALUE, max:int = int.MAX_VALUE, wrap:Boolean = false) {
            super(x, y, width, callback, String(def), Math.max(String(min).length, String(max).length));

            this.min = min;
            this.max = max;
            this.wrap = wrap;

            if (min < 0) {
                _text.restrict = "0-9\\-";
            }
            else {
                _text.restrict = "0-9";
            }
        }

        override protected function onKeyDown(e:KeyboardEvent):void {
            if (_captureEnterKey && hasFocus && e.keyCode == 13)
            {
                stage.focus = null;
                doCallback();
            } else if (e.keyCode == Keyboard.DOWN){
                if (e.ctrlKey){
                    value = (int(_text.text) - 100).toString();
                } else if (e.shiftKey){
                    value = (int(_text.text) - 10).toString();
                } else {
                    value = (int(_text.text) - 1).toString();
                }
                doCallback();
                e.preventDefault();

            } else if (e.keyCode == Keyboard.UP){
                if (e.ctrlKey){
                    value = (int(_text.text) + 100).toString();
                } else if (e.shiftKey){
                    value = (int(_text.text) + 10).toString();
                } else {
                    value = (int(_text.text) + 1).toString();
                }
                doCallback();
                e.preventDefault();

            }
        }


        override protected function doCallback():void {
            var value:Number = Number(_text.text);
            if (wrap){
                var delta:Number = max - min;
                while (value < min){
                    value += delta;
                }
                while (value > max){
                    value -= delta;
                }

            } else {
                value = Math.min(max, Math.max(min, value));
            }

            if (isNaN(value)) {
                _text.text = defaultValue;
            } else {
                _text.text = value.toString();
            }

            super.doCallback();
        }
        override protected function isValidValue(value:String):Boolean {
            var numeric:Number = int(value);

            return !(isNaN(numeric) || numeric < min || numeric > max);
        }
    }
}