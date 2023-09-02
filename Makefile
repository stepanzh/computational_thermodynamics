default: help

book:
	jupyter-book build book

publish:
	ghp-import -n -p -f book/_build/html

help:
	@echo 'Make targets'
	@echo '  help (default) : show this help message and exit'
	@echo '  book           : build pages for the book'
	@echo '  publish        : publish *already* built pages to github'
