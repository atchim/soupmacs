all: README.md

clean: README.md
	rm -fr $^

README.md: macros.fnl
	./make-readme

.PHONY: all clean
