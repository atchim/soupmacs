all: README.md

clean: README.md
	rm -fr $^

README.md: make-readme soupmacs.fnl
	./make-readme

.PHONY: all clean
