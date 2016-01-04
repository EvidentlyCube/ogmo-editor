package editor.definitions {
    import editor.commons.SelectOption;
    import editor.commons.Value;

    public class ValueDefinition {

        public static const TYPE_BOOL:uint = 0;
        public static const TYPE_NUMBER:uint = 1;
        public static const TYPE_INT:uint = 2;
        public static const TYPE_STRING:uint = 3;
        public static const TYPE_TEXT:uint = 4;
        public static const TYPE_SELECT:uint = 5;
        public static const TYPE_RADIUS:uint = 6;
        public static const TYPE_ANGLE:uint = 7;
        private static const TYPE_MAP:Array = [ Boolean, Number, int, String, String, String, Number, Number];
        public var valueType:uint;
        public var name:String;
        public var prettyName:String;
        public var def:*;
        public var min:Number;
        public var max:Number;
        public var wraps:Boolean = false;
        public var maxLength:uint;
        public var selectOptions:Vector.<SelectOption>;

        public function ValueDefinition(name:String, prettyName:String, valueType:uint, def:*) {
            this.name = name;
            this.prettyName = prettyName;
            this.valueType = valueType;
            this.def = def;
        }

        public function getValue():Value {
            var v:Value = new Value(this, TYPE_MAP[ valueType ]);
            v.value = def;

            return v;
        }

        public function getOptionForValue(value:*):SelectOption {
            for each(var option:SelectOption in selectOptions) {
                if (option.value == value) {
                    return option;
                }
            }

            return null;
        }
    }

}