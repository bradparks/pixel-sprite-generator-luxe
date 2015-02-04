# WAIT

This is work in progress.
**DO NOT TRUST THIS README**

pixel-sprite-generator-luxe
======================

Haxe port of [Pixel Sprite Generator](https://github.com/zfedoran/pixel-sprite-generator) by [zfedoran](https://github.com/zfedoran). 

##Live Example

**HTML/JS** - [http://zielak.pl/pub/github/pixel-sprite-generator/](http://zielak.pl/pub/github/pixel-sprite-generator/)

<img src="https://raw.githubusercontent.com/Zielak/pixel-sprite-generator/master/doc/screenshot.png">

##Installation

###Using Haxelib

```
haxelib install pixel-sprite-generator
```

##Algorithm

The sprites are generated by using a two dimensional mask. The values in the mask are then randomized and mirrored. The resulting template is rendered to a canvas element.

<a href="http://web.archive.org/web/20080228054410/http://www.davebollinger.com/works/pixelspaceships/"><img src="https://github.com/zfedoran/pixel-sprite-generator/raw/master/doc/algorithm-1.png"></a>

The algorithm is explained in more detail on [Dave Bollinger's](http://web.archive.org/web/20080228054410/http://www.davebollinger.com/works/pixelspaceships/) website.

<a href="http://web.archive.org/web/20080228054410/http://www.davebollinger.com/works/pixelspaceships/"><img src="https://github.com/zfedoran/pixel-sprite-generator/raw/master/doc/algorithm-0.png"></a>
