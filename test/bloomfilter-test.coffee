#!/usr/bin/env vows --spec

vows   = require('vows')
assert = require('assert')
sha1   = require('../vendor/sha1.js')

Canvas = require('canvas')

bloomfilter = require('../bloomfilter')

BloomFilter   = bloomfilter.BloomFilter
BufferBackend = bloomfilter.BufferBackend
CanvasBackend = bloomfilter.CanvasBackend

testBackend = (name, createBackend, size) ->
	batch = {}

	batch["An empty #{name}"] =
		topic: -> createBackend(size)

		'should be big enough': (backend) ->
			assert.ok(backend.size >= size)

		'should have all bits unset': (backend)	->
			for idx in [0...backend.size]
				assert.equal(backend.at(idx), false)

	batch["A #{name} with one bit set"] =
		topic: ->
			backend = createBackend(size)
			pos = Math.floor(Math.random() * size)
			backend.set(pos)
			[backend, pos]

		'should have that bit set': ([backend, pos]) ->
			assert.equal(backend.at(pos), true)

		'should have the other bits unset': ([backend, pos]) ->
			for idx in [0...backend.size] when idx != pos
				assert.equal(backend.at(idx), false)
	
	batch

createCanvas = (size) ->
	canvas = new Canvas(Math.ceil(size/10), 10)
	new CanvasBackend(canvas)

suite = vows.describe('Bloom filter')

suite.addBatch(testBackend('BufferBackend', ((size) -> new BufferBackend(size)), 49 * 3))
suite.addBatch(testBackend('CanvasBackend', createCanvas, 49 * 3))

suite.addBatch(
	'Saved and loaded CanvasBackend':
		topic: ->
			size= 49 * 3

			backend1 = createCanvas(size)
			for idx in [0..size]
				backend1.set(idx) if Math.floor(Math.random * 2) == 1

			backend2 = createCanvas(size)
			backend2.load(backend1.toDataURL())

			[backend1, backend2]

		'should be equivalent to the original backend': ([backend1, backend2]) ->
			assert.ok(backend1.size == backend2.size)
			for idx in [0..backend1.size]
				assert.ok(backend1.at(idx) == backend2.at(idx))
)

suite.addBatch(
	'An empty BloomFilter':
		topic: -> new BloomFilter(new BufferBackend(49 * 3), 49, 3, sha1.hex_sha1)

		'should not contain any elements': (bf) ->
			assert.equal(bf.has('test1'), false)

	'A BloomFilter with one element':
		topic: ->
			bf = new BloomFilter(new BufferBackend(49 * 3), 49, 3, sha1.hex_sha1)
			bf.add('test1')

		'should contain the element': (bf) ->
			assert.ok(bf.has('test1'))

		'should (probably) not contain other elements': (bf) ->
			assert.ok(!bf.has('test2'))

).export(module)
