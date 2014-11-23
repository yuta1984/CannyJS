# Canny JS
A (client-side) JavaScript implementation of Canny Edge Detection based on HTML5 canvas API.

## Demo
Visit the [demo page](http://yuta1984.github.io/canny/examples/) to see it in action.

## Usage
Include `canny.min.js` in your html file:

```
	<script src="js/canny.min.js"></script>
```

`CannyJS.canny` method loads the image data from a given canvas, and returns the resulting image data as a `GrayImageData` object. To show the resulting image, just call its `drawOn(canvas)` method.

```javascript
// get target canvas element
mycanvas = document.getElementById("myCanvas");
// perform edge detection
imageData = CannyJS.canny(canvas);
// overwrites the original canvas 
image.drawOn(mycanvas);
```

## Options
You can give some optional parameters to `CannyJS.canny` method:

```javascript
	CannyJS.canny(canvas, [ht=100], [lt=50], [sigmma=1.4], [kernelSize=5])
```	

`ht` and `lt` represent high and low threshold values that will be used in hysteresis thresholding procedure. Both `sigmma` and `kernalSize` are parameters used in Gaussian blur process (note that `kernelSize` must be an odd number).

## Other APIs
You can also call methods that perform each step of Canny edge detection: gaussian blur, sobel filtering, non-maximum suppression and hysteresis thresholding. Since these methods all receive and return `GrayImageData` objects, you first need to build an instance and make it load image data:

```javascript
	var canvas = document.getElementById("myCanvas");
	// construct a new GrayImageData object
	var imageData = new GrayImageData(canvas.width, canvas.height)
	// load image data from canvas
	imageData.loadCanvas(canavs);
```

Available methods are as follows:

```javascript
	// apply Gaussian filter 
	CannyJS.gaussianBlur(imageData, [sigmma=1.4], [kernelSize=5])
	// apply sobel filter
	CannyJS.sobel(blur)
	// apply non-Maximum suppression
	CannyJS.nonMaximumSuppression(sobel)
	// apply hysteresis thresholding
	CannyJS.hysteresis(nms, [ht=100], [lt=50])
```

## Performance
From what I tested CannyJS takes 3-4 seconds to perform edge-detection on an image with size 600x400 (tested on Chrome 38 on MacBookAir). Because I wrote this library in CoffeeScript I have difficulties in optimizing the generated code for better performance. Any suggestion or fix will be appreciated (perhaps I better rewrite it in native JavaScript?).

## License
MIT License.
