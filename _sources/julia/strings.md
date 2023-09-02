# Строки

Подробнее о строках в мануале **[[url]](https://docs.julialang.org/en/v1/manual/strings/)**.

В Julia богатая поддержка работы с текстом, встроенные текстовые типы работают с Unicode. Основные типы: `Char`, `String` и `SubString`.

Тип `Char` используется для работы с отдельными символами, его литерал две одинарные кавычки `'`.

% здесь почему-то julia-repl не работает. Убрал, чтобы jb build не ругался
```
julia> 'a'
'a': ASCII/Unicode U+0061 (category Ll: Letter, lowercase)

julia> 'α'
'α': Unicode U+03B1 (category Ll: Letter, lowercase)

julia> 'aa'
ERROR: syntax: character literal contains multiple characters
Stacktrace:
 [1] top-level scope
   @ none:1
```

Тип `String` предназначен для строк, его литерал двойные кавычки `"`.

```julia-repl
julia> "a"
"a"

julia> "a" == 'a'
false

julia> "aaaa"
"aaaa"

julia> typeof("aaaa")
String
```

Escape специальных символов производится привычным `\`, например `'\n'`, `'\t'`.

```{list-table} Часто используемые операции над строками.
:header-rows: 1

* - Описание
  - Cинтаксис
  - Пример
  - Результат
* - Конкатенация
  - `x * y`
  - `"ab" * "b"`
  - `"abb"`
* - Дублирование
  - `x ^ i`
  - `"a" ^ 6`
  - `"aaaaaa"`
* - Интерполяция значения переменной
  - `"$x"`
  - `y = 1.0; x = "$y"`
  - `x` будет `"1.0"`
* - Интерполяция результата выражения
  - `"$(expr)"`
  - `"$(sin(π/2))"`
  - `"1.0"`
* - Разбиение строки
  - `split(x)`
  - `split("a b\nc\td")`
  - `["a", "b", "c", "d"]` (массив)
* - Сбор строки
  - `join(x [, delim])`
  - `join([25, "февраля", 1936], " ")`
  - `"25 февраля 1936"`
* - Удаление whitespace окружения
  - `strip(x)`
  - `strip(" \ta ba\n")`
  - `"a ba"`
* - Форматированная строка (`using Printf`)
  - `@sprintf "fmt" x...`
  - `@sprintf "π ≈ %.2f, ℯ ≈ %.2f" π ℯ`
  - `"π ≈ 3.14, ℯ ≈ 2.72"`
* - Печать в stdout
  - `println(x,..)`
  - `println("A = ", 10)`
  - Печатает в stdout "A = 10"
* - `@show`: печать выражения
  - `@show expr1[ expr2 ...]`
  - `x = 2; @show x^3`
  - Печатает в stdout `x ^ 3 = 8`
* - Чтение из stdin
  - `readline()`
  - `readline()`
  - Ожидание ввода
* - Парсинг строки
  - `parse(T, x)`
  - `parse(Float64, "1.564")`
  - `1.564`
```

Строки в Julia являются неизменяемыми объектами. Однако, часто требуется поработать с каким-то участком строки. Для этого, чтобы экономить память и время, в Julia существует тип `SubString`, который указывает на часть строки, но при этом ведёт себя как `String`.

```julia-repl
julia> split(strip("  1.0 2.0 3.0   "))
3-element Vector{SubString{String}}:
 "1.0"
 "2.0"
 "3.0"

julia> parse.(Float64, ans)  # ans -- внутренняя переменная REPL, хранящая результат последнего вычисления
3-element Vector{Float64}:
 1.0
 2.0
 3.0
```
