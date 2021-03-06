OS_NAME=$(shell uname -s)
MH_NAME=$(shell uname -m)
DFLAGS=
OS_TYPE=linux
ifeq (${OS_NAME},Darwin)
	DFLAGS+=-L-framework -LCoreServices 
endif
HTTP_PARSER_LIB_BUILD=
ifeq (${DEBUG}, 1)
	DFLAGS=-debug -gc -gs -g
else
	DFLAGS=-O -release -inline -noboundscheck
	HTTP_PARSER_LIB_BUILD=package
endif
ifeq (${OS_NAME},Darwin)
	OS_TYPE=osx
endif
DC?=dmd

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

deps/http-parser/http_parser.o:
	@echo "Compiling deps/http-parser"
	git submodule update --init deps/http-parser
	mkdir -p out/di
	(cd deps/http-parser; $(MAKE) $(HTTP_PARSER_LIB_BUILD))
	cp deps/http-parser/http_parser.o out/http-parser.o

http-parser.d.c: deps/http-parser/http_parser.o
		mkdir -p out
		$(CC) -Ideps/http-parser -o out/http-parser.d.c.o -c src/*.c $(CFLAGS)

http-parser.d.lib: lib/http/parser/*.d http-parser.d.c
		mkdir -p out/di
		mkdir -p out/docs
		$(DC) -c -ofout/http-parser.d.lib.o -Hdout/di/http/parser lib/http/parser/*.d -Ddout/docs/ $(DFLAGS)

http-parser.d: http-parser.d.lib
		rm -f out/http-parser.a
		ar -r out/http-parser.a out/http-parser.o out/http-parser.d.c.o out/http-parser.d.lib.o

dub: http-parser.d
	mkdir -p dub/bin
	cp out/http-parser.d.c.o dub/bin/http-parser-$(OS_TYPE)-$(MH_NAME).d.c.o
	cp out/http-parser.o dub/bin/http-parser-$(OS_TYPE)-$(MH_NAME).o

.PHONY: clean


clean:
		# rm -rf deps/http-parser/*
		rm -rf deps/http-parser/*.a deps/http-parser/*.o
		rm -rf out/*
