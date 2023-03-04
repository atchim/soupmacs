README.md: soupmacs.fnl mdoer.fnl
	cat soupmacs.fnl | fennel mdoer.fnl >README.md

all: README.md

clean: README.md
	rm -fr $^

.PHONY: all clean
