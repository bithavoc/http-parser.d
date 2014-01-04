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

module http.parser.c;
import std.conv;
import std.c.stdlib;
import std.stdint;
import std.bitmanip;
import std.stdint;

extern(C):
struct http_parser;

alias int function (http_parser*, ubyte *at, size_t length) http_data_cb;
alias int function (http_parser*) http_cb;

enum http_parser_type { HTTP_REQUEST, HTTP_RESPONSE, HTTP_BOTH };

struct http_parser_settings {
  http_cb      on_message_begin;
  http_data_cb on_url;
  http_data_cb on_status_complete;
  http_data_cb on_header_field;
  http_data_cb on_header_value;
  http_cb      on_headers_complete;
  http_data_cb on_body;
  http_cb      on_message_complete;
};

void http_parser_init(http_parser *parser, http_parser_type type);
size_t http_parser_execute(http_parser *parser, http_parser_settings *settings, ubyte * data, size_t len);

const(char) * duv_http_errno_name(http_parser *parser);
const(char) * duv_http_errno_description(http_parser *parser);

http_parser * duv_alloc_http_parser();
void duv_free_http_parser(http_parser * parser);

void duv_set_http_parser_data(http_parser * parser, void * data);
void * duv_get_http_parser_data(http_parser * parser);

ubyte duv_http_parser_get_errno(http_parser * parser);

template http_parser_cb(string Name) {
	const char[] http_parser_cb = "static int duv_http_parser_" ~ Name ~ "(http_parser * parser) { void * _self = duv_get_http_parser_data(parser); HttpParser self = cast(HttpParser)_self; return self._" ~ Name ~ "(); }";
}

template http_parser_data_cb(string Name) {
	const char[] http_parser_data_cb = "static int duv_http_parser_" ~ Name ~ "(http_parser * parser, ubyte * at, size_t len) { HttpParser self = cast(HttpParser)duv_get_http_parser_data(parser); return self._" ~ Name ~ "(at[0 .. len]); }";
}

immutable(char) * duv_http_method_str(http_parser * parser);

ushort duv_http_major(http_parser * parser);
ushort duv_http_minor(http_parser * parser);
uint duv_http_status_code(http_parser * parser);
