package editor.tools.object
{
    import editor.layers.Layer;
    import editor.tools.*;
    import editor.layers.object.GameObject;
    import editor.layers.object.ObjectLayer;
    import editor.ui.elements.SelectedObjectOverlay;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class ToolObjectPaint extends ObjectTool
    {
        private var ghost:SelectedObjectOverlay;

        public function ToolObjectPaint( layer:Layer )
        {
            super( layer );
        }

        override protected function activate( e:Event ):void
        {
            super.activate(e);
            layer.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
            layer.addEventListener( MouseEvent.RIGHT_CLICK, onRightClick );
            layer.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
            layer.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
        }

        override protected function deactivate(e:Event):void
        {
            super.deactivate(e);
            layer.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
            layer.removeEventListener( MouseEvent.RIGHT_CLICK, onRightClick );
            layer.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
            layer.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
        }

        private function setGhost( ax:int, ay:int ):void
        {
            if (!ghost)
                addChild( ghost = new SelectedObjectOverlay( Ogmo.level.selectedObject ) );

            ghost.x = ax;
            ghost.y = ay;
        }

        private function killGhost():void
        {
            if (ghost)
            {
                removeChild( ghost );
                ghost = null;
            }
        }

        private function onMouseDown( e:MouseEvent ):void
        {
            objectLayer.deselectAll();
            if (Ogmo.level.selectedObject)
            {
                var p:Point = getMouseCoords( e );
                var ax:int = p.x;
                var ay:int = p.y;

                //Check that it's within bounds
                if (ax < 0 || ay < 0 || ax > Ogmo.level.levelWidth - (Ogmo.level.selectedObject.width - Ogmo.level.selectedObject.originX) || ay > Ogmo.level.levelHeight - (Ogmo.level.selectedObject.height - Ogmo.level.selectedObject.originY))
                    return;

                if (objectLayer.hasObjectOfTypeAt(Ogmo.level.selectedObject, ax, ay)){
                    objectLayer.selectObject(objectLayer.getObjectOfTypeAt(Ogmo.level.selectedObject, ax, ay));
                    return;
                }

                //Add the object
                var o:GameObject;

                o = objectLayer.addObject( Ogmo.level.selectedObject, ax, ay );
                objectLayer.selectObject( o );

                //Quick-resize?
                if (e.ctrlKey && (Ogmo.level.selectedObject.resizableX || Ogmo.level.selectedObject.resizableY))
                {
                    objectLayer.setTool(new ToolObjectTransform(objectLayer));
                    objectLayer.tool.startQuickMode();
                    objectLayer.quickTools.push( new QuickTool( ToolObjectPaint, QuickTool.MOUSE ) );
                    objectLayer.quickTools.push( new QuickTool( ToolObjectSelect, QuickTool.CTRL ) );
                }
                else
                {
                    //Quick-move
                    objectLayer.setTool(new ToolObjectSelect(objectLayer));
                    objectLayer.tool.startQuickMode();
                    objectLayer.quickTools.push( new QuickTool( ToolObjectPaint, QuickTool.MOUSE ) );
                }
            }
        }

        private function onRightClick( e:MouseEvent ):void
        {
            var p:Point = globalToLocal(new Point(e.stageX, e.stageY));
            objectLayer.removeObject( objectLayer.getFirstAtPoint( p.x, p.y ) );
        }

        private function onMouseMove( e:MouseEvent ):void
        {
            if (!Ogmo.level.selectedObject)
            {
                killGhost();
                return;
            }

            var p:Point = getMouseCoords( e );
            var ax:int = p.x - Ogmo.level.selectedObject.originX;
            var ay:int = p.y - Ogmo.level.selectedObject.originY;

            if (ax < 0 || ay < 0 || ax > Ogmo.level.levelWidth - Ogmo.level.selectedObject.width || ay > Ogmo.level.levelHeight - Ogmo.level.selectedObject.height)
                killGhost();
            else
                setGhost( ax, ay );
        }

        private function onMouseOut( e:MouseEvent ):void
        {
            killGhost();
        }

    }

}