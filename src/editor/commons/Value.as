package editor.commons {
    import editor.definitions.ValueDefinition;

    public class Value {

        public var datatype:Class;
        public var definition:ValueDefinition;
        private var _callbacksOnChange:Array;

        private var _value:*;

        public function Value(definition:ValueDefinition, datatype:Class) {
            this.definition = definition;
            this.datatype = datatype;

            _callbacksOnChange = [];
        }

        public function get value():* {
            return (datatype)(_value);
        }

        public function set value(to:*):void {
            if (_value !== (datatype)(to)) {
                _value = (datatype)(to);

                for (var i:int = 0; i < _callbacksOnChange.length; i++) {
                    _callbacksOnChange[i](this);
                }
            }
        }

        public function watch(callback:Function):void {
            _callbacksOnChange.push(callback);
        }

        public function unwatch(callback:Function):void {
            _callbacksOnChange.splice(_callbacksOnChange.indexOf(callback), 1);

        }
    }

}