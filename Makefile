all: README.md
clean: README.md ; rm -fr $^
.PHONY: all clean

README.md: soupmacs.fnl gen-md-doc.fnl
	cat soupmacs.fnl | fennel gen-md-doc.fnl >README.md