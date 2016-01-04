package editor.layers.tile
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.system.System;

    public class TileMap extends Sprite
    {
        private var _bitmap:Bitmap;
        private var _tilemapWidth:uint;
        private var _tilemapHeight:uint;
        private var _tilemapTileWidth:uint;
        private var _tilemapTileHeight:uint;
        private var _tiles:Vector.<Vector.<Tile>>;
        private var _tileset:Tileset;
        private var _tilesCount:int = 0;
        
        public function TileMap(width:uint, height:uint, tileset:Tileset)
        {
            _tilemapWidth     = width;
            _tilemapHeight     = height;
            
            _tileset    = tileset;

            _tilemapTileWidth = Math.ceil(_tilemapWidth / _tileset.tileWidth);
            _tilemapTileHeight = Math.ceil(_tilemapHeight / _tileset.tileHeight);
            
            _bitmap = new Bitmap(new BitmapData(width, height));
            _bitmap.bitmapData.fillRect(new Rectangle(0, 0, width, height), 0x00000000);
            addChild(_bitmap);

            clear();
        }

        /* ============================ UTILITIES ============================ */

        //Deletes all tiles
        public function clear():void
        {
            clearTiles();
            
            _bitmap.bitmapData.fillRect(new Rectangle(0, 0, _tilemapWidth, _tilemapHeight), 0x00FFFFFF);

            System.gc();
        }
        
        private function clearTiles():void{
            _tiles = new Vector.<Vector.<Tile>>(_tilemapTileWidth, true);
            for (var i:int = 0; i < _tilemapTileWidth; i++){
                _tiles[i] = new Vector.<Tile>(_tilemapTileHeight, true);
            }
        }

        //Resizes the tilemap, removing all out-of-bounds tiles
        public function resize(width:uint, height:uint):void{
            var oldTileWidth:int = _tilemapTileWidth;
            var oldTileHeight:int = _tilemapTileHeight;
            
            var bd:BitmapData = new BitmapData(width, height);
            bd.fillRect(new Rectangle(0, 0, width, height), 0x00FFFFFF);
            bd.copyPixels(_bitmap.bitmapData, new Rectangle(0, 0, Math.min(_tilemapWidth, width), Math.min(_tilemapHeight, height)), new Point);
            _bitmap.bitmapData = bd;

            _tilemapWidth     = width;
            _tilemapHeight     = height;
            
            _tilemapTileWidth = Math.ceil(_tilemapWidth / _tileset.tileWidth);
            _tilemapTileHeight = Math.ceil(_tilemapHeight / _tileset.tileHeight);

            var oldTilemap:Vector.<Vector.<Tile>> = _tiles;
            
            clearTiles();
            
            _tilesCount = 0;
            
            var right :int = Math.min(_tilemapTileWidth, oldTileWidth);
            var bottom:int = Math.min(_tilemapTileHeight, oldTileHeight);
            
            for (var i:int = 0; i < right; i++){
                for (var j:int = 0; j < bottom; j++){
                    _tiles[i][j] = oldTilemap[i][j];
                    _tilesCount++;
                }
            }
        }

        public function moveEverything(x:int, y:int):void{
            var oldTilemap:Vector.<Vector.<Tile>> = _tiles;
            var oldTileX:int;
            var oldTileY:int;
            var tile:Tile;

            clear();

            for (var i:int = 0; i < _tilemapTileWidth; i++){
                for (var j:int = 0; j < _tilemapTileHeight; j++){
                    oldTileX = (i + _tilemapTileWidth - x) % _tilemapTileWidth;
                    oldTileY = (j + _tilemapTileHeight - y) % _tilemapTileHeight;

                    tile = oldTilemap[oldTileX][oldTileY];

                    if (tile){
                        addTile(new Tile(tile.tileset, new Point(tile.tileRect.x, tile.tileRect.y), i * _tileset.tileWidth, j * _tileset.tileHeight));
                    }
                }
            }
        }

        /* ============================ ADDING ============================ */

        //Add a tile to the map
        public function addTile(tile:Tile):Tile
        {
            //Remove those that are colliding with it
            removeCollidingWithTile(tile);

            var tileX:uint = tile.x / _tileset.tileWidth;
            var tileY:uint = tile.y / _tileset.tileHeight;

            if (tileX >= _tilemapTileWidth || tileY >= _tilemapTileHeight){
                return null;
            }

            //Add it to the vector
            _tiles[tileX][tileY] = tile;
            
            _tilesCount++;
            
            //Add it to the bitmap
            Ogmo.point.x = tile.x;
            Ogmo.point.y = tile.y;
            Ogmo.rect.x = tile.tileRect.x;
            Ogmo.rect.y = tile.tileRect.y;
            Ogmo.rect.width = _tileset.tileWidth;
            Ogmo.rect.height = _tileset.tileHeight;
            _bitmap.bitmapData.copyPixels(_tileset.bitmapData, Ogmo.rect, Ogmo.point);

            return tile;
        }

        /* Just adds a tile without checking for collisions or setting its position. Used in undo/redo. */
        public function addTileQuick(tile:Tile):void{
            _tiles[tile.x / _tileset.tileWidth][tile.y / _tileset.tileHeight] = tile;

            _tilesCount++;
            
            Ogmo.point.x = tile.x;
            Ogmo.point.y = tile.y;
            Ogmo.rect.x = tile.tileRect.x;
            Ogmo.rect.y = tile.tileRect.y;
            Ogmo.rect.width = _tileset.tileWidth;
            Ogmo.rect.height = _tileset.tileHeight;
            _bitmap.bitmapData.copyPixels(_tileset.bitmapData, Ogmo.rect, Ogmo.point);
        }

        /* ============================ REMOVING ============================ */

        /* Remove a single tile from the tilemap */
        public function removeTile(tile:Tile):void{
            if (!tile){
                return;
            }
            
            var tx:int = tile.x / _tileset.tileWidth;
            var ty:int = tile.y / _tileset.tileHeight;
            
            if (_tiles[tx][ty] !== tile){
                return;
            }
            
            //remove it from the vector
            _tiles[tx][ty] = null;

            _tilesCount--;
            
            //remove it from the bitmap
            Ogmo.rect.x = tile.x;
            Ogmo.rect.y = tile.y;
            Ogmo.rect.width = _tileset.tileWidth;
            Ogmo.rect.height = _tileset.tileHeight;
            _bitmap.bitmapData.fillRect(Ogmo.rect, 0x00000000);
        }

        /* Remove a vector of tiles from the tilemap */
        public function removeTiles(toRemove:Vector.<Tile>):void{
            for each(var tile:Tile in toRemove){
                removeTile(tile);
            }
        }

        //Remove all tiles colliding with the given tile
        public function removeCollidingWithTile(tile:Tile):void{
            if (!tile){
                return;
            }
            
            var left:int = tile.x / _tileset.tileWidth;
            var top:int = tile.y / _tileset.tileHeight;
            var right:int = left + Math.ceil(tile.tileset.tileWidth / _tileset.tileWidth);
            var bottom:int = top + Math.ceil(tile.tileset.tileHeight / _tileset.tileHeight);
            
            for (var i:int = left; i < right; i++){
                if (i >= _tilemapTileWidth){
                    break;
                }

                for (var j:int = top; j < bottom; j++){
                    if (j >= _tilemapTileHeight){
                        break;
                    }

                    removeTile(_tiles[i][j]);
                }
            }
        }

        /* ============================ GETS / SETS ============================ */

        //Switch the tileset of every tile
        public function set tileset(ts:Tileset):void{
            var v:Vector.<Tile> = new Vector.<Tile>;
            var t:Tile;

            for each (var column:Vector.<Tile> in _tiles){
                for each( t in column){
                    if (t)
                        v.push(t);
                }
            }

            clear();

            for each (t in v){
                addTile(t);
            }

            _tileset = ts;
        }

        //Get the current only tileset
        public function get tileset():Tileset
        {
            return _tileset;
        }

        //Returns whether the tilemap is empty or not
        public function get empty():Boolean
        {
            return _tilesCount === 0;
        }

        //Returns an XML representation of the tilemap
        public function getXML(layerXML:XML):void{
            for each (var column:Vector.<Tile> in _tiles){
                for each(var tile:Tile in column){
                    if (tile){
                        layerXML.appendChild(tile.getXML());
                    }
                }
            }
        }

        //Builds the tilemap from an XML representation
        public function setXML(to:XML):void{
            clear();

            var o:XML;
            var p:Point;
            if (_tileset){
                for each (o in to.tile){
                    p = new Point(o.@tx, o.@ty);
                    addTile(new Tile(_tileset, p, o.@x, o.@y));
                }
            }
        }

        /* Returns the tile which can be found at the given point (or null if none exists) */
        public function getTileAtPosition(x:int, y:int):Tile{
            x /= _tileset.tileWidth;
            y /= _tileset.tileHeight;
            
            if (x < 0 || y < 0 || x >= _tilemapTileWidth || y >= _tilemapTileHeight){
                return null;
            }
            
            return _tiles[x][y];
        }

        /* Returns a vector of all the tiles that collide with the given rectangle */
        public function getTilesAtRectangle(rect:Rectangle):Vector.<Tile>{
            var left:int = rect.x / _tileset.tileWidth;
            var top:int = rect.y / _tileset.tileHeight;
            var right:int = left + Math.ceil(rect.width / _tileset.tileWidth);
            var bottom:int = top + Math.ceil(rect.height / _tileset.tileHeight);
            
            var vector:Vector.<Tile> = new Vector.<Tile>();
            
            for (var i:int = left; i < right; i++){
                for (var j:int = top; j < bottom; j++){
                    if (_tiles[i][j]){
                        vector.push(_tiles[i][j]);
                    }
                }
            }
            
            return vector;
        }
        
        public function getTilesAsFill(x:int, y:int, gridSize:uint, points:Array):Vector.<Tile>{
            var vec:Vector.<Tile> = new Vector.<Tile>(_tilemapWidth * _tilemapHeight);
            var found:Vector.<Boolean> = new Vector.<Boolean>(_tilemapWidth * _tilemapHeight, true);
            
            var currentIndex:int = 0;
            
            var tx:int;
            var ty:int;
            
            var tile:Tile = getTileAtPosition(x, y);
            if (tile){
                tx = tile.tileRect.x;
                ty = tile.tileRect.y;
                vec[currentIndex++] = tile;
            } else {
                tx = -1;
                ty = -1;
            }
            
            found[x + y * _tilemapWidth] = true;
            points.push(new Point(x, y));
            
            var point:Point;
            var checkIndex:uint = 0;
            while(checkIndex < points.length){
                point = points[checkIndex++];
                
                checkAndAdd(point.x - gridSize, point.y);
                checkAndAdd(point.x + gridSize, point.y);
                checkAndAdd(point.x, point.y - gridSize);
                checkAndAdd(point.x, point.y + gridSize);
            }
            
            function checkAndAdd(x:int, y:int):void{
                if (x < 0 || y < 0 || x >= _tilemapWidth || y >= _tilemapHeight){
                    return;
                }
                
                if (found[x + y * _tilemapWidth]){
                    return;
                }
                
                tile = getTileAtPosition(x, y);
                if (tx == -1 && tile == null){
                    found[x + y * _tilemapWidth] = true;
                    points.push(new Point(x, y));
                    
                } else if (tile && tile.tileRect.x == tx && tile.tileRect.y == ty){
                    found[x + y * _tilemapWidth] = true;
                    points.push(new Point(x, y));
                    vec[currentIndex++] = tile;
                }
            }
            
            vec.length = Math.max(0, currentIndex);
            
            return vec;
        }

    }

}