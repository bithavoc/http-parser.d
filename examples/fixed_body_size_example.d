// Copyright (c) 2013 Heapsource.com and Contributors - http://www.heapsource.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


import std.stdio;
import http.parser.core;

void main() {
  "http-parser.d in action with fixed-size Http Message Body".writeln;
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
  parser.onStatusComplete = (parser, string data) {
    writeln("HTTP status is complete");
  };
  parser.onHeader = (parser, HttpHeader header) {
    writeln("Parser Header '", header.name, "' with value '", header.value, "'");
  };
  parser.onBody = (parser, HttpBodyChunk data) {
    writeln("A chunk of the HTTP body has been processed: ", data.buffer);
  };
	parser.execute("GET / HTTP 1.1\r");
	parser.execute("\n");
	parser.execute("FirstHeader: ValueOfFirst Header\r\n");
	parser.execute("Content-Length: 3\r\n");
  parser.execute("\r\n");
  ubyte[] bodyChunk = [1u,2u,3u];
  parser.execute(bodyChunk);
}
