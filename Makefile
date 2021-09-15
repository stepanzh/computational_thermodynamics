default: help

build:
	jupyter-book build book

pages:
	ghp-import -n -p -f book/_build/html

help:
	@echo 'Make targets'
	@echo '  help (default) : show this help message and exit'
	@echo '  build          : build pages for the book'
	@echo '  pages          : publish *already* built pages to github'
