all: README.md

clean: README.md
	rm -fr $^

README.md: soupmacs.fnl
	./make-readme

.PHONY: all clean
