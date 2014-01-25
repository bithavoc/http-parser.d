import http.parser.core;
import std.stdio;
import testutil;
import std.typecons;

unittest {
  {
    scopeTest("HttpParser", {
      scopeTest("Exceptions", {
        string customErrorMessage = "Custom Error";
        runTest("onMessageBegin", {
          Exception lastException;
          auto parser = new HttpParser();
          parser.onMessageBegin = (parser) {
            throw new Exception(customErrorMessage);
          };
          try {
            parser.execute(cast(ubyte[])"GET / HTTP/1.1\r\n\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException !is null, "Custom exception was not cached and throwed by the execute method");
          assert(lastException.msg == customErrorMessage, "Exception raised doesn't have the given exception");
        });
        runTest("onMessageComplete", {
          Exception lastException;
          auto parser = new HttpParser();
          parser.onMessageComplete = (parser) {
            throw new Exception(customErrorMessage);
          };
          try {
            parser.execute(cast(ubyte[])"GET / HTTP/1.1\r\n\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException !is null, "Custom exception was not cached and throwed by the execute method");
          assert(lastException.msg == customErrorMessage, "Exception raised doesn't have the given exception");
        });
        runTest("onHeadersComplete", {
          Exception lastException;
          auto parser = new HttpParser();
          parser.onHeadersComplete = (parser) {
            throw new Exception(customErrorMessage);
          };
          try {
            parser.execute(cast(ubyte[])"GET / HTTP/1.1\r\nHeaderA: Valor del Header 1\r\n\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException !is null, "Custom exception was not cached and throwed by the execute method");
          assert(lastException.msg == customErrorMessage, "Exception raised doesn't have the given exception");
        });
        runTest("onBody", {
          Exception lastException;
          auto parser = new HttpParser();
          parser.onBody = (parser, chunk) {
            throw new Exception(customErrorMessage);
          };
          try {
            parser.execute(cast(ubyte[])"GET / HTTP/1.1\r\nContent-Length: 3\r\n\r\naaa");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException !is null, "Custom exception was not cached and throwed by the execute method");
          assert(lastException.msg == customErrorMessage, "Exception raised doesn't have the given exception");
        });
        runTest("onUrl", {
          Exception lastException;
          auto parser = new HttpParser();
          parser.onUrl = (parser, string data) {
            throw new Exception(customErrorMessage);
          };
          try {
            parser.execute(cast(ubyte[])"GET / HTTP/1.1\r\n\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException !is null, "Custom exception was not cached and throwed by the execute method");
          assert(lastException.msg == customErrorMessage, "Exception raised doesn't have the given exception");
        });
        runTest("onStatusComplete", {
          Exception lastException;
          auto parser = new HttpParser(HttpParserType.RESPONSE);
          string st;
          parser.onStatusComplete = (parser, status) {
            st = status;
            throw new Exception(customErrorMessage);
          };
          try {
            parser.execute(cast(ubyte[])"HTTP/1.1 200 OK\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException !is null, "Custom exception was not cached and throwed by the execute method");
          assert(lastException.msg == customErrorMessage, "Exception raised doesn't have the given exception");
          assert(st == "OK");
        });
        runTest("onStatusComplete Request", {
          Exception lastException;
          auto parser = new HttpParser(HttpParserType.REQUEST);
          string st;
          parser.onStatusComplete = (parser, status) {
            st = status;
          };
          try {
            parser.execute(cast(ubyte[])"GET / HTTP/1.1\r\n\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException is null);
          assert(st == "");
          assert(parser.method == "GET");
        });
      }); //Exceptions
      scopeTest("Headers", {
        runTest("chunked", {
          HttpHeader headers[];
          Exception lastException;
          auto parser = new HttpParser();
          parser.onHeader = (parser, HttpHeader header) {
            headers ~= header;
          };
          try {
            parser.execute(cast(ubyte[])"GET / HTTP/1.1\r\nHea");
            parser.execute(cast(ubyte[])"de");
            parser.execute(cast(ubyte[])"r1: Val");
            parser.execute(cast(ubyte[])"ue1\r\n");
            parser.execute(cast(ubyte[])"Header");
            parser.execute(cast(ubyte[])"2: Val");
            parser.execute(cast(ubyte[])"ue2\r\n\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException is null, "No exception should be throwed");
          assert(headers.length == 2, "The parsed headers do not match");
          assert(headers[0].name == "Header1", "Header 0 name did not match");
          assert(headers[0].value == "Value1", "Header 0 value did not match");
          assert(headers[1].name == "Header2", "Header 1 name did not match");
          assert(headers[1].value == "Value2", "Header 1 value did not match");
        });
        runTest("batch", {
          HttpHeader headers[];
          Exception lastException;
          auto parser = new HttpParser();
          parser.onHeader = (parser, HttpHeader header) {
            headers ~= header;
          };
          try {
            parser.execute(cast(ubyte[])"GET / HTTP/1.1\r\nHeader1: Value1\r\nHeader2: Value2\r\n\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException is null, "No exception should be throwed");
          assert(headers.length == 2, "The parsed headers do not match");
          assert(headers[0].name == "Header1", "Header 0 name did not match");
          assert(headers[0].value == "Value1", "Header 0 value did not match");
          assert(headers[1].name == "Header2", "Header 1 name did not match");
          assert(headers[1].value == "Value2", "Header 1 value did not match");
        });
        runTest("status", {
          Exception lastException;
          auto parser = new HttpParser(HttpParserType.RESPONSE);
          bool callbackCalled = false;
          string status = null;
          parser.onStatusComplete = (parser, st) {
            status = st;
            callbackCalled = true;
          };
          try {
            parser.execute(cast(ubyte[])"HTTP/1.1 200 OK\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException is null, "No exception should be throwed");
          assert(callbackCalled, "onStatusCompleted callback must be invoked");
          assert(status == "OK");
        });
        runTest("http 1.1 version", {
          Exception lastException;
          auto parser = new HttpParser(HttpParserType.RESPONSE);
          bool callbackCalled = false;
          string status = null;
          HttpVersion v;
          parser.onStatusComplete = (parser, st) {
            status = st;
            v = parser.protocolVersion;
            callbackCalled = true;
          };
          try {
            parser.execute(cast(ubyte[])"HTTP/1.1 200 OK\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException is null, "No exception should be throwed");
          assert(callbackCalled, "onStatusCompleted callback must be invoked");
          assert(status == "OK");
          assert(v.toString == "1.1");
          assert(v.minor == 1);
          assert(v.major == 1);
        });
        runTest("http 1.0 version", {
          Exception lastException;
          auto parser = new HttpParser(HttpParserType.RESPONSE);
          bool callbackCalled = false;
          string status = null;
          HttpVersion v;
          parser.onStatusComplete = (parser, st) {
            status = st;
            v = parser.protocolVersion;
            callbackCalled = true;
          };
          try {
            parser.execute(cast(ubyte[])"HTTP/1.0 200 OK\r\n");
          } catch(Exception ex) {
            lastException = ex;
          }
          assert(lastException is null, "No exception should be throwed");
          assert(callbackCalled, "onStatusCompleted callback must be invoked");
          assert(status == "OK");
          assert(v.toString == "1.0");
          assert(v.minor == 0);
          assert(v.major == 1);
        });
        runTest("URI schema", {
            Uri uri = Uri("testschema://jhon:doe@hello.com/root/sub?delete=1#paragraph1");
            assert(uri.schema == "testschema", "parsed schema is not 'testschema'");
            assert(uri.host == "hello.com", "parsed host is not 'hello.com', current is " ~ uri.host);
            assert(uri.port == 0, "parsed port is not '0', current is " ~ std.conv.to!string(uri.port));
            assert(uri.path == "/root/sub", "parsed path is not '/root/sub', current is " ~ uri.path);
            assert(uri.query == "delete=1", "parsed query is not 'delete=1', current is " ~ uri.query);
            assert(uri.fragment == "paragraph1", "parsed fragment is not 'paragraph1', current is " ~ uri.fragment);
            assert(uri.userInfo == "jhon:doe", "parsed userInfo is not 'jhon:doe', current is " ~ uri.userInfo);
        });
        runTest("URI special port", {
            Uri uri = Uri("testschema://hello.com:9000");
            assert(uri.port == 9000, "parsed port is not '9000', current is " ~ std.conv.to!string(uri.port));
        });
      });
      scopeTest("HTTP Body", {
        runTest("onBody isFinal", {
          auto parser = new HttpParser();
          HttpBodyChunk[] readings;
          Throwable lastException;
          parser.onBody = (parser, HttpBodyChunk chunk) {
            readings ~= chunk;
          };
          try {
            parser.execute(cast(ubyte[])"POST / HTTP/1.1\r\nContent-Length: 6\r\n\r\naaa");
            parser.execute(cast(ubyte[])"bbb");
          } catch(Throwable ex) {
            lastException = ex;
          }
          assert(lastException is null, "Something happened while executing a body post");
          assert(readings[0].buffer == [97, 97, 97], "first chunk should read  aaa");
          assert(!readings[0].isFinal, "first chunk should not be final");
          assert(readings[1].buffer == [98, 98, 98], "second chunk should read  aaa");
          assert(readings[1].isFinal, "second chunk should be final");
        });
        runTest("onBody contentLength", {
          auto parser = new HttpParser();
          HttpBodyChunk[] readings;
          Throwable lastException;
          parser.onBody = (parser, HttpBodyChunk chunk) {
            readings ~= chunk;
          };
          ulong contentLength = 0;
          parser.onHeadersComplete = (parser) {
            contentLength = parser.contentLength;
          };
          try {
            parser.execute(cast(ubyte[])"POST / HTTP/1.1\r\nContent-Length: 6\r\n\r\naaa");
            parser.execute(cast(ubyte[])"bbb");
          } catch(Throwable ex) {
            lastException = ex;
          }
          assert(lastException is null, "Something happened while executing a body post");
          assert(readings[0].buffer == [97, 97, 97], "first chunk should read  aaa");
          assert(!readings[0].isFinal, "first chunk should not be final");
          assert(readings[1].buffer == [98, 98, 98], "second chunk should read  aaa");
          assert(readings[1].isFinal, "second chunk should be final");
          assert(contentLength == 6, "Content Length should be 6");
        });
        runTest("onBody HttpBodyTransmissionMode.ContentLength", {
          auto parser = new HttpParser();
          Throwable lastException;
          HttpBodyTransmissionMode mode;
          parser.onHeadersComplete = (parser) {
            mode = parser.transmissionMode;
          };
          try {
            parser.execute(cast(ubyte[])"POST / HTTP/1.1\r\nContent-Length: 10\r\n\r\n");
          } catch(Throwable ex) {
            lastException = ex;
          }
          assert(lastException is null, "Something happened while executing a body post");
          assert(mode == HttpBodyTransmissionMode.ContentLength, "Transmission must be ContentLength");
        });
        runTest("onBody HttpBodyTransmissionMode.Chunked", {
          auto parser = new HttpParser();
          Throwable lastException;
          HttpBodyTransmissionMode mode;
          parser.onHeadersComplete = (parser) {
            mode = parser.transmissionMode;
          };
          try {
            parser.execute(cast(ubyte[])"POST / HTTP/1.1\r\nTransfer-Encoding: chunked\r\n\r\n");
          } catch(Throwable ex) {
            lastException = ex;
          }
          assert(lastException is null, "Something happened while executing a body post");
          assert(mode == HttpBodyTransmissionMode.Chunked, "Transmission must be Chunked");
        });
        runTest("onBody HttpBodyTransmissionMode.Chunked case insensitivity", {
          auto parser = new HttpParser();
          Throwable lastException;
          HttpBodyTransmissionMode mode;
          parser.onHeadersComplete = (parser) {
            mode = parser.transmissionMode;
          };
          try {
            parser.execute(cast(ubyte[])"POST / HTTP/1.1\r\nTransfer-ENCOding: chunked\r\n\r\n");
          } catch(Throwable ex) {
            lastException = ex;
          }
          assert(lastException is null, "Something happened while executing a body post");
          assert(mode == HttpBodyTransmissionMode.Chunked, "Transmission must be Chunked");
        });
        runTest("onBody HttpBodyTransmissionMode.Chunked inference by presence of Header", {
          auto parser = new HttpParser();
          Throwable lastException;
          HttpBodyTransmissionMode mode;
          parser.onHeadersComplete = (parser) {
            mode = parser.transmissionMode;
          };
          try {
            parser.execute(cast(ubyte[])"POST / HTTP/1.1\r\nTransfer-ENCOding: somethingElse\r\n\r\n");
          } catch(Throwable ex) {
            lastException = ex;
          }
          assert(lastException is null, "Something happened while executing a body post");
          assert(mode == HttpBodyTransmissionMode.Chunked, "Transmission must be Chunked even if the Transfer-Encoding header is not explicitely set to 'chunked'");
        });
      });
    }); //HttpParser
  }
}

void main() {
  writeln("All Tests OK");
}
