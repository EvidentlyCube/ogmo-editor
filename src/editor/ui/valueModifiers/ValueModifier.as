package editor.ui.valueModifiers
{
    import editor.commons.Value;
    import flash.display.Sprite;

    public class ValueModifier extends Sprite
    {
        private var _valueObject:Value;
        private var _callback:Function;

        public function ValueModifier(callback:Function) {
            _callback = callback;
        }

        public function set value( to:* ):void { }
        public function get value():* { }
        public function giveValue():void { }
        public function takeValue():void { }

        public function get valueObject():Value {
            return _valueObject;
        }

        public function set valueObject(value:Value):void {
            _valueObject = value;
        }

        protected function doCallback():void{
            if (_callback != null){
                if (_callback.length == 0){
                    _callback();
                } else {
                    _callback(this);
                }
            }
        }

        public function get callback():Function {
            return _callback;
        }

        public function set callback(value:Function):void {
            _callback = value;
        }
    }

}