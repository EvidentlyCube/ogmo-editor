package editor.ui.valueModifiers {
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    public class ValueModifierTextNumber extends ValueModifierText {
        private var min:int;
        private var max:int;
        private var wrap:Boolean;

        public function ValueModifierTextNumber(x:int, y:int, width:int, callback:Function = null, def:Number = 0, min:Number = int.MIN_VALUE, max:Number = int.MAX_VALUE, wrap:Boolean = false) {
            super(x, y, width, callback, String(def), -1);

            this.min = min;
            this.max = max;
            this.wrap = wrap;

            _text.restrict = "0-9.\\-";
        }


        override protected function onKeyDown(e:KeyboardEvent):void {
            if (_captureEnterKey && hasFocus && e.keyCode == 13)
            {
                stage.focus = null;
                doCallback();
            } else if (e.keyCode == Keyboard.DOWN){
                if (e.ctrlKey){
                    value = (Number(_text.text) - 100).toString();
                } else if (e.shiftKey){
                    value = (Number(_text.text) - 10).toString();
                } else {
                    value = (Number(_text.text) - 1).toString();
                }
                doCallback();
                e.preventDefault();

            } else if (e.keyCode == Keyboard.UP){
                if (e.ctrlKey){
                    value = (Number(_text.text) + 100).toString();
                } else if (e.shiftKey){
                    value = (Number(_text.text) + 10).toString();
                } else {
                    value = (Number(_text.text) + 1).toString();
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
                _text.text = Math.floor(value).toString();
            }

            super.doCallback();
        }

        override protected function isValidValue(value:String):Boolean {
            var numeric:Number = Number(value);

            return !(isNaN(numeric) || numeric < min || numeric > max);
        }
    }
}