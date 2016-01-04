package editor.undo
{
    import editor.layers.tile.Tile;
    import editor.layers.tile.TileMap;
    import editor.layers.tile.Tileset;

    public class TileUndoState
    {
        private var removed:Vector.<Tile>;
        private var added:Vector.<Tile>;
        private var oldSet:Tileset;
        private var newSet:Tileset;

        public function TileUndoState()
        {
            removed = new Vector.<Tile>;
            added = new Vector.<Tile>;
        }

        public function pushAdded(tile:Tile):void
        {
            added.push(tile);
        }

        public function pushAddedVector(tiles:Vector.<Tile>):void
        {
            for (var i:int = 0; i < tiles.length; i++)
                added.push(tiles[i]);
        }

        public function pushRemoved(tile:Tile):void
        {
            removed.push(tile);
        }

        public function pushRemovedVector(tiles:Vector.<Tile>):void
        {
            for (var i:int = 0; i < tiles.length; i++)
                removed.push(tiles[i]);
        }

        public function setTilesetChange(oldSet:Tileset, newSet:Tileset):void
        {
            this.oldSet = oldSet;
            this.newSet = newSet;
        }

        public function undo(tilemap:TileMap):void
        {
            var t:Tile;
            for each (t in added){
                tilemap.removeTile(t);
            }
            for each (t in removed){
                tilemap.addTileQuick(t);
            }

            if (oldSet)
                tilemap.tileset = oldSet;
        }

        public function redo(tilemap:TileMap):void
        {
            var t:Tile;
            for each (t in removed)
                tilemap.removeTile(t);
            for each (t in added)
                tilemap.addTileQuick(t);

            if (newSet)
                tilemap.tileset = newSet;
        }

        /* Returns true if this undo state does not represent any meaningful changes (ie: if nothing happened) */
        public function get empty():Boolean
        {
            return (added.length == 0 && removed.length == 0 && oldSet == null);
        }
    }

}