package editor.commons {
    import editor.definitions.*;
    import editor.ui.elements.Label;
    import editor.ui.valueModifiers.ValueModifier;
    import editor.ui.valueModifiers.ValueModifierCheckBox;
    import editor.ui.valueModifiers.ValueModifierSelect;
    import editor.ui.valueModifiers.ValueModifierText;
    import editor.ui.valueModifiers.ValueModifierTextBig;
    import editor.ui.valueModifiers.ValueModifierTextInteger;
    import editor.ui.valueModifiers.ValueModifierTextNumber;
    import editor.ui.windows.Window;

    public class Reader {

        /* =================== READING XML =================== */

        static public function readOptions(attr:*):Vector.<SelectOption> {
            var values:Vector.<SelectOption> = new Vector.<SelectOption>();

            for each(var option:XML in attr.option) {
                values.push(new SelectOption(option.@value.toString(), option.text()));
            }

            return values;
        }

        static public function readStringJson(attr:*, def:String = ""):String {
            return attr;
        }

        static public function readStringXml(attr:*, def:String = ""):String {
            if (attr.length() == 0) {
                return def;
            }
            else {
                return attr[0];
            }
        }

        static public function readIntXml(attr:*, def:int, error:String, min:int = int.MIN_VALUE, max:int = int.MAX_VALUE):int {
            if (attr.length() == 0) {
                return def;
            }
            else {
                var str:String = attr[0];
                var match:String = "";
                for (var i:int = 0; i < str.length; i++) {
                    match = match + "[0-9\-]";
                }
                if (!str.match(match)) {
                    throw new Error("Expected integer value for " + error + ", got \"" + attr[0] + "\".");
                }
                else {
                    var num:int = (int)(str);
                    if (num < min || num > max) {
                        if (min == int.MIN_VALUE) {
                            throw new Error("Expected integer smaller than or equal to " + max + " for " + error + ", got \"" + attr[0] + "\".");
                        }
                        else if (max == int.MAX_VALUE) {
                            throw new Error("Expected integer larger then or equal to " + min + " for " + error + ", got \"" + attr[0] + "\".");
                        }
                        else {
                            throw new Error("Expected integer value within ( " + min + ", " + max + " ) for " + error + ", got \"" + attr[0] + "\".");
                        }
                    }
                    return num;
                }
            }
        }

        static public function readIntJson(attr:*, def:int, error:String, min:int = int.MIN_VALUE, max:int = int.MAX_VALUE):int {
            var str:String = attr;
            var match:String = "";
            for (var i:int = 0; i < str.length; i++) {
                match = match + "[0-9\\-]";
            }
            if (!str.match(match)) {
                throw new Error("Expected integer value for " + error + ", got \"" + attr + "\".");
            }
            else {
                var num:int = (int)(str);
                if (num < min || num > max) {
                    if (min == int.MIN_VALUE) {
                        throw new Error("Expected integer smaller than or equal to " + max + " for " + error + ", got \"" + attr + "\".");
                    }
                    else if (max == int.MAX_VALUE) {
                        throw new Error("Expected integer larger then or equal to " + min + " for " + error + ", got \"" + attr + "\".");
                    }
                    else {
                        throw new Error("Expected integer value within ( " + min + ", " + max + " ) for " + error + ", got \"" + attr + "\".");
                    }
                }
                return num;
            }
        }

        static public function readNumberJson(attr:*, def:Number, error:String, min:Number = int.MIN_VALUE, max:Number = int.MAX_VALUE):Number {
            var str:String = attr;
            var match:String = "";
            for (var i:int = 0; i < str.length; i++) {
                match = match + "[0-9\\-\\.]";
            }
            if (!str.match(match)) {
                throw new Error("Expected number value for " + error + ", got \"" + attr + "\".");
            }
            else {
                var num:Number = (Number)(str);
                if (num < min || num > max) {
                    if (min == int.MIN_VALUE) {
                        throw new Error("Expected number smaller than or equal to " + max + " for " + error + ", got \"" + attr + "\".");
                    }
                    else if (max == int.MAX_VALUE) {
                        throw new Error("Expected number larger then or equal to " + min + " for " + error + ", got \"" + attr + "\".");
                    }
                    else {
                        throw new Error("Expected number value within ( " + min + ", " + max + " ) for " + error + ", got \"" + attr + "\".");
                    }
                }
                return num;
            }
        }
        static public function readNumberXml(attr:*, def:Number, error:String, min:Number = int.MIN_VALUE, max:Number = int.MAX_VALUE):Number {
            if (attr.length() == 0) {
                return def;
            }
            else {
                var str:String = attr[0];
                var match:String = "";
                for (var i:int = 0; i < str.length; i++) {
                    match = match + "[0-9\-\.]";
                }
                if (!str.match(match)) {
                    throw new Error("Expected number value for " + error + ", got \"" + attr[0] + "\".");
                }
                else {
                    var num:Number = (Number)(str);
                    if (num < min || num > max) {
                        if (min == int.MIN_VALUE) {
                            throw new Error("Expected number smaller than or equal to " + max + " for " + error + ", got \"" + attr[0] + "\".");
                        }
                        else if (max == int.MAX_VALUE) {
                            throw new Error("Expected number larger then or equal to " + min + " for " + error + ", got \"" + attr[0] + "\".");
                        }
                        else {
                            throw new Error("Expected number value within ( " + min + ", " + max + " ) for " + error + ", got \"" + attr[0] + "\".");
                        }
                    }
                    return num;
                }
            }
        }

        static public function readBooleanXml(attr:*, def:Boolean, error:String):Boolean {
            if (attr.length() == 0) {
                return def;
            }

            var value:String = String(attr[0]);
            value = value.toLocaleLowerCase();

            if (value == "true" || value == "1" || value == "t") {
                return true;
            }
            else if (value == "false" || value == "0" || value == "f") {
                return false;
            }
            else {
                throw new Error("Expected boolean value for " + error + ", got \"" + value + "\".");
            }
        }

        static public function readBooleanJson(attr:*, def:Boolean, error:String):Boolean {
            attr = attr is String ? attr.toLocaleLowerCase() : attr;

            if (attr == "true" || attr == "1" || attr == "t" || attr === true) {
                return true;
            }
            else if (attr == "false" || attr == "0" || attr == "f" || attr === false) {
                return false;
            }
            else {
                throw new Error("Expected boolean value for " + error + ", got \"" + attr + "\".");
            }
        }

        static public function readColor24(attr:*, def:uint, error:String):uint {
            if (attr.length() == 0) {
                return def;
            }
            else {
                var str:String = attr[0];
                if (str.length == 6) {
                    str = "0x" + str;
                }
                else if (str.length == 7 && str.charAt() == "#") {
                    str = "0x" + str.substr(1);
                }
                else if (str.length != 8) {
                    throw new Error("Expected hex color value of format \"RRGGBB\" for " + error + ", got \"" + attr[0] + "\".");
                }

                if (!str.match("0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]")) {
                    throw new Error("Expected hex color value of format \"RRGGBB\" for " + error + ", got \"" + attr[0] + "\".");
                }

                return (uint)(str);
            }
        }

        static public function readColor32(attr:*, def:uint, error:String):uint {
            if (attr.length() == 0) {
                return def;
            }
            else {
                var str:String = attr[0];
                if (str.length == 8) {
                    str = "0x" + str;
                }
                else if (str.length == 9 && str.charAt() == "#") {
                    str = "0x" + str.substr(1);
                }
                else if (str.length != 10) {
                    throw new Error("Expected hex color value of format \"AARRGGBB\" for " + error + ", got \"" + attr[0] + "\".");
                }

                if (!str.match("0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]")) {
                    throw new Error("Expected hex color value of format \"RRGGBB\" for " + error + ", got \"" + attr[0] + "\".");
                }

                return (uint)(str);
            }
        }

        static public function readForValueJson(attr:*, value:Value, error:String):void {
            var e:String = error + " -> " + value.definition.name;

            if (value.datatype == Boolean) {
                value.value = readBooleanJson(attr, value.definition.def, e);
            }
            else if (value.datatype == int) {
                value.value = readIntJson(attr, value.definition.def, e, value.definition.min, value.definition.max);
            }
            else if (value.datatype == Number) {
                value.value = readNumberJson(attr, value.definition.def, e, value.definition.min, value.definition.max);
            }
            else if (value.datatype == String) {
                value.value = readStringJson(attr, value.definition.def);
            }
        }

        static public function readForValueXml(attr:*, value:Value, error:String):void {
            var e:String = error + " -> " + attr.name().localName;

            if (value.datatype == Boolean) {
                value.value = readBooleanXml(attr, value.definition.def, e);
            }
            else if (value.datatype == int) {
                value.value = readIntXml(attr, value.definition.def, e, value.definition.min, value.definition.max);
            }
            else if (value.datatype == Number) {
                value.value = readNumberXml(attr, value.definition.def, e, value.definition.min, value.definition.max);
            }
            else if (value.datatype == String) {
                value.value = readStringXml(attr, value.definition.def);
            }
        }

        /* =================== WITH VALUES =================== */

        static public function writeValuesToXml(xml:XML, values:Vector.<Value>):void {
            for each (var v:Value in values) {
                xml["@" + v.definition.name] = v.value;
            }
        }
        static public function writeValuesToJson(values:Vector.<Value>):Object {
            var object:Object = {};
            for each (var v:Value in values) {
                object[v.definition.name] = v.value;
            }
            return object;
        }

        static public function readValuesJson(jsonArray:Object, values:Vector.<Value>):void {
            for (var valueName:String in jsonArray) {
                if (!jsonArray.hasOwnProperty(valueName)){
                    continue;
                }

                var v:Value = getValueByName(valueName, values);
                if (v) {
                    Reader.readForValueJson(jsonArray[valueName], v, "level");
                }
            }
        }

        static public function readValuesXml(xml:XML, values:Vector.<Value>):void {
            for each (var o:XML in xml.attributes()) {
                var nodeName:String = QName(o.name()).localName;

                var v:Value = getValueByName(nodeName, values);
                if (v) {
                    Reader.readForValueXml(o, v, "level");
                }
            }
        }

        static public function getValueByName(name:String, values:Vector.<Value>):Value {
            for each (var v:Value in values) {
                if (v.definition.name == name) {
                    return v;
                }
            }
            return null;
        }

        static public function addElementsForValues(window:Window, values:Vector.<Value>):void {
            var ay:int, value:Value, func:Function, vm:ValueModifier;

            ay = window.bodyHeight + 5;
            func = function (c:ValueModifier):void {
                c.giveValue();
            };

            for each (value in values) {

                switch (value.definition.valueType) {
                    case(ValueDefinition.TYPE_BOOL):
                        //Add a checkbox
                        vm = new ValueModifierCheckBox(window.bodyWidth - 13, ay + 4, value.definition.def, func);

                        window.ui.addChild(new Label(value.definition.prettyName + ":", 5, ay + 2, "Left", "Center"));
                        ay += 22;
                        break;
                    case(ValueDefinition.TYPE_INT):
                        //Add an int EnterText
                        vm = new ValueModifierTextInteger(window.bodyWidth - 55, ay - 4, 50, func, value.definition.def, value.definition.min, value.definition.max, value.definition.wraps);

                        window.ui.addChild(new Label(value.definition.prettyName + ":", 5, ay + 2, "Left", "Center"));
                        ay += 22;
                        break;
                    case(ValueDefinition.TYPE_NUMBER):
                        //Add a num EnterText
                        vm = new ValueModifierTextNumber(window.bodyWidth - 55, ay - 4, 50, func, value.definition.def, value.definition.min, value.definition.max, value.definition.wraps);

                        window.ui.addChild(new Label(value.definition.prettyName + ":", 5, ay + 2, "Left", "Center"));
                        ay += 22;
                        break;
                    case(ValueDefinition.TYPE_STRING):
                        //Add a string EnterText
                        vm = new ValueModifierText(window.bodyWidth - 90, ay - 4, 85, func, value.definition.def, value.definition.maxLength);

                        window.ui.addChild(new Label(value.definition.prettyName + ":", 5, ay + 2, "Left", "Center"));
                        ay += 22;
                        break;
                    case(ValueDefinition.TYPE_TEXT):
                        //Add a text EnterText
                        vm = new ValueModifierTextBig(5, ay + 14, window.bodyWidth - 10, func, value.definition.def, value.definition.maxLength);

                        window.ui.addChild(new Label(value.definition.prettyName + ":", 5, ay, "Left", "Center"));
                        ay += 70;
                        break;
                    case(ValueDefinition.TYPE_SELECT):
                        vm = new ValueModifierSelect(5, ay + 14, window.bodyWidth - 10, func, value.definition.selectOptions);

                        window.ui.addChild(new Label(value.definition.prettyName + ":", 5, ay, "Left", "Center"));
                        ay += 44;
                        break;
                    case(ValueDefinition.TYPE_RADIUS):
                        //Add a num EnterText
                        vm = new ValueModifierTextNumber(window.bodyWidth - 55, ay - 4, 50, func, value.definition.def, value.definition.min, value.definition.max, value.definition.wraps);

                        window.ui.addChild(new Label("Radius:", 5, ay + 2, "Left", "Center"));
                        ay += 22;
                        break;
                    case(ValueDefinition.TYPE_ANGLE):
                        //Add a num EnterText
                        vm = new ValueModifierTextNumber(window.bodyWidth - 55, ay - 4, 50, func, value.definition.def, value.definition.min, value.definition.max, value.definition.wraps);

                        window.ui.addChild(new Label("Angle:", 5, ay + 2, "Left", "Center"));
                        ay += 22;
                        break;
                }

                vm.valueObject = value;
                vm.value = value.value;
                window.ui.addChild(vm);

            }
            window.bodyHeight = ay;
        }

    }

}