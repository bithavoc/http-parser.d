http-parser.D
===

http-parser.D = [joyent/http-parser](https://github.com/joyent/http-parser/) in D programming language.

## Usage

	import std.stdio;
	import http.parser.core;
	...
	auto parser = new HttpParser();
	parser.onMessageBegin = (parser) {
		writeln("Message has just begun");
	};
	parser.onMessageComplete = (parser) {
		writeln("Message has been completed");
	};
	parser.onUrl = (parser, string data) {
		writeln("Url of HTTP message is: ", data);
	};
	parser.onStatusComplete = (parser) {
		writeln("HTTP status is complete");
        // if parsing request, this is a good spot to query for:
        if(parser.type == HttpParserType.REQUEST) {
            string method = parser.method; // GET
            writeln("Method: ", method);
        }
        auto version = parser.protocolVersion.toString; // 1.1
	};
	parser.onHeader = (parser, HttpHeader header) {
		writeln("Parser Header '", header.name, "' with value '", header.value, "'");
	};
	parser.onBody = (parser, HttpBodyChunk chunk) {
        string isFinal = chunk.isFinal ? "final" : "not final" ;
		writeln(std.string.format("A chunk of the HTTP body has been processed: %s (%s) ", chunk.buffer, isFinal));
	};
	parser.execute("GET / HTTP 1.1\r");
	parser.execute("\n");
	parser.execute("FirstHeader: ValueOfFirst Header\r\n");
	parser.execute("Content-Length: 3\r\n");
	parser.execute("\r\n");
	ubyte[] bodyChunk = [1u,2u,3u];
	parser.execute(bodyChunk);


Output:


	Message has just begun
	Url of HTTP message is: /
	Parser Header 'FirstHeader' with value 'ValueOfFirst Header'
	Parser Header 'Content-Length' with value '3'
	A chunk of the HTTP bady has been processed: [1, 2, 3] (is final)
	Message has been completed

## Uri

Uri parsing is provided by the class `http.parser.Uri`.

```D
import http.parser : Uri;

//...

Uri uri = new Uri("http://user1:password1@google.com:9000/myResource?indent=1#page_2");
string schema = uri.schema; // -> "http"
string credentials = uri.userInfo; // -> "user1:password1"
string host = uri.host; // -> "google.com"
ushort port = uri.port; // -> 9000
string path = uri.path; // -> "/myResource"
string query = uri.query; // -> "ident=1"
string fragment = uri.fragment; // -> "page_2"

```

## Building

	make

An archive will be generated in `out/http-parser.a` containing joyent/http-parser objects and the http-parser.d object itself.

## Examples

Use `make examples` to compile all the examples. Executables will be generated in `out/examples`.


## Test


	make test


## License (MIT)

Copyright (c) 2013, 2014 Heapsource.com - http://www.heapsource.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
