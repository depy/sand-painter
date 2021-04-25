import hxd.Pixels;
import hxd.PixelFormat;
import h2d.Tile;
import h2d.Bitmap;

class Main extends hxd.App {
    var pixelSize = 5;
    var xSize = 128;
    var ySize = 128;
    var fc: Int = 0;
    var tsum: Float = 0;
    var tile: Tile;
    var pixels: Pixels;
    var data: Pixels;
    var white = 0xFFFFFFFF;

    function updatePixels() 
    {
        for (y in 0...ySize)
        {
            for (x in 0...xSize)
            {
                // Pixel is not empty
                if (pixels.getPixel(x, y) != 0)
                {
                    // if last row (hit the bottom) then stay
                    // else if can fall directly down then fall
                    // else try sliding to the side
                    
                    if (y == ySize-1)
                        stay(x, y);
                    else if (pixels.getPixel(x, y+1) == 0)
                        fall(x, y);
                    else 
                        slide(x, y);
                }
            }
        }
    }

    function stay(x, y)
    {
        data.setPixel(x, y, white);
    }

    function fall(x, y) 
    {
        data.setPixel(x, y, 0);
        data.setPixel(x, y+1, white);
    }

    function conditionallyUpdate(predicate: Void->Bool, xTrue: Int, yTrue: Int, xFalse: Int, yFalse: Int) {
        if(predicate())
            data.setPixel(xTrue, yTrue, white);
        else
            data.setPixel(xFalse, yFalse, white);
    }

    function slide(x, y)
    {
        // If both directions are possible, pick a random direction
        if (pixels.getPixel(x-1, y+1) == 0 && pixels.getPixel(x+1, y+1) == 0)
        {
            var xd = if (Math.random() > 0.5) -1 else 1;
            var cond = function() { return (x+xd) < 0 || (x+xd) > xSize-1; };
            conditionallyUpdate(cond, x, y, x+xd, y+1);
        }
        // If only sliding left is possible
        else if (pixels.getPixel(x-1, y+1) == 0)
        {
            var cond = function() { return (x-1) < 0; };
            conditionallyUpdate(cond, x, y, x-1, y+1);
        }
        // If only sliding right is possible
        else if (pixels.getPixel(x+1, y+1) == 0)
        {
            var cond = function() { return (x+1) > xSize-1; };
            conditionallyUpdate(cond, x, y, x+1, y+1);
        }
        // If no movement is possible
        else stay(x, y);
    }

    function redraw(tile: Tile) {
        pixels = data.clone();
        data.clear(0);
        tile.getTexture().uploadPixels(pixels);
    }

    function onEvent(event : hxd.Event) {
        switch(event.kind) {
            case EKeyDown: null;
            case EKeyUp: null;
            case _: data.setPixel(Std.int(s2d.mouseX), Std.int(s2d.mouseY), white);
        }
    }

    override function init() {
        hxd.Window.getInstance().addEventTarget(onEvent);

        data = Pixels.alloc(xSize, ySize, PixelFormat.ARGB);
        pixels = data.clone();

        tile = Tile.fromPixels(pixels);
        var bitmap = new Bitmap(tile);
        s2d.addChild(bitmap);
        s2d.scale(pixelSize);
    }

    override function update(dt : Float) {
        updatePixels();
        redraw(tile);
    }
    
    static function main() {
        new Main();
    }
}