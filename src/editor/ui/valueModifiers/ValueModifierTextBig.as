package editor.ui.valueModifiers {
    public class ValueModifierTextBig extends ValueModifierText {

        static private const HEIGHT:uint = 50;

        public function ValueModifierTextBig(x:int, y:int, width:int, callback:Function = null, defText:String = "", maxChars:int = -1) {
            super(x, y, width, callback, defText, maxChars);

            _text.height = HEIGHT;
            _text.wordWrap = true;
            _text.multiline = true;

            _captureEnterKey = false;
        }
    }

}