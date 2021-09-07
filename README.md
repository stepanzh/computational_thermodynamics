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
% jb build book                           # билд статического сайта, стартовая страница
% open book/_build/html/index.html
```

- документация jupyter{book} https://jupyterbook.org/intro.html;
- мои заметки по использованию https://stepanzh.github.io/JuliaAndJupyterBook/intro.html.
