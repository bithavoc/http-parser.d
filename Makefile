OS_NAME=$(shell uname -s)
MH_NAME=$(shell uname -m)
DFLAGS=-gc -gs -g $(DUV_FLAGS)
ifeq (${OS_NAME},Darwin)
	DFLAGS+=-L-framework -LCoreServices 
endif
DC=dmd

build: http-parser.d

test: test/*.d http-parser.d
	$(DC) -ofout/tests.app -unittest -Iout/di out/http-parser.a test/*.d $(DFLAGS)
	chmod +x out/tests.app
	out/tests.app

examples: http-parser.d examples/*
		mkdir -p out/examples
		for EXAMPLE_FILE in examples/${example}*.d; do \
			EXAMPLE_FILE_OUT=out/$$EXAMPLE_FILE.app ; \
			echo "Compiling Example $$EXAMPLE_FILE" ; \
			$(DC) -of$$EXAMPLE_FILE_OUT $$EXAMPLE_FILE -Iout/di out/http-parser.a ; \
			chmod +x $$EXAMPLE_FILE_OUT ; \
			echo "==> Example $$EXAMPLE_FILE was compiled in program $$EXAMPLE_FILE_OUT" ; \
		done

http-parser.c:
	CFLAGS="$(CFLAGS)" $(MAKE) -C deps/http-parser http_parser.o
	cp deps/http-parser/http_parser.o out/http-parser.o

http-parser.d.c: http-parser.c
		mkdir -p out
		$(CC) -Ideps/http-parser -o out/http-parser.d.c.o -c src/*.c $(CFLAGS)

http-parser.d.lib: lib/http/parser/*.d http-parser.d.c http-parser.c
		mkdir -p out/di
		mkdir -p out/docs
		$(DC) -c -ofout/http-parser.d.lib.o -Hdout/di/http/parser lib/http/parser/*.d -Ddout/docs/ $(DFLAGS)

http-parser.d: http-parser.d.lib http-parser.d.c http-parser.c
		rm -f out/http-parser.a
		ar -r out/http-parser.a out/http-parser.o out/http-parser.d.c.o out/http-parser.d.lib.o

clean:
		rm -rf out/*
		$(MAKE) -C deps/http-parser clean
