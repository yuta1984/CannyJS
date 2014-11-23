###*
# Utility object
###
Util = {}

Util.generateMatrix = (w, h, initialValue) ->
  matrix=[]
  for x in [0..w-1]
    matrix[x] = []
    for y in [0..h-1]
      matrix[x][y] = initialValue
  matrix

###*
# Class that represents gray-scaled image data
###
class GrayImageData
  
  ###*
  # construct a new image data
  # @param {number} width of the image
  # @param {number} height of the image
  ###
  constructor: (width, height) ->
    @width = width
    @height = height
    @data = Util.generateMatrix(@width, @height, 0)
    @

  ###*
  # load image data from canvas and store it as a matrix of gray-scaled pixels
  # @param {object} canvas object
  ###
  loadCanvas: (canvas) ->
    ctx = canvas.getContext('2d')
    rawdata = ctx.getImageData(0, 0, canvas.width, canvas.height).data
    x = 0
    y = 0
    for d, i in rawdata by 4
      r = rawdata[i]
      g = rawdata[i+1]
      b = rawdata[i+2]
      @data[x][y] = Math.round(0.298*r + 0.586*g + 0.114*b)
      if x is @width-1
        x = 0
        y+= 1
      else
        x+=1
    @
  
  ###*
  # get the neighbor of a given point
  # @param {number} x corrdinate of the point
  # @param {number} y corrdinate of the point
  # @param {number} size of the neighbors
  # @return {array} matrix of the neighbor of the point
  ###
  getNeighbors: (x, y, size) ->
    neighbors = Util.generateMatrix(size, size, 0)
    for i in [0..size-1]
      neighbors[i] = []
      for j in [0..size-1]
        trnsX = x-(size-1)/2+i
        trnsY = y-(size-1)/2+j
        if @data[trnsX] and @data[trnsX][trnsY]
          neighbors[i][j] = @data[trnsX][trnsY]
        else
          neighbors[i][j] = 0
    neighbors
    
  ###*
  # iterate all the pixel in the image data
  # @param {number} size of the neighbors given to
  # @param {function} function that will applied to the pixel
  ###
  eachPixel: (neighborSize, func) ->
    for x in [0..@width-1]  
      for y in [0..@height-1]
        current = @data[x][y]
        neighbors = @getNeighbors(x, y, neighborSize)
        func(x, y, current, neighbors)
    # x = 0
    # while x < @width-1
    #   y = 0
    #   while y < @height-1
    #     current = @data[x][y]
    #     neighbors = @getNeighbors(x, y, neighborSize)
    #     func(x, y, current, neighbors)
    #     y++
    #   x++
    @

  ###*
  # return linear array of the image data
  # @return {array} array of the pixel color data
  ###
  toImageDataArray: ->
    ary = []
    for y in [0..@height-1]
      for x in [0..@width-1]
        ary.push @data[x][y] for i in [0..2]          
        ary.push 255
    ary

  ###*
  # return a deep copy of this object
  # @return {object} the copy of this object
  ###
  copy: ->
    copied = new GrayImageData(@width, @height)
    for x in [0..@width-1]
      for y in [0..@height-1]
        copied.data[x][y] = @data[x][y]
    copied.width = @width
    copied.height = @height
    copied

  ###*
  # draw the image on a given canvas
  # @param {object} target canvas object
  ###
  drawOn: (canvas) ->
    ctx = canvas.getContext('2d')
    imgData = ctx.createImageData(canvas.width, canvas.height)
    for color, i in @toImageDataArray()
      imgData.data[i] = color 
    ctx.putImageData(imgData, 0, 0)

  ###*
  # fill the image with given color
  # @param {number} color to fill
  ###
  fill: (color) ->
    for y in [0..@height-1]
      for x in [0..@width-1]
        @data[x][y] = color
        

###*
# object that holds methods for image processing 
###
CannyJS = {}

###*
# apply gaussian blur to the image data
# @param {object} GrayImageData object
# @param {number} [sigmma=1.4] value of sigmma of gauss function
# @param {number} [size=3] size of the kernel (must be an odd number)
# @return {object} GrayImageData object
###
CannyJS.gaussianBlur= (imgData, sigmma=1.4, size=3) ->
  kernel = CannyJS.generateKernel(sigmma, size)
  copy = imgData.copy()
  copy.fill 0
  imgData.eachPixel size, (x, y, current, neighbors) ->
    ## this for-loop is too slow
    # for i in [0..size-1]
    #   for j in [0..size-1]
    #     copy.data[x][y] += neighbors[i][j] * kernel[i][j]
    i = 0
    while i <= size-1
      j = 0
      while j <= size-1
        copy.data[x][y] += neighbors[i][j] * kernel[i][j]
        j++
      i++
  copy
  
###*
# generate kernel matrix
# @param {number} [sigmma] value of sigmma of gauss function
# @param {number} [size] size of the kernel (must be an odd number)
# @return {array} kernel matrix
###
CannyJS.generateKernel= (sigmma, size) ->
  s = sigmma
  e = 2.718
  kernel = Util.generateMatrix(size, size, 0)
  sum = 0
  for i in [0..size-1]
    x = -(size-1)/2 + i # calculate the local x coordinate of neighbor
    for j in [0..size-1]
      y = -(size-1)/2 + j # calculate the local y coordinate of neighbor
      gaussian = (1/(2*Math.PI*s*s)) * Math.pow(e, -(x*x+y*y)/(2*s*s))
      kernel[i][j] = gaussian
      sum += gaussian
  # normalization
  for i in [0..size-1]
    for j in [0..size-1]
      kernel[i][j] = (kernel[i][j]/sum).toFixed(3)
  console.log "kernel",kernel      
  kernel

###*
# appy sobel filter to image data
# @param {object} GrayImageData object
# @return {object} GrayImageData object
###
CannyJS.sobel= (imgData) ->
  yFiler = [
    [-1, 0, 1],
    [-2, 0, 2],
    [-1, 0, 1]
  ]
  xFiler = [
    [-1, -2, -1],
    [ 0,  0,  0],
    [1, 2, 1]
  ]
  copy = imgData.copy()
  copy.fill 0
  imgData.eachPixel 3, (x, y, current, neighbors) ->
    ghs=0
    gvs=0
    for i in [0..2]
      for j in [0..2]
        ghs += yFiler[i][j]*neighbors[i][j]
        gvs += xFiler[i][j]*neighbors[i][j]
    copy.data[x][y] = Math.sqrt(ghs*ghs+gvs*gvs)
  copy

###*
# appy non-maximum suppression to image data
# @param {object} GrayImageData object
# @return {object} GrayImageData object
###
CannyJS.nonMaximumSuppression = (imgData) ->
  copy = imgData.copy()
  copy.fill 0
  # discard non-local maximum
  imgData.eachPixel 3, (x, y, c, n) ->
    if n[1][1] > n[0][1] and n[1][1] > n[2][1]
      copy.data[x][y] = n[1][1]
    else
      copy.data[x][y] = 0
    if n[1][1] > n[0][2] and n[1][1] > n[2][0]
      copy.data[x][y] = n[1][1]
    else
      copy.data[x][y] = 0
    if n[1][1] > n[1][0] and n[1][1] > n[1][2]
      copy.data[x][y] = n[1][1]
    else
      copy.data[x][y] = 0
    if n[1][1] > n[0][0] and n[1][1] > n[2][2]
      copy.data[x][y] = n[1][1]
    else
      copy.data[x][y] = 0
  copy
    
      
###*
# appy hysteresis threshold to image data
# @param {object} GrayImageData object
# @param {number} [ht=150] value of high threshold
# @param {number} [lt=100] value of low threshold
# @return {object} GrayImageData object
###
CannyJS.hysteresis= (imgData, ht, lt) ->
  copy = imgData.copy()
  isStrong = (edge) -> edge > ht
  isCandidate = (edge) -> edge <= ht and edge >= lt
  isWeak = (edge) -> edge < lt
  # discard weak edges, pick up strong ones
  imgData.eachPixel 3, (x, y, current, neighbors) ->
    if isStrong(current)
      copy.data[x][y] = 255
    else if isWeak(current) or isCandidate(current)
      copy.data[x][y] = 0
  # traverse over candidate edges connected to strong ones      
  traverseEdge = (x, y) ->
    return if x is 0 or y is 0 or x is imgData.width-1 or y is imgData.height-1
    if isStrong(copy.data[x][y])
      neighbors = copy.getNeighbors(x, y, 3)
      for i in [0..2]
        for j in [0..2]
          if isCandidate(neighbors[i][j])
            copy.data[x-1+i][y-1+j] = 255
            traverseEdge(x-1+i,y-1+j)        
  copy.eachPixel 3, (x, y) -> traverseEdge(x, y)    
  # discard others
  copy.eachPixel 1, (x, y, current) ->
    copy.data[x][y] = 0 unless isStrong(current)      
  copy

###*
# appy canny edge detection algorithm to canvas
# @param {object} canvas object
# @param {number} [ht=100] value of high threshold
# @param {number} [lt=50] value of low threshold
# @param {number} [sigmma=1.4] value of sigmma of gauss function
# @param {number} [size=3] size of the kernel (must be an odd number)
# @return {object} GrayImageData object
###
CannyJS.canny = (canvas, ht=100, lt=50, sigmma=1.4, kernelSize=3) ->
  imgData = new GrayImageData(canvas.width, canvas.height)
  imgData.loadCanvas(canvas)
  blur = CannyJS.gaussianBlur(imgData, sigmma, kernelSize)
  sobel = CannyJS.sobel(blur)
  nms = CannyJS.nonMaximumSuppression(sobel)
  CannyJS.hysteresis(nms, ht, lt)

window.CannyJS = CannyJS
window.GrayImageData = GrayImageData

  
