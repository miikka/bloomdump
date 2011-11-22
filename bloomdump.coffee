fs   = require('fs')
path = require('path')

CoffeeScript = require('coffee-script')
Png          = require('./png').Png
Rational     = require('rational').Rational
Mustache     = require('mustache')

bloomfilter = require('./bloomfilter')
sha1        = require('./vendor/sha1.js')

BloomFilter   = bloomfilter.BloomFilter
BufferBackend = bloomfilter.BufferBackend

parser = new Rational '''
	bloomdump [OPTION...] filename
	--
	h,help              print this help
	t,template=         use the given template to generate HTML
	e,error-rate=       the error rate of the generated Bloom filter [0.01]
'''

filename     = ""
templatePath = "bloomdump.tmpl"
errorRate    = 0.01

try
	result = parser.parse(process.argv)

	if result.options.h
		parser.usage()
		process.exit(0)

	filename = result.extras[2]

	throw ("Input file name is required.") unless filename?
	throw ("Input file not found: #{filename}") unless path.existsSync(filename)

	templatePath = result.options.template unless result.options.template == true
	throw ("Template not found: #{templatePath}") unless path.existsSync(templatePath)

	errorRate = parseFloat(result.options.e)
	throw ("Error rate should be a float between 0 and 1: #{errorRate}") unless 0 < errorRate < 1

catch e
	parser.usage()
	console.error()
	console.error(e)
	process.exit(1)

template = fs.readFileSync(templatePath, "utf-8")

calculate_filter_length = (capacity, error_rate) ->
	lowest_m = null
	best_k = 1

	for k in [1..100]
		m = (-1 * k * capacity) / Math.log(1 - Math.pow(error_rate, (1/k)))
		if lowest_m is null or m < lowest_m
			lowest_m = m
			best_k = k
	
	[Math.ceil(lowest_m), Math.ceil(best_k)]

trim = (str) -> str.replace(/^\s*|\s*$/g, '')

class EasyBloomFilter extends BloomFilter
	constructor: (@capacity, @error_rate) ->
		[m, k] = calculate_filter_length(@capacity, @error_rate)
		backend = new BufferBackend(m * k)
		super(backend, m, k, sha1.hex_sha1)

lines = fs.readFileSync(filename, "utf-8").split("\n")

bf = new EasyBloomFilter(lines.length, 0.01)

#console.log(bf.m, bf.k)

for line in lines
	bf.add(trim(line))

png = new Png(bf.backend.buffer, Math.ceil(bf.m/(24*400)), 400, 'rgb')
png_image = png.encodeSync()

ctx =
	sha1:        fs.readFileSync('./vendor/sha1.js', 'utf-8')
	bloomfilter: CoffeeScript.compile(fs.readFileSync('bloomfilter.coffee', 'utf-8'))
	image:       'data:image/png;base64,' + png_image.toString('base64')
	m: 			 bf.m
	k: 			 bf.k
	filename:    path.basename(filename)

console.log(Mustache.to_html(template, ctx))
