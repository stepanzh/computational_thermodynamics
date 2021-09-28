[![Jupyter Book Badge](https://jupyterbook.org/badge.svg)](https://stepanzh.github.io/JuliaAndJupyterBook/)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

# Репозиторий курса "Практикум по вычислительной теплофизике"

## Читателям
Книга расположена здесь https://stepanzh.github.io/computational_thermodynamics/.

## Разработчикам

Локальное тестирование сайта

```console
% git clone https://github.com/stepanzh/computational_thermodynamics.git
% virtualenv venv           # виртуальное окружение,
% source venv/bin/activate  # если необходимо не мусорить
% pip3 freeze               # в библиотеках python3
% cd computational_thermodynamics
% pip3 install -r book/requirements.txt   # установка необходимых библиотек
% jupyter-book -h                         # или jb -h, проверка, что всё установилось
% jb build book                           # билд статического сайта
% open book/_build/html/index.html        # открытие локальной стартовой страницы сайта-книги
```

- документация jupyter{book} https://jupyterbook.org/intro.html;
- мои заметки по использованию https://stepanzh.github.io/JuliaAndJupyterBook/intro.html;
- утилиты по тестированию и публикации изменений: `make` в корне репозитория. 

### Цитирование

1. Добавьте bibtex запись в `book/praktikum.bib`. Поддерживается Unicode (до какой-то степени).
2. Процитируйте в тексте книги ``` {cite}`CiteLabel2001` ```.

### Указатель

Указатель это страница книги со ссылками на места в книге, объявленные пользователем. Если в печатном случае указатель обычно точен до страницы, то здесь точность до параграфа.

Используйте для этого директиву `{index} entries`.

Например, `{index} функция; Гаусса`, `{index} функция; непрерывная` создаст следующую структуру в указателе

- функция (без ссылки)
    - Гаусса, ссылка
    - непрерывная, ссылка

Также можно использовать и роль `{index}`, но её точность указания (строка параграфа), кажется, не нужна.

У `{index}` много полезных модификаторов, упрощающих жизнь, см. [[url]](https://www.sphinx-doc.org/en/1.4.9/markup/misc.html?highlight=index#index-generating-markup).
