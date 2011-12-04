root   = exports ? this
Image ?= require('canvas').Image

# Generate k different hashes using the given hash function.
make_hashes = (hash, k) ->
	make_hash = (seed) -> (key) ->
		parseInt(hash(seed.toString() + key.toString())[0...8], 16)
	make_hash(seed) for seed in [0...k]

# A bloom filter
root.BloomFilter = class BloomFilter
	constructor: (@backend, @m, @k, hash)->
		@hashes = make_hashes(hash, @k)

	add: (key) ->
		for h in @hashes
			pos = h(key) % @m
			@backend.set(pos)
		this

	# Returns true if the key belongs to the set.
	has: (key) ->
		for h in @hashes
			pos = h(key) % @m
			unless @backend.at(pos)
				return false
		return true

# A canvas-based backend for BloomFilter
root.CanvasBackend = class CanvasBackend
	constructor: (canvas, url = null) ->
		@ctx = canvas.getContext('2d')
		@imageData = @ctx.getImageData(0, 0, canvas.width, canvas.height)
		@size = canvas.width * canvas.height * 24
		@load(url) if url?
	
	load: (url) ->
		img = new Image()

		img.onload = =>
			if img.width > @ctx.canvas.width or img.height > @ctx.canvas.height
				throw "Image is too large for the canvas"
			@ctx.drawImage(img, 0, 0)
			@imageData = @ctx.getImageData(0, 0, img.width, img.height) 
			@size = @imageData.data.length / 4 * 24

		img.src = url
		this

	toDataURL: ->
		@ctx.putImageData(@imageData, 0, 0)
		@ctx.canvas.toDataURL()

	posToCoord: (pos) ->
		pixel = Math.floor(pos / 24)
		byte = Math.floor((pos - pixel * 24) / 8)
		bit = pos - pixel * 24 - byte * 8 
		[pixel, byte, bit]
	
	at: (pos) ->
		[pixel, byte, bit] = @posToCoord(pos)
		(@imageData.data[pixel * 4 + byte] & (1 << bit)) > 0
	
	set: (pos) ->
		[pixel, byte, bit] = @posToCoord(pos)
		# We set the alpha to 255 - otherwise the color data is lost or
		# corrupted.
		@imageData.data[pixel * 4 + 3] = 255
		@imageData.data[pixel * 4 + byte] |= (1 << bit)
