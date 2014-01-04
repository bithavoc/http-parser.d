import http.parser.core;
import std.stdio;
import testutil;

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
          parser.onBody = (parser, ubyte[] data) {
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
      });
    }); //HttpParser
  }
}

void main() {
  writeln("All Tests OK");
}
