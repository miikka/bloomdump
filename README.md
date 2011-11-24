# bloomdump

`bloomdump` is a tool for creating self-contained HTML pages which allow you to
check whether you are on a list without publishing the list itself.

## Installation

Bloomdump is written in CoffeeScript and is meant to be used with
[Node](http://nodejs.org).  Easiest way to install bloomdump is to use `npm`.

	$ git clone https://github.com/miikka/bloomdump.git
	$ npm install -g bloomdump

Bloomdump depends on the following libraries for Node:

* [CoffeeScript](http://jashkenas.github.com/coffee-script/)
* [node-canvas](https://github.com/learnboost/node-canvas)
* [mustache.js](https://github.com/janl/mustache.js/)
* [Rational](https://github.com/nikhilm/rational)

For running the tests, you also need

* [Vows](http://vowsjs.org/)

## Usage

    $ bloomdump emaildump.txt > emaildump.html

For the command line options, see `bloomdump --help`.

## Contribute

Create issues, fork, send pull requests at [GitHub](https://github.com/miikka/bloomdump).

## Author

Bloomdump was originally created by [Miikka Koskinen](http://miikka.me/). It's
based on Maciej Ceglowski's article [Using Bloom Filters][using-bloom-filters].
A hat tip to [Adam Burmister][adam-burmister] for the idea of using canvas as a
backend.

Bloomdump is bundled with a [JavaScript SHA1 implementation][sha1]
(`vendor/sha1.js`) created by Paul Johnston and others.

[using-bloom-filters]: http://www.perl.com/pub/2004/04/08/bloom_filters.html
[adam-burmister]: https://github.com/adamburmister/JavaScript-Bloom-Filter
[sha1]: http://pajhome.org.uk/crypt/md5

## Copyright and licensing

Please see the file COPYING. For the details on the bundled SHA1 library, see
the file `vendor/sha1.js`. 
