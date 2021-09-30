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

### Исполняемый код

Исполняемый код я делю на библиотечный и остальной, который пользуется библиотечным.

Библиотечный код хранится в `book/src.jl`.
Там подключаются используемые модули (так не приходится в каждой `{cell-code}` писать `using`) и содержатся функции из книги.
В отдельный модуль этот код не обёрнут.

Чтобы им воспользоваться, добавьте ячейку кода (`{code-cell}` директива) в страницу книги с содержанием

```
:tags: [remove-cell]

include("../src.jl")
```

`"../src.jl"` здесь путь до `src.jl` от исходного файла страницы.

Далее на странице книги в `{code-cell}` ниже всё будет доступно.

Все необходимые зависимости помещены в `book/Project.toml`.

### Графики

Графики генерируются с помощью Plots.jl. В этой библиотеке функции возвращают объект графика, который должен быть результатом вычисления ячейки кода.

Если не получается вызвать функцию построения последней в ячейке, сохраните заранее объект

```julia
plt = plot(; xlabel="foo", ylabel="bar")
for i in (10, 100)
    x = ...
    y = foo.(x)
    plot!(x, y; label="$i", ...)
end
plt
```

### Таблицы

Таблицы генерируются с помощью `PrettyTables.jl` с указанием `backend=:html`.

```julia
pretty_table(data;
    header=["Вещество", "M, г/моль", "σ, Å", "ε/k, K", "Tmin, K", "Tmax, K", "NIST"],
    backend=:html,
    alignment=:c
)
```

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
