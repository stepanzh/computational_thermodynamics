"""Печатает sitemap.xml в stdout.
Что такое sitemap.xml? - https://www.sitemaps.org/protocol.html

Степан Захаров (github: stepanzh),
2024
"""

# Если книга переедет, измените url ниже.
# Базовый URL, где хостится книга (index page url).
book_base_url = "https://stepanzh.github.io/computational_thermodynamics/"



# Ссылки достаются из _toc.yml файла.
# Для этого в jupyter-book уже есть модуль (см parse_toc_yml).
# Остаётся лишь к ним приписать в начало book_base_url, а в конец .html.
# Я пробовал использовать xml.etree.ElementTree, но там вывод в файл некрасивый, поэтому ниже велосипед, чтобы не тянуть third-party зависимости.


from dataclasses import dataclass
import pathlib
from typing import List, Optional
from sphinx_external_toc.parsing import parse_toc_yaml
import sys
from urllib.parse import urljoin


@dataclass
class SitemapUrl:
    loc: str
    lastmod: Optional = None
    changefreq: Optional = None
    priority: Optional = None

    def tostringlist(self) -> List[str]:
        surround = lambda tag, value: f"<{tag}>{value}</{tag}>"

        tags = [surround("loc", self.loc)]
        if self.lastmod:
            tags.append(surround("lastmod", self.lastmod))
        if self.changefreq:
            tags.append(surround("changefreq", self.changefreq))
        if self.priority:
            tags.append(surround("priority", self.priority))

        return tags


class SitemapUrlSet:
    xmlns: str = "http://www.sitemaps.org/schemas/sitemap/0.9"
    xml_declaration: str = '<?xml version="1.0" encoding="UTF-8"?>'

    def __init__(self):
        self._urls = []

    def add(self, url: SitemapUrl) -> None:
        self._urls.append(url)

    def tostring(self) -> str:
        lst = [self.xml_declaration, ""]
        lst.append(f'<urlset xmlns="{self.xmlns}">')

        for url in self._urls:
            lst.append("  <url>")
            for field in url.tostringlist():
                lst.append("    " + field)
            lst.append("  </url>")

        lst.append(f'</urlset>')
        return '\n'.join(lst)


book_dir = pathlib.Path(__file__).parent.resolve()
toc_path = book_dir / "_toc.yml"

if not toc_path.is_file():
    print("Table of contents file (_toc.yml) does not exists:", file=sys.stderr)
    print(" ", toc_path, file=sys.stderr)
    sys.exit(1)


sitemap_list = parse_toc_yaml(toc_path)
urlset = SitemapUrlSet()

for page_path in sitemap_list:
    url = urljoin(book_base_url, page_path + ".html")
    urlset.add(SitemapUrl(url))

print(urlset.tostring())
