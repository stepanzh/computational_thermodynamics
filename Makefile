all: book

book:
	jupyter-book build book

publish:
	ghp-import -n -p -f book/_build/html

help:
	@echo 'Make targets'
	@echo '  help    : show this help message and exit'
	@echo '  book    : build pages for the book'
	@echo '  publish : publish *already* built pages to github'

.PHONY: book
