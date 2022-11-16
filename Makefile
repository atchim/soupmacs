all: README.md

clean: README.md
	rm -fr $^

README.md: mkreadme soupmacs.fnl
	./mkreadme

.PHONY: all clean
