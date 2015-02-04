
package psg;

import luxe.Sprite;
import luxe.Component;
import luxe.Vector;
import luxe.Sprite;
import luxe.options.SpriteOptions;

import snow.utils.UInt8Array;

import phoenix.Texture;

class PixelSprite extends Component
{
  var _sprite:Sprite;

  public var data:Array<Int>;

  public var mask:Mask;

  public var isColored:Bool;
  public var edgeBrightness:Float;
  public var colorVariations:Float;
  public var brightnessNoise:Float;
  public var saturation:Float;

  public var width(get, null):Int;
  public var height(get, null):Int;

  @:isVar public var rendered(default, null):Bool = false;


  var pixelsInt:Array<Int>;
  var pixelsUInt8:UInt8Array;


  /**
  *   The Sprite class makes use of a Mask instance to generate a 2D sprite.
  *   {
  *       colored         : true,   // boolean
  *       edgeBrightness  : 0.3,    // value from 0 to 1
  *       colorVariations : 0.2,    // value from 0 to 1
  *       brightnessNoise : 0.3,    // value from 0 to 1
  *       saturation      : 0.5     // value from 0 to 1
  *   }
  *   @class PixelSprite
  *   @param {_options} 
  *   @constructor
  */
 
  override public function new( _options:PixelSpriteOptions ):Void
  {
    _options.name = 'psg';
    super(_options);

    mask = _options.mask; // cast(_options.mask, Mask);

      // Default values
    isColored       = (_options.isColored == null) ? false : _options.isColored;
    edgeBrightness  = (_options.edgeBrightness == null) ? 0.3 : _options.edgeBrightness;
    colorVariations = (_options.colorVariations == null) ? 0.2 : _options.colorVariations;
    brightnessNoise = (_options.brightnessNoise == null) ? 0.3 : _options.brightnessNoise;
    saturation      = (_options.saturation == null) ? 0.5 : _options.saturation;

    data = new Array<Int>();

    pixelsInt = new Array<Int>();
  }


  /**
   * The init method calls all functions required to generate the sprite.
   */
  override function onadded():Void
  {
    _sprite = cast entity;
    // _sprite.texture = new Texture(Luxe.resources, texture);

    initSprite();
    initData();

    applyMask();
    generateRandomSample();

    if (mask.mirrorX) {
      mirrorX();
    }

    if (mask.mirrorY) {
      mirrorY();
    }

    generateEdges();
  }


  function initSprite():Void
  {
    _sprite.size.x = Std.int( mask.width * (mask.mirrorX ? 2 : 1) );
    _sprite.size.y = Std.int( mask.height * (mask.mirrorY ? 2 : 1) );
  }
  
  /**
   * The getData method returns the sprite template data at location (x, y)
   * 
   *    -1 = Always border (black)
   *     0 = Empty
   *     1 = Randomly chosen Empty/Body
   *     2 = Randomly chosen Border/Body
   *     
   * @param  x X position of pixel
   * @param  y Y position of pixel
   * @return   Value of pixel at position
   */
  function getData(x, y):Int
  {
    return data[y * width + x];
  };

  /**
  *   The setData method sets the sprite template data at location (x, y)
  *
  *      -1 = Always border (black)
  *       0 = Empty
  *       1 = Randomly chosen Empty/Body
  *       2 = Randomly chosen Border/Body
  *
  *   @method setData
  *   @param {x}
  *   @param {y}
  *   @param {value}
  *   @returns {undefined}
  */
  function setData(x, y, value):Void
  {
    data[y * width + x] = value;
  };

  /**
  *   The initData method initializes the sprite data to completely solid.
  *
  *   @method initData
  *   @returns {undefined}
  */
  function initData():Void
  {
    var h:Int = height;
    var w:Int = width;
    var x:Int = 0;
    var y:Int = 0;

    for (y in 0...h)
    {
      for (x in 0...w)
      {
        setData(x, y, -1);
      }
    }
  };

  /**
  *   The mirrorX method mirrors the template data horizontally.
  *
  *   @method mirrorX
  *   @returns {undefined}
  */
  function mirrorX():Void
  {
    var h:Int = height;
    var w:Int = Math.floor(width/2);
    var x:Int = 0;
    var y:Int = 0;

    for (y in 0...h)
    {
      for (x in 0...w)
      {
        setData(width - x - 1, y, getData(x, y));
      }
    }
  };


  /**
  *   The mirrorY method mirrors the template data vertically.
  *
  *   @method 
  *   @returns {undefined}
  */
  function mirrorY():Void
  {
    var h:Int = Math.floor(height/2);
    var w:Int = width;
    var x:Int = 0;
    var y:Int = 0;

    for (y in 0...h)
    {
      for (x in 0...w)
      {
        setData(x, height - y - 1, getData(x, y));
      }
    }
  };


  /**
  *   The applyMask method copies the mask data into the template data array at
  *   location (0, 0).
  *
  *   (note: the mask may be smaller than the template data array)
  *
  *   @method applyMask
  *   @returns {undefined}
  */
  function applyMask():Void
  {
    var h:Int = mask.height;
    var w:Int = mask.width;
    var x:Int = 0;
    var y:Int = 0;

    for (y in 0...h)
    {
      for (x in 0...w)
      {
        setData(x, y, mask.data[y * w + x]);
      }
    }
  };



  /**
  *   Apply a random sample to the sprite template.
  *
  *   If the template contains a 1 (internal body part) at location (x, y), then
  *   there is a 50% chance it will be turned empty. If there is a 2, then there
  *   is a 50% chance it will be turned into a body or border.
  *
  *   (feel free to play with this logic for interesting results)
  *
  *   @method generateRandomSample
  *   @returns {undefined}
  */
  function generateRandomSample():Void
  {
    var h:Int = height;
    var w:Int = width;
    var x:Int = 0;
    var y:Int = 0;
    var val:Int = 0;

    for (y in 0...h)
    {
      for (x in 0...w)
      {
        val = getData(x, y);

        if (val == 1)
        {
          val = val * Math.round( Math.random() );
        }
        else if (val == 2)
        {
          if (Math.random() > 0.5)
          {
            val = 1;
          }
          else
          {
            val = -1;
          }
        } 

        setData(x, y, val);
      }
    }
  };


  /**
  *   This method applies edges to any template location that is positive in
  *   value and is surrounded by empty (0) pixels.
  *
  *   @method generateEdges
  *   @returns {undefined}
  */
  function generateEdges():Void
  {
    var h:Int = height;
    var w:Int = width;
    var x:Int = 0;
    var y:Int = 0;

    for (y in 0...h)
    {
      for (x in 0...w)
      {
        if (getData(x, y) > 0)
        {
          if (y - 1 >= 0 && getData(x, y-1) == 0)
          {
            setData(x, y-1, -1);
          }
          if (y + 1 < height && getData(x, y+1) == 0)
          {
            setData(x, y+1, -1);
          }
          if (x - 1 >= 0 && getData(x-1, y) == 0)
          {
            setData(x-1, y, -1);
          }
          if (x + 1 < width && getData(x+1, y) == 0)
          {
            setData(x+1, y, -1);
          }
        }
      }
    }
  };

  /**
  *   This method renders out the template data to a HTML canvas to finally
  *   create the sprite.
  *
  *   (note: only template locations with the values of -1 (border) are rendered)
  *
  *   @method renderPixelData
  *   @returns {undefined}
  */
  function renderPixelData():Void
  {
    // Prepare all the variables first
    var isVerticalGradient:Bool = Math.random() > 0.5;
    var saturation:Float        = Math.max( Math.min( Math.random() * saturation, 1 ), 0);
    var hue:Float               = Math.random();

    var u:Int = 0;
    var v:Int = 0;
    var ulen:Int = 0;
    var vlen:Int = 0;

    var isNewColor:Float = 0;

    var val:Int = 0;
    var index:Int = 0;

    var color:Color = new Color(0,0,0);

    var brightness:Float = 0;

    // Target XY of BitmapData pixels
    var x:Int = 0;
    var y:Int = 0;


    if (isVerticalGradient)
    {
      ulen = height;
      vlen = width;
    }
    else
    {
      ulen = width;
      vlen = height;
    }

    // _sprite.texture.lock();

    for (u in 0...ulen)
    {
      // Create a non-uniform random number between 0 and 1 (lower numbers more likely)
      isNewColor = Math.abs(((Math.random() * 2 - 1) 
                           + (Math.random() * 2 - 1) 
                           + (Math.random() * 2 - 1)) / 3);

      // Only change the color sometimes (values above 0.8 are less likely than others)
      if (isNewColor > (1 - colorVariations))
      {
        hue = Math.random();
      }

      for (v in 0...vlen)
      {
        if (isVerticalGradient)
        {
          val   = getData(v, u);
          index = (u * vlen + v) * 4;
          x     = v;
          y     = u;
        }
        else
        {
          val   = getData(u, v);
          index = (v * ulen + u) * 4;
          x     = u;
          y     = v;
        }

        color.setRGB(1,1,1);

        if (val != 0)
        {
          if (isColored)
          {
            // Fade brightness away towards the edges
            brightness = Math.sin((u / ulen) * Math.PI) * (1 - brightnessNoise) 
                                   + Math.random() * brightnessNoise;

            // Get the RGB color value
            color.setHSL( hue, saturation, brightness );

            // If this is an edge, then darken the pixel
            if (val == -1)
            {
              color.r *= edgeBrightness;
              color.g *= edgeBrightness;
              color.b *= edgeBrightness;
            }

          }
          else
          {
            // Not colored, simply output black
            if (val == -1)
            {
              color.r = 0;
              color.g = 0;
              color.b = 0;
            }
          }
        }

        // _sprite.texture.set_pixel( new Vector(x, y) , color );
        pixelsInt.push(color.getARGB());
      }
    }

    // _sprite.texture.unlock();
    pixelsUInt8 = new UInt8Array(data.length);
    pixelsUInt8.set(pixelsInt);

    trace('pixelsInt' + pixelsInt);
    trace('pixelsUInt8' + pixelsUInt8);

    trace(' ## Texture.load_from_pixels(${name+'.pixels'}, ${width}, ${height}, ...)');
    _sprite.texture = Texture.load_from_pixels(name+'.pixels', width, height, pixelsUInt8);

    rendered = true;
  };



  override function update(_)
  {
    if(_sprite.inited && !rendered)
    {
      renderPixelData();
    }
  }


  function get_width():Int{
    return Std.int(_sprite.size.x);
  }
  function get_height():Int{
    return Std.int(_sprite.size.y);
  }

  /**
  *   This method converts the template data to a string value for debugging
  *   purposes.
  *
  *   @method toString
  *   @returns {undefined}
  */
  public function toString():String
  {
    var h:Int = height;
    var w:Int = width;
    var x:Int = 0;
    var y:Int = 0;
    var output:String = "";

    for (y in 0...h)
    {
      for (x in 0...w)
      {
        var val = getData(x, y);
        output += (val >= 0) ? " " + val : "" + val;
      }
      output += "\n";
    }
    return output;
  };

}

typedef PixelSpriteOptions = {
  > SpriteOptions,

  var mask:psg.Mask;
  @:optional var isColored:Bool;
  @:optional var edgeBrightness:Float;
  @:optional var colorVariations:Float;
  @:optional var brightnessNoise:Float;
  @:optional var saturation:Float;
}
