all: README.md

clean:
	rm -fr README.md

README.md: macros.fnl
	./make-readme

.PHONY: all clean
