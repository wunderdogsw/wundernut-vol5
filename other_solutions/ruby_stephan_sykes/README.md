# SECRET MESSAGE solution

## Stephen Sykes

This is a javascript solution that runs in your browser. It deliberately runs slowly so you can see the image as it is drawn from the original image.

[View the solution here.](http://sdsykes.github.io/secretnut/)

### Solution description

With the given start, turn and stop pixel colours for drawing, it is simply a matter of iterating through the pixels of the given image to find those pixels.

Once a start pixel is found, we can begin drawing in this position.

In my solution it is convenient to use tail recursion so that setTimeout can be effectively used to slow the drawing down. 
Both the scan, and drawing each part of the result proceed in this way.
Incidentally, this also means that the scanning and drawing proceed in parallel.

The important parts of the program are as follows:

    // Scan remaining column for useful pixels
    function col(imgd, x) {
      row(imgd, x, 0);
      if (++x < width) col(imgd, x);
    }
    
    // Scan remaining rows for useful pixels
    function row(imgd, x, y) {
      var index = y * width * 4 + x * 4;
      var pix = imgd.data;
      var rgb = pix[index] * 65536 + pix[index + 1] * 256 + pix[index + 2];
      if (rgb == upwards) draw(imgd, x, y, 0, -1);
      else if (rgb == leftwards) draw(imgd, x, y, -1, 0);
      else if (rgb != stopdraw && rgb != turnright && rgb != turnleft) setPixel(imgd, index, 0);
  
      if (++y < height) setTimeout(function() {row(imgd, x, y)}, 100);
    }
    
    // Draw from x, y in direction xinc, yinc
    function draw(imgd, x, y, xinc, yinc) {
      var index = y * width * 4 + x * 4;
      var pix = imgd.data;
      var rgb = pix[index] * 65536 + pix[index + 1] * 256 + pix[index + 2];
      setPixel(imgd, index, 0xff);

      if (rgb == stopdraw) return;
      if (rgb == turnright) {var tmp = yinc; yinc = xinc; xinc = -tmp;}
      if (rgb == turnleft) {var tmp = xinc; xinc = yinc; yinc = -tmp;}

      setTimeout(function() {draw(imgd, x + xinc, y + yinc, xinc, yinc)}, 100);
    }

### In ruby

You can see [a simple working version of the same algorithm in ruby here.](https://github.com/sdsykes/secretnut/blob/master/a.rb)

### Thanks

Thanks to Wunderdog for [posing another fun puzzle](http://wunder.dog/secret-message-1).
