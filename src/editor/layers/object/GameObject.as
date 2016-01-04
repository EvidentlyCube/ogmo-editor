package editor.layers.object {
    import editor.commons.Reader;
    import editor.commons.Value;
    import editor.definitions.*;
    import editor.ui.elements.SelectOutline;
    import editor.ui.windows.MouseCoordsWindow;
    import editor.utils.Utils;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class GameObject extends Sprite {
        private var _selected:Boolean;
        private var draw:Sprite;
        private var layer:ObjectLayer;
        private var holder:Sprite;
        private var bg:Sprite;
        public var selBox:SelectOutline;
        public var grabbed:Point;
        public var resizing:Boolean;
        public var radiusValue:Value;
        public var angleValue:Value;

        public var definition:ObjectDefinition;
        public var objWidth:int;
        public var objHeight:int;
        public var values:Vector.<Value>;
        public var nodes:Sprite;
        public var lines:Sprite;
        public var radiusGraphic:Sprite;
        public var radiusSpritePreview:Sprite;

        public function GameObject(layer:ObjectLayer, objDef:ObjectDefinition = null) {
            this.layer = layer;
            grabbed = null;
            _selected = false;

            //The colored background drawn behind selected objects
            bg = new Sprite;
            addChild(bg);

            //Holds the actual drawn object image, rotates
            holder = new Sprite;
            addChild(radiusGraphic = new Sprite);
            addChild(holder);

            //The actual drawn object image
            draw = new Sprite;
            holder.addChild(draw);

            //The colored hollow rectangle around each object
            selBox = new SelectOutline(8, 8, 1, SelectOutline.OBJECT_NOTSELECTED);
            addChild(selBox);

            addChild(nodes = new Sprite);
            addChild(lines = new Sprite);
            radiusGraphic.addChild(radiusSpritePreview = new Sprite);
            radiusSpritePreview.visible = false;

            if (objDef) {
                init(objDef);
            }
        }

        private function init(objDef:ObjectDefinition):void {
            definition = objDef;
            setSize(objDef.width, objDef.height);

            draw.x = -definition.originX;
            draw.y = -definition.originY;
            bg.x = -definition.originX;
            bg.y = -definition.originY;
            selBox.x = -definition.originX;
            selBox.y = -definition.originY;

            //Get values
            if (objDef.values) {
                values = new Vector.<Value>;
                for each (var vd:ValueDefinition in objDef.values) {
                    var value:Value = vd.getValue();
                    values.push(value);

                    if (vd.valueType === ValueDefinition.TYPE_RADIUS){
                        radiusValue = value;
                        radiusValue.watch(radiusOrAngleChanged);
                        refreshRadius();
                    }

                    if (vd.valueType === ValueDefinition.TYPE_ANGLE){
                        angleValue = value;
                        angleValue.watch(radiusOrAngleChanged);
                        refreshRadius();
                    }
                }
            }

            //Enforce object limits
            if (definition.limit > 0) {
                var amount:int = layer.getAmountType(definition.name);
                if (amount >= definition.limit) {
                    layer.removeType(definition.name, amount + 1 - definition.limit);
                }
            }
        }

        private function drawBG():void {
            bg.graphics.clear();
            bg.graphics.beginFill(0xFFFFFF, 0.3);
            bg.graphics.drawRect(0, 0, objWidth, objHeight);
            bg.graphics.endFill();
        }

        private function clearBG():void {
            bg.graphics.clear();
            bg.graphics.beginFill(0xFFFFFF, 0.1);
            bg.graphics.drawRect(0, 0, objWidth, objHeight);
            bg.graphics.endFill();
        }

        public function move(h:int, v:int):void {
            x = Math.max(0, Math.min(x + h, Ogmo.level.levelWidth - objWidth + definition.originX));
            y = Math.max(0, Math.min(y + v, Ogmo.level.levelHeight - objHeight + definition.originY));
        }

        public function setSize(width:int, height:int):void {
            width = Math.max(definition.width, width);
            width = Math.min(Ogmo.level.levelWidth - x, width);
            if (!definition.resizableX) {
                width = definition.width;
            }

            height = Math.max(definition.height, height);
            height = Math.min(Ogmo.level.levelHeight - y, height);
            if (!definition.resizableY) {
                height = definition.height;
            }

            objWidth = width;
            objHeight = height;

            drawSprite(draw);
            drawSprite(radiusSpritePreview);

            selBox.setSize(objWidth, objHeight);
            if (selected) {
                drawBG();
            } else {
                clearBG();
            }

            refreshNodes();
            refreshRadius();
        }

        private function drawSprite(sprite:Sprite):void {
            sprite.graphics.clear();
            sprite.graphics.beginBitmapFill(definition.bitmapData);
            if (definition.tile) {
                sprite.graphics.drawRect(0, 0, objWidth, objHeight);
            }
            else {
                sprite.graphics.drawRect(0, 0, definition.imgWidth, definition.imgHeight);
                sprite.scaleX = objWidth / definition.imgWidth;
                sprite.scaleY = objHeight / definition.imgHeight;
            }
            sprite.graphics.endFill();
        }

        public function setAngle(value:Number):void {
            if (definition.rotatable) {
                var go:Number = Math.round(value / definition.rotationPrecision) * definition.rotationPrecision;
                angle = go;
                angle = angle % 360;
            }
        }

        public function rotate(dir:int = 1):void {
            if (definition.rotatable) {
                angle = (angle + 360 + (definition.rotationPrecision * dir)) % 360;
            }
        }

        public function collidesWithPoint(x:int, y:int):Boolean {
            return (rect.contains(x, y));
        }

        public function collidesWithObject(other:GameObject):Boolean {
            return (rect.intersects(other.rect));
        }

        public function collidesWithRectangle(other:Rectangle):Boolean {
            return (rect.intersects(other));
        }

        /* ========================== NODES ========================== */

        public function addNode(node:Node):void {
            nodes.addChild(node);
            node.x -= x;
            node.y -= y;
            refreshLines();
        }

        public function removeNode(node:Node):void {
            nodes.removeChild(node);
            refreshLines();
        }

        public function removeAllNodes():void {
            while (nodes.numChildren > 0) {
                nodes.removeChildAt(0);
            }
            refreshLines();
        }

        public function removeFirstNode(times:uint = 1):void {
            for (var i:int = 0; i < times; i++) {
                nodes.removeChildAt(0);
            }
            refreshLines();
        }

        public function getAmountOfNodes():uint {
            return nodes.numChildren;
        }

        public function hasNodeAt(x:int, y:int):Boolean {
            for (var i:int = 0; i < nodes.numChildren; i++) {
                if (nodes.getChildAt(i).x == x - this.x && nodes.getChildAt(i).y == y - this.y) {
                    return true;
                }
            }
            return false;
        }

        public function removeNodeAt(x:int, y:int):void {
            for (var i:int = 0; i < nodes.numChildren; i++) {
                if (nodes.getChildAt(i).x == x - this.x && nodes.getChildAt(i).y == y - this.y) {
                    nodes.removeChildAt(i);
                    refreshLines();
                    return;
                }
            }
        }

        private function refreshNodes():void {
            for (var i:int = 0; i < nodes.numChildren; i++) {
                (nodes.getChildAt(i) as Node).updateImage();
            }
            refreshLines();
        }

        private function refreshLines():void {
            if (definition.nodesDefinition == null || definition.nodesDefinition.lineMode == NodesDefinition.NONE) {
                return;
            }

            lines.graphics.clear();

            var color:uint = definition.nodesDefinition.color;
            var n:Node;
            var i:int;

            lines.graphics.lineStyle(1, color);
            if (definition.nodesDefinition.lineMode == NodesDefinition.PATH || definition.nodesDefinition.lineMode == NodesDefinition.CIRCUIT) {
                lines.graphics.moveTo(0, 0);
                for (i = 0; i < nodes.numChildren; i++) {
                    n = nodes.getChildAt(i) as Node;
                    lines.graphics.lineTo(n.x, n.y);
                }

                if (nodes.numChildren > 0 && definition.nodesDefinition.lineMode == NodesDefinition.CIRCUIT) {
                    lines.graphics.lineTo(0, 0);
                }
            }
            else if (definition.nodesDefinition.lineMode == NodesDefinition.FAN) {
                for (i = 0; i < nodes.numChildren; i++) {
                    n = nodes.getChildAt(i) as Node;
                    lines.graphics.moveTo(0, 0);
                    lines.graphics.lineTo(n.x, n.y);
                }
            }
        }

        private function refreshRadius():void {
            radiusGraphic.graphics.clear();
            if (radiusValue){
                radiusGraphic.graphics.lineStyle(2, 0xFFFF00);
                radiusGraphic.graphics.drawCircle(objWidth / 2, objHeight / 2, radiusValue.value);

                if (angleValue){
                    holder.x = Math.cos(angleValue.value * Math.PI / 180) * radiusValue.value;
                    holder.y = Math.sin(angleValue.value * Math.PI / 180) * radiusValue.value;
                } else {
                    holder.x = radiusValue.value;
                }
            }

        }

        /* ========================== GETS/SETS ========================== */

        public function deepCopy():GameObject {
            var o:GameObject = new GameObject(layer, definition);
            o.x = x;
            o.y = y;

            o.setAngle(angle);
            o.setSize(objWidth, objHeight);

            var i:int;

            //Copy the values
            if (values) {
                for (i = 0; i < values.length; i++) {
                    o.values[i].value = values[i].value;
                }
            }

            //Copy the nodes
            for (i = 0; i < nodes.numChildren; i++) {
                o.addNode(new Node(o, nodes.getChildAt(i).x, nodes.getChildAt(i).y));
            }

            return o;
        }

        public function get angle():Number {
            return holder.rotation;
        }

        public function set angle(value:Number):void {
            holder.rotation = value;
        }

        public function set selected(value:Boolean):void {
            if (_selected === value){
                return;
            }
            
            _selected = value;
            if (value) {
                nodes.alpha = 1;
                lines.alpha = 1;
                selBox.setColor(SelectOutline.OBJECT_SELECTED);
                radiusGraphic.alpha  = 1;
                drawBG();
            }
            else {
                nodes.alpha = 0.4;
                lines.alpha = 0.4;
                selBox.setColor(SelectOutline.OBJECT_NOTSELECTED);
                radiusGraphic.alpha  = 0.25;
                clearBG();
                radiusSpritePreview.visible = false;
            }
        }

        public function get selected():Boolean {
            return _selected;
        }

        public function get xml():XML {
            var xml:XML = <object/>;

            //basics
            xml.setName(definition.name);
            xml.@x = x;
            xml.@y = y;

            //Size if resizable
            if (definition.resizableX) {
                xml.@width = objWidth;
            }
            if (definition.resizableY) {
                xml.@height = objHeight;
            }

            //Angle if rotatable
            if (definition.rotatable) {
                if (definition.exportRadians) {
                    xml.@angle = Utils.degToRad(angle);
                } else {
                    xml.@angle = angle;
                }
            }

            //values
            Reader.writeValues(xml, values);

            //nodes
            for (var i:int = 0; i < nodes.numChildren; i++) {
                var node:XML = (nodes.getChildAt(i) as Node).xml;
                xml.appendChild(node);
            }

            return xml;
        }

        public function set xml(value:XML):void {
            var o:ObjectDefinition = Ogmo.project.getObjectDefinitionByName(value.name().localName);
            if (o) {
                init(o);
            } else {
                throw new Error("Object not defined: \"" + value.name().localName + "\"");
            }

            x = (int)(value.@x);
            y = (int)(value.@y);

            //Set the size
            var w:int, h:int;
            if (definition.resizableX) {
                w = value.@width;
            } else {
                w = definition.width;
            }

            if (definition.resizableY) {
                h = value.@height;
            } else {
                h = definition.height;
            }

            setSize(w, h);

            //Angle if rotatable
            if (definition.rotatable) {
                if (definition.exportRadians) {
                    angle = Utils.radToDeg(Number(value.@angle));
                } else {
                    angle = Number(value.@angle);
                }
            }

            //set the values
            Reader.readValues(value, values);

            //create the nodes
            for each (var n:XML in value.node) {
                addNode(new Node(this, n.@x, n.@y));
            }
        }

        public function get rect():Rectangle {
            return new Rectangle(x - definition.originX, y - definition.originY, objWidth, objHeight);
        }

        private function radiusOrAngleChanged(value:Value):void {
            refreshRadius();
        }
    }
}