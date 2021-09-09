---
substitutions:
  urldownload: "**[[url]](https://julialang.org/downloads/)**"
  wintermdwnld: "<img src=\"https://www.microsoft.com/favicon.ico%3Fv2\" style=\"height: 1em;\" alt=\"⊞\"> [Windows Terminal](https://aka.ms/terminal)"
---

# Основы языка программирования Julia

```{epigraph}
Julia: come for the syntax, stay for the speed

-- *[Nature](https://www.nature.com/articles/d41586-019-02310-3)*
```

Язык Julia создавался как решение *two-languages problem* в научной и вычислительной среде: программы на языках с простым синтаксисом (`Python`) обычно медленно исполняются, быстрые же программы пишутся на языках со сложным синтаксисом (`C/C++`, `Fortran`).

В данном разделе излагаются основные инструменты языка Julia, которые понадобятся в практикуме.

- Официальная документация языка находится здесь: https://docs.julialang.org/en/v1/.
- Самостоятельно можно обучиться по
  - мануалу https://docs.julialang.org/en/v1/manual/getting-started/;
  - разделу с материалами https://julialang.org/learning/.
- Обзор синтаксиса https://learnxinyminutes.com/docs/ru-ru/julia-ru/.

## Инструкция по установке

Ниже расположены краткие инструкции по установке исполнителя языка Julia для Linux-based операционных систем (ОС), MacOS и Windows 10. При возникновении неясностей, обратитесь к [официальной инструкции](https://julialang.org/downloads/platform/) вашей ОС.

```{admonition} Инструкция для пользователей Linux-based ОС
:class: dropdown

**1. Скачать последнюю версию интерпретатора**

На сайте загрузок {{ urldownload }} найти в таблице свою систему и архитектуру
(скорее всего, это {guilabel}`Generic Linux on x86 → 64-bit`).

:::{warning}
Использовать пакеты `julia` из репозитория дистрибутива настоятельно не рекомендуется, поскольку в репозиториях сборка часто неверно сконфигурирована, из-за чего сторонние библиотеки для Julia могут отказаться работать.
:::

**2. Распаковать скачанный архив**

(предполагаем, что скачанный архив лежит непосредственно в домашней директории)

:::console
$ tar -xzf julia-1.6.2-linux-x86_64.tar.gz
:::

(здесь и далее команды в терминале помечаются `$`)

После этого в домашней директории должна появиться директория {file}`julia-1.6.2`, где находится исполняемый файл интерпретатора и необходимые для его работы библиотеки.

**3. Добавить исполняемый файл в `PATH`**

Рекомендуется вместо добавления в `PATH` директории, в которой лежит исполняемый файл, добавить символьную ссылку на этот файл в директорию, которая уже в `PATH`. В большинстве дистрибутивов директория {file}`~/bin`, если она существует, автоматически добавляется в `PATH`, что позволяет добавить ссылку, даже не имея прав администратора. Если директории {file}`~/bin` нет, то её сначала нужно создать:

:::console
$ mkdir ~/bin
:::

Затем делаем там символьную ссылку на исполняемый файл интерпретатора

:::console
$ ln -s ~/julia-1.6.2/bin/julia ~/bin/julia
:::

Теперь интерпретатор можно запускать, просто набрав `julia` в командной строке (возможно, нужно начать новую сессию в терминале).

Можно вместо домашней директории сделать символьную ссылку в системной директории (нужны права администратора):

:::console
# ln -s ~/julia-1.6.2/bin/julia /usr/local/bin/julia
:::
```

```{admonition} Инструкция для пользователей MacOS
:class: dropdown

1. Скачать `Julia-1.6.app`-пакет с официального сайта языка {{ urldownload }}, {guilabel}`MacOS → 64-bit`;
2. Стандартно для `.app` приложений установить.

Откройте терминал и исполните команду (далее команды терминала помечаются `%`)

:::console
% /Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia --version
:::

Если вы получили в ответ `julia version 1.6.2`, то всё в порядке.

Однако, чтобы в будущем не доступаться до Julia по абсолютному пути, добавьте `alias` в rc-файл вашего терминала.

::::{admonition} Как найти rc-файл
:class: dropdown

Узнайте ваш `shell`

:::console
% echo $SHELL
/bin/zsh
:::

- Если это `zsh`, то файл для настройки {file}`~/.zshrc`.
    - Если файл отсутствует, создайте его `touch ~/.zshrc`.
- Если это `bash`, то файл для настройки {file}`~/.bashrc`.
    - Если файл отсутствует, создайте его `touch ~/.bashrc`.
::::

3\. Добавление `alias` (для `bash` аналогично):

:::console
% open ~/.zshrc
:::

В открывшемся редакторе будет содержимое {file}`~/.zshrc`, добавьте в файл строчку

:::console
alias julia='/Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia'
:::

и сохраните {file}`~/.zshrc`. Далее сделайте завершение настройки.

:::console
% source ~/.zshrc  # изменения вступят в силу (можно также просто перезапустить терминал)
% julia --version  # проверка, всё ли работает
julia version 1.6.2
:::
```

```{admonition} Инструкция для пользователей ОС Windows 10
:class: dropdown

**1. Скачать последнюю версию интерпретатора**

На сайте загрузок {{ urldownload }} найти в таблице свою систему и архитектуру
(скорее всего, подойдет {guilabel}`Windows → 64-bit (installer)`)

**2. Установить интерпретатор**

Следуйте инструкциям установщика. По умолчанию установка идёт в пользовательскую директорию. Если хочется установить в {file}`C:\Program Files`, не забудьте запустить установщик через {guilabel}`ПКМ → Запуск от имени администратора`.

В конце установки отметить галочкой пункт **Add Julia to `PATH`**.

**3. Запуск**

Теперь интерпретатор можно запускать из командной строки командой `julia`.
*Рекомендуется* в качестве командной строки использовать современный {{ wintermdwnld }}.
```

(repl_guide)=
## Интерактивный режим

```{margin}
Это аналогично интерактивному режиму работы в Python.
```
Знакомство языка начнём с интерактивного режима. Для этого необходимо запустить Julia REPL (Read-Evaluate-Print-Loop).

```{margin}
`GNOME Terminal`, `Terminal.app`, `iTerm.app`, `Windows Terminal`, `cmd`...
```
В терминале необходимо набрать команду `julia`

```console
% julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.6.2 (2021-07-14)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia>
```

Строки до `julia>` это приветственное сообщение. Здесь есть ссылка на документацию к языку. Команды для получения помощи и версия релиза.

Julia REPL обладает четыремя режимами работы. Режим отмечается prompt-строкой.

Строка `julia>` это prompt-сообщение в **исполнительном режиме** REPL-а. В нём вы можете исполнять команды языка и переходить в другие режимы.

```julia-repl
julia> println("Hello, world")
Hello, world

julia>
```

Перейти в **режим помощи** по языку можно с помощью {kbd}`?`, при этом prompt-сообщение сменится на `help?>`.

```{margin}
Попробуйте также зайти в режим помощи и нажать {kbd}`↵ Return`.
```
```julia-repl
help?> println
search: println printstyled print sprint isprint

  println([io::IO], xs...)

  Print (using print) xs followed by a newline. If io is not supplied, prints to stdout.

  ...
```

Чтобы выйти из режима помощи, необходимо нажать {kbd}`← Backspace`. *Таким же способом можно вернуться и из других режимов в **исполнительный***.

```{margin}
Для знакомых с Python, `pkg>` сочетает в себе возможности `pip` и `virtualenv`.
```
Третий режим посвящён работе со **сторонними пакетами и окружениями [^pkgenv]**. Команда перехода {kbd}`]`, prompt-сообщение `(@v1.6) pkg>`, попробуйте набрать `help`. Этот режим нам пока не понадобится.

[^pkgenv]: Программный пакет *package* это библиотека кода. Окружение *environment* позволяет исполнить код только с необходимыми пакетами, что уменьшает количество конфликтов версий между ними.

```{margin}
Бывает удобно, но есть особенности.
```
В четвёртом режиме можно работать в терминале, не выходя из Julia REPL. Команда перехода {kbd}`;`, prompt-сообщение `shell>`.

```julia-repl
shell> echo 'Привет, мир!'
Привет, мир!

shell>
```

## Числа и переменные

```{warning}
Данный раздел является *кратким* обзором следующих разделов манула

- Variables **[[url]](https://docs.julialang.org/en/v1/manual/variables/)**;
- Integers and Floating-Point Numbers **[[url]](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/)**;
- Mathematical Operations and Elementary Functions **[[url]](https://docs.julialang.org/en/v1/manual/mathematical-operations/)**;
- Complex and Rational Numbers **[[url]](https://docs.julialang.org/en/v1/manual/complex-and-rational-numbers/)**.
```

В Julia богатая система встроенных числовых типов, узнать тип переменной или литерала можно с помощью функции `typeof(x)`

```julia-repl
julia> typeof(5)
Int64

julia> typeof(5.0)
Float64

julia> typeof(5im)
Complex{Int64}

julia> typeof(2.3 + 5.0im)
ComplexF64 (alias for Complex{Float64})

julia> typeof(2//3)
Rational{Int64}

julia> typeof(1//3 + 2//3im)
Complex{Rational{Int64}}

```

Синтаксис присвоения значения переменной стандартный, также поддерживается параллельное присваивание и каскадное.

```julia-repl
julia> x = 5
5

julia> x, y = 1, 2
(1, 2)

julia> x
1

julia> y
2

julia> x = y = 1
1

julia> x
1

julia> y
1

```

В исполнительном режиме REPL печатает возращаемое значение, его можно опустить с помощью `;` в конце выражения.

```julia-repl
julia> x = 10;

julia> x
10

```

Имена переменных могут быть любыми Unicode символами, REPL позволяет набирать часто употребляемые с помощью LaTeX-подобного синтаксиса и {kbd}`Tab ⇥`, например, так выглядит набор имени `α₁`:

```julia-repl
julia> \alpha  # потом нажмите `<Tab>`, и ввод сменится на α
       α
       α\_1  # `<Tab>`
       α₁
```

Ниже в таблице перечислены некоторы арифметические, алгебраические и тригонометрические операторы и функции

```{list-table}
:header-rows: 1

* - Описание
  - Синтаксис
* - Бинарные `+`, `-`, `*`, `/`
  - `x + y`, `x - y`, `x * y`, `x / y`
* - Умножение на константу ([сахар](https://ru.wikipedia.org/wiki/%D0%A1%D0%B8%D0%BD%D1%82%D0%B0%D0%BA%D1%81%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B9_%D1%81%D0%B0%D1%85%D0%B0%D1%80))
  - `<num>x`, например `2.5x`
* - Унарный минус
  - `-x`
* - Частное от деления целых
  - `x ÷ y` или `div(x, y)`
* - Остаток от деления целых (также см. `divrem`)
  - `x % y` или `rem(x, y)`
* - Возведение в степень
  - `x ^ y`
* - Логарифмы $\ln(x)$, $\log_2(x)$, $\log_{10}(x)$
  - `log(x)`, `log2(x)`, `log10(x)`
* - Тригонометрия $\sin(x)$, $\cos(x)$
  - `sin(x)`, `cos(x)`
* - Квадратный корень $\sqrt{x}$
  - `sqrt(x)` или `√x`
```

Стоит отметить, что (кажется, все) функции из таблицы определены для всех типов, перечисленных выше, но, иногда требуется аргумент подать в явном типе

```julia-repl
julia> sqrt(-1.0)
ERROR: DomainError with -1.0:
sqrt will only return a complex result if called with a complex argument. Try sqrt(Complex(x)).
...

julia> sqrt(-1.0 + 0im)
0.0 + 1.0im

```

```{admonition} Почему?
:class: dropdown

Такое поведение языка задано по двум причинам.

Во-первых, функция корня в математике определяется на разных множествах.

Во-вторых, так удаётся сохранять *стабильность типов*. Если бы функция корня извлекая из `Float64`, возвращала иногда `Float64`, а иногда `Complex{Float64}`, то предсказать тип возвращаемого значения было бы невозможно. Предсказание типов позволяет *компилировать* участки исходного кода, не уступающие по скорости аналогам кода на статически типизируемых языках, например, `C/C++`.
```

Математические константы

```julia-repl
julia> π                    # \pi<Tab>
π = 3.1415926535897...

julia> ℯ                    # \euler<Tab>
ℯ = 2.7182818284590...

julia> typeof(ℯ)
Irrational{:ℯ}

```

При применении операций к разным типам тип результата интуитивен: число из типа, соответствующего, математически "меньшему" множеству конвертируется в тип математически "большего" множества. Затем операция выполняется для одинаковых типов. Система типов в Julia это её позвоночник, см. раздел {ref}`type_system`.

```{margin}
Однако, стоит избегать и потенциально предугадывать места, в которых переменная меняет свой тип. Компилятор вас поощрит.
```
В Julia **динамическая** типизация. Переменная может менять свой тип в процессе работы программы

```julia-repl
julia> x = 5
5

julia> typeof(x)
Int64

julia> x  = 5.0
5.0

julia> typeof(x)
Float64
```

В Julia нельзя указать, чтобы переменная имела постоянное значение, но можно указать, что переменная *не меняет свой тип*

```julia-repl
julia> const y = 10
10

julia> y = 10.0
ERROR: invalid redefinition of constant y
Stacktrace:
 [1] top-level scope
   @ REPL[6]:1

julia> y = 20
WARNING: redefinition of constant y. This may fail, cause incorrect answers, or produce other errors.
20
```

Заметьте, Julia не допустила присвоение `y = 10.0`, потому что оно меняет тип переменной `y::Int64`. Однако, присваивать значения `Int64` переменной `y` можно, Julia лишь *предупредит*, но не запретит.

## Строки

В Julia богатая поддержка работы с текстом, встроенные текстовые типы работают с Unicode.

Тип `Char` используется для работы с отдельными символами, его литерал две одинарные кавычки `'`

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

Тип `String` предназначен для строк, его литерал двойные кавычки `"`

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

Escape специальных символов производится привычным `\`, например `"\n"`, `"\t"`.

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
```

```{tip}
Подробнее о строках в мануале **[[url]](https://docs.julialang.org/en/v1/manual/strings/)**.
```

## Функции

Основной синтаксис для функций в Julia

```julia-repl
julia> function f(x, y)
           return sqrt(x^2 + y^2)
       end
f (generic function with 1 method)
```

Строго говоря, слово `return` необязательно, функция в Julia возвращает результат последнего выражения, однако, мы будем придерживаться [![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle).

В теле функции может находится несколько слов `return`, в этом случае при вызове сработает только одно из них.
Если необходимо, чтобы функция ничего не возвращала, тогда используется `return nothing`.

Зачастую пригождается более краткий синтаксис создания функции (*assignment form*)

```julia-repl
julia> f(x, y) = sqrt(x^2 + y^2)
f (generic function with 1 method)
```

В этом случае справа от `=` может находиться составное выражение (*compound expression*) `begin-end`.

```julia-repl
julia> g(x, y) = begin              # или g(x, y) = begin z = f(x, y); return 2*z end
           z = f(x, y)
           return 2*z
       end
g (generic function with 1 method)
```

Синтаксис вызова интуитивен

```julia-repl
julia> f(3, 4)
5.0

julia> g(3, 4)
10.0
```

В Julia аргументы передаются по принципу *pass-by-sharing*. Т.е. аргументы функции внутри тела ведут себя как новые переменные. Однако, у изменяемых *mutable* аргументов (например, массив), можно поменять значения, и они будут видны извне. По соглашению, если функция меняет свой аргумент, то в её имя добавляется `!` в конце, например, `map!(f, A, B)`, `push!(A, a)`.

Функции являются **first-class** объектами. Ими можно "распоряжаться", как переменными: присваивать их другим переменным, передавать как аргумент... 

```julia-repl
julia> φ = f;

julia> φ(3, 4)
5.0
```

Важно, что операторы в Julia также являются функциями

```julia-repl
julia> +(1, 2, 3) == 1 + 2 + 3
true
```

Языковые конструкции, вроде доступа к элементу массива (`A[i]`) или полю структуры (`S.x`) также являются операторами, а следовательно, и функциями.

Можно создавать анонимные функции

```julia-repl
julia> x -> 2x                        # короткий синтаксис
#1 (generic function with 1 method)

julia> f4 = x -> 2x                   # анонимная функция x -> 2x присвоена переменной f4
#3 (generic function with 1 method)

julia> f4(8)
16

julia> function (x)                   # длинный синтаксис
           return 3x
       end
#5 (generic function with 1 method)

julia> map(x -> 3x, 1:4)              # пример применения
4-element Vector{Int64}:              # map здесь создает массив
  3                                   # из утроенных значений
  6                                   # арифм. прогрессии от 1 до 4
  9
 12
```

В Julia тип, соответствующий аргументам функции, является кортежем `Tuple`. Кортеж неизменная коллекция.

```julia-repl
julia> tup = (3, 4)
(3, 4)

julia> tup[1]
3

julia> (3,)  # tuple из одного значения
(3,)
```

Функция, конечно, может и возращать `Tuple`, т.е. возвращать несколько значений. Если абстрагироваться, функция в Julia создаёт из одного кортежа значений другой кортеж.

```julia-repl
julia> function addmul(x, y)
           return x + y, x * y
       end
addmul (generic function with 1 method)

julia> a, b = addmul(3, 4)
(7, 12)

julia> a
7

julia> b
12
```

Также существует именованный кортеж `NamedTuple`, хранящий пары ключ-значение. На его основе создаются функции, принимающие аргументы по ключу.

```{tip}
Больше информации в мануале **[[url]](https://docs.julialang.org/en/v1/manual/functions/)**.
```

## Управляющие конструкции

```{tip}
Подробнее в мануале **[[url]](https://docs.julialang.org/en/v1/manual/control-flow/)**.
Здесь освещены не все конструкции и не так подробно.
```

### Составные выражения

C двумя управляющими конструкциями мы уже встретились, это `begin`-блоки и `;`-цепочки.

Блок `begin-end` позволяет объединять несколько выражений в одно, составное выражение (*compound expression*).

```julia-repl
julia> z = begin
           x = 1
           y = 2
           x + y
       end
3
```

С помощью `;` можно поместить несколько выражений на одной строке, что часто используется для коротких составных выражений.

```julia-repl
julia> z = (x = 1; y = 2; x + y)
3

julia> z = begin x = 1; y = 2; x + y end
3
```

### Условное исполнение

Синтаксис `if-elseif-else` блока

```julia-repl
julia> x = 10; y = 20;

julia> if x < y
           println("x is less than y")
       elseif x > y
           println("x is greater than y")
       else
           println("x is equal to y")
       end
x is less than y
```

В `if` и `elseif` должно стоять boolean выражение.
За это отвечает тип `Bool`, имеющий два значения: `true` и `false`.
Основные операторы сравнения можете посмотреть здесь **[[url]](https://docs.julialang.org/en/v1/manual/mathematical-operations/#Numeric-Comparisons)**.

Количество `elseif` не ограничено.

```{margin}
Раз есть тип `Nothing`, есть и `Something`!
```
Блок `if-elseif-else` подобно `begin-end` возвращает значение. В примере выше возвращается `nothing`, который вернулся от вызова `println("x is less than y")`. Значение `nothing` не печатается в языке и является абстракцией отсутствия какого-либо значения.

Также в вашем распоряжении тернарный оператор

```julia
x = cond ? a : b
```

### Циклы

Julia предоставляет два цикла: `while` и `for`.

```julia-repl
julia> i = 1;

julia> while i <= 5
           println(i)
           global i += 1
       end
1
2
3
4
5
```

Наличие слова `global` связано с созданием циклом `while` собственного пространства видимости (*variable scope*). В REPL это значения не имеет, поскольку в нём глобальное пространство. А вот в скриптах вы получите ошибку. Попробуйте запустить в REPL `include_string(Main, "i = 1; while i < 2; i += 1; end")`.

У цикла `for` следующий синтаксис

```julia
for item in iterator
    ...
end
```

Переменная цикла `item` создаётся внутри видимости цикла `for` автоматически. После исполнения цикла она недоступна, если не была объявлена во внешней области видимости.

```julia-repl
julia> for j in 1:3
           println(j)
       end
1
2
3

julia> j
ERROR: UndefVarError: j not defined
```

Здесь использован *range operator* `start:stop`

```julia-repl
help?> 1:3
  (:)(start, [step], stop)

  Range operator. a:b constructs a range from a to b with a step size of 1 (a UnitRange),
  and a:s:b is similar but uses a step size of s(a StepRange).
```

Итерировать можно и по коллекциям. Ниже пример для `Tuple`

```julia-repl
julia> for j in (1, 2, "hello")
           println(j)
       end
1
2
hello
```

(type_system)=
## Система типов

В Julia **сильная динамическая** система типов, являющаяся центральной темой языка наряду с методами.

```{tip}
Подробнее, как всегда, в мануале к языку **[[url]](https://docs.julialang.org/en/v1/manual/types/)**.
```

### Декларация типов

С помощью оператора `::` вы можете *декларировать* тип объекта. Обычно это делается для

- переменных;
- аргументов функции;
- возвращаемоего значения функцией;
- полей композитных типов (структур).

```{margin}
Конвертацию делает функция `convert(T, x)`. Правила конвертации можно задавать.
```
Например, вы можете декларировать тип переменной внутри функции (или другой локальной области видимости). В таком случае при присвоении значения происходит конвертация.

```julia-repl
julia> function foo()
           x::Int8 = 100
           return x
       end
foo (generic function with 1 method)

julia> x = foo()
100

julia> typeof(x)
Int8

julia> typeof(100)
Int64
```

Также вы можете декларировать тип возвращаемого значения функцией (хотя, делается это редко)

```julia-repl
julia> bar()::Int8 = 100
bar (generic function with 1 method)

julia> bar()
100

julia> typeof(bar())
Int8
```

### Какие бывают типы

Типы в Julia классифицируются по следующим признакам (указаны не все)

- абстрактный *abstract* (`AbstractFloat`) и конкретный *concrete* (`Float64`);
- примитивный *primitive* (`Float64`) и композитный *composite* (`Complex{Float64}`);
- параметрический *parametric* (`Complex{Float64}`);
- изменяемый (`Vector{Float64}`) и неизменяемый (`Tuple{Float64,Float64}`);
- ...

В Julia система типов является деревом, корень которого тип `Any`. Листьями дерева типов являются **конкретные типы**. У значения такого типа известна структура в памяти. **Абстрактные** типы нужны в качестве промежуточных узлов дерева типов.

```{note}
:class: dropdown

Кроме того, объявление неабстрактного параметрического типа `T1{T2}`  создаёт **UnionAll** тип `T1`. Последний ведёт себя как супертип для параметризованных потомков. Например, `Rational{T}` порождает UnionAll `Rational`, и `Rational` будет супертипом для всех `Rational{T}`: `Rational{Int64}`, `Rational{Int8}`...

В дереве ниже UnionAll типы помещены в параллелограммы.
```

Например, так выглядит часть дерева с числовыми и строчными типами, при этом

- конкретные типы указаны в округлённых рамках;
- абстрактные в прямоугольных.

```{mermaid}
flowchart TB
    Any --> Number --> Real --> Integer
    Any --> AbstractString --> String([String])
            AbstractString --> SubString[/SubString/]
    Number --> Complex[/Complex/]
    Real --> AbstractFloat
    Real --> Rational[/Rational/]
    Rational --> RationalInt64(["Rational{Int64}"])
    Rational --> RationalInt32(["Rational{Int32}"])
    Integer --> Int64([Int64])
    Integer --> Int32([Int32])
    Integer --> Int16([Int16])
    Integer --> Int8([Int8])
```

Несколько функций для интроспекции системы типов

- `subtypes(T)`: подтипы типа `T`;
- `isabstracttype(T)`: является ли тип `T` абстрактным;
- `isprimitivetype(T)`: является ли тип `T` примитивным;
- `ismutable(x)`: является ли значение `x` изменяемым.

```{margin}
С точки зрения дерева, можно ли из `Ty` добраться до `Tx`.
```
Также с помощью subtype-оператора `Tx <: Ty` можно проверять "является ли тип `Tx` подтипом типа `Ty`".

```julia-repl
julia> Int64 <: Number
true
```

**Примитивные** типы представляются в виде набора бит. Такими примерами являются Int-ы и Float-ы.

```{note}
Создание собственных абстрактных и примитивных типов здесь не разбирается.
```

(julia_composite)=
### Композитные типы

**Композитный** тип имеет более сложную структуру в памяти. Этот тип является набором именнованных полей, а экземпляром такого типа можно манипулирвовать как одним значением. В других языках им соответствуют объекты (*objects*) или структуры (*structs*). Примерами встроенных композитых типов являются `Tuple`, `String`, `Array`, `IO`...

Классический пример &ndash; структура для точки в пространстве.

```julia-repl
julia> struct Point
           x
           y::Int64       # так указывается тип (можно и абстрактный)
       end

julia> p1 = Point(1.0, 2)
Point(1.0, 2)

julia> typeof(p1)
Point

julia> p1.x
1.0

julia> p1.x = 9
ERROR: setfield! immutable struct of type Point cannot be changed
...
```

Присвоение можно разрешить, сделав структуру `mutable`

```julia-repl
julia> mutable struct MPoint
           x
           y
       end

julia> mp1 = MPoint(1, 2)
MPoint(1, 2)

julia> mp1.x = 10
10

julia> mp1
MPoint(10, 2)
```

Иногда это может приводить к замедлению работы, поскольку `mutable struct` выделяется в куче, а не на стеке.

Тем не менее, в поле обычной структуры можно хранить значение изменяемого типа. В таком случае поле хранит *ссылку на изменяемый объект*. Объект поменять можно, а ссылку &ndash; нет.

Конструктор (*constructor*) `Point(x, y)` для композитного типа можно поменять. Более того, можно создать несколько конструкторов.

### Параметрические композитные типы

```{margin}
Абстрактные параметрические типы тоже существуют.
```
**Параметрический** тип это тип, который в своём объявлении содержит дополнительную информацию. Например, тип `Complex` в языке объявлен следующим образом **[[source]](https://github.com/JuliaLang/julia/blob/1326e4b00e6f27a4120c30eb12b578a6cee28039/base/complex.jl#L3)**

```julia
struct Complex{T<:Real} <: Number
    re::T
    im::T
end
```

Это объявление значит

```{margin}
`Complex` в данном случае ни абстрактный, ни конкретный.
```
- создать UnionAll-тип `Complex`, который будет вести себя как супертип для `Complex{T}`;
- создать параметрический тип `Complex{T}`,
- где параметр `T` является подтипом типа `Real`,
- при этом типы `Complex` и `Complex{T}` являются подтипами `Number`;
- у `Complex{T}` два поля: `re` и `im`, каждое из них имеет тип `T`.

```{margin}
Это не значит, что массив в Julia может хранить только значения одного типа. Ведь есть абстрактные типы: `Any`, `Number`...
```
В качестве параметров могут быть типы и значения примитивных типов. Например в Julia объявлен тип для массивов ` AbstractArray{T,N}`, где под `T` подразумевается тип значений, а под `N` размерность.

Параметрические типы порождают целое семейство типов. Член такого семейства &ndash; *любая  комбинация разрешенных значений* параметров типа.

Таким образом, с помощью параметризации композитного типа мы можем дать подсказки для компилятора, чтобы тот создавал оптимизированный код.

#### Пример оптимизации

Рассмотрим две версии `Point`

```julia-repl
julia> struct APoint
           x
           y
       end

julia> struct TPoint{T}
           x::T
           y::T
       end
```

Создадим функцию, вычисляющую расстояние от точки до начала координат

```julia-repl
julia> dist(p) = sqrt(p.x^2 + p.y^2)
dist (generic function with 1 method)
```

Заметьте, в этой функции нет никаких ограничений на тип `p`.

Создадим два массива случайных точек

```julia-repl
julia> AA = [APoint(rand(2)...) for _ in 1:1_000_000];

julia> TA = [TPoint(rand(2)...) for _ in 1:1_000_000];

julia> typeof(AA), typeof(TA)
(Vector{APoint}, Vector{TPoint{Float64}})
```

Про массив `TA` компилятор явно знает больше, судя по `typeof`.

Измерим время работы (в первые запуски вмешивается компиляция)

```julia-repl
julia> @time dist.(AA);
  0.138012 seconds (5.00 M allocations: 84.154 MiB, 6.08% gc time, 7.93% compilation time)

julia> @time dist.(AA);
  0.141266 seconds (5.00 M allocations: 83.916 MiB, 13.38% gc time)

julia> julia> @time dist.(TA);
  0.029862 seconds (8.17 k allocations: 8.015 MiB, 29.57% gc time, 63.13% compilation time)

julia> @time dist.(TA);
  0.001816 seconds (4 allocations: 7.630 MiB)
```

Точный бенчмарк также показывает разницу времени работы в два порядка

```julia-repl
julia> using BenchmarkTools

julia> @btime dist.(AA);
  117.766 ms (4999502 allocations: 83.92 MiB)

julia> @btime dist.(TA);
  1.290 ms (5 allocations: 7.63 MiB)
```

```{tip}
:class: dropdown

Поисследовать, может ли компилятор предугадать типы в теле вызова можно с помощью макроса `@code_warntype`

:::julia-repl
julia> @code_warntype dist(APoint(1, 2))
Variables
  #self#::Core.Const(dist)
  p::APoint

Body::Any
1 ─ %1  = Base.getproperty(p, :x)::Any
│   %2  = Core.apply_type(Base.Val, 2)::Core.Const(Val{2})
│   %3  = (%2)()::Core.Const(Val{2}())
│   %4  = Base.literal_pow(Main.:^, %1, %3)::Any
│   %5  = Base.getproperty(p, :y)::Any
│   %6  = Core.apply_type(Base.Val, 2)::Core.Const(Val{2})
│   %7  = (%6)()::Core.Const(Val{2}())
│   %8  = Base.literal_pow(Main.:^, %5, %7)::Any
│   %9  = (%4 + %8)::Any
│   %10 = Main.sqrt(%9)::Any
└──       return %10

julia> @code_warntype dist(TPoint(1, 2))
Variables
  #self#::Core.Const(dist)
  p::TPoint{Int64}

Body::Float64
1 ─ %1  = Base.getproperty(p, :x)::Int64
│   %2  = Core.apply_type(Base.Val, 2)::Core.Const(Val{2})
│   %3  = (%2)()::Core.Const(Val{2}())
│   %4  = Base.literal_pow(Main.:^, %1, %3)::Int64
│   %5  = Base.getproperty(p, :y)::Int64
│   %6  = Core.apply_type(Base.Val, 2)::Core.Const(Val{2})
│   %7  = (%6)()::Core.Const(Val{2}())
│   %8  = Base.literal_pow(Main.:^, %5, %7)::Int64
│   %9  = (%4 + %8)::Int64
│   %10 = Main.sqrt(%9)::Float64
└──       return %10
:::
```

## Методы и multiple dispatch

Для каждой функции в Julia можно определить сколько угодно методов (*methods*). Это способ полиформизма в языке. Вы уже с ним сталкивались, например, `1 + 2` и `1.0 + 2.0` совершенно разные вызовы. В первом случае вызывается метод `+(x, y)` для  `Int64`, а во втором метод `+(x, y)` для сложения `Float64`.

У сложения `+` в Julia 190 методов

```julia-repl
julia> methods(+)
# 190 methods for generic function "+":
[1] +(x::T, y::T) where T<:Union{Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8} in Base at int.jl:87
[2] +(c::Union{UInt16, UInt32, UInt64, UInt8}, x::BigInt) in Base.GMP at gmp.jl:528
[3] +(c::Union{Int16, Int32, Int64, Int8}, x::BigInt) in Base.GMP at gmp.jl:534
...

julia> @which 1 + 2
+(x::T, y::T) where T<:Union{Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8} in Base at int.jl:87

julia> @which 1.0 + 2.0
+(x::Float64, y::Float64) in Base at float.jl:326

julia> @which 1.0 + 2
+(x::Number, y::Number) in Base at promotion.jl:321
```

Процесс выбора нужного метода называется **диспетчеризацией** (*dispatch*). В Julia диспетчеризация производится **по типам *всех* позиционных аргументов функции**. Этот механизм называется *multiple dispatch*. Он гибче и продуктивнее, нежели диспетчеризация по одному типу, например, как в Python (`type(x).__add__(x, y)`).

Строго говоря, *generic function* единственна, а методов у неё много. Однако, всё же принято называть методы функциями, если контекст позволяет.

Методы создаются как функции, но с указанием типа хотя бы одного аргумента.

```julia-repl
julia> f(x, y) = 2x + y
f (generic function with 1 method)

julia> f(x::Float64, y::Float64) = 3x + y
f (generic function with 2 methods)
```

Здесь же посмотрим на диспетчеризацию
```julia-repl
julia> f(1, 1)
3

julia> f(1.0, 1.0)  # два Float64, подходит f(x::Float64, y::Float64)
4.0

julia> f(1.0, 1)    # Float64 и Int64, подходит лучше f(x, y)
3.0
```

Конечно, использование не конкретных типов разрешено

```julia-repl
julia> f(x::Complex, y::Complex) = 5x + y*im
f (generic function with 3 methods)

julia> f(1.5im, 2.5im)
-2.5 + 7.5im

julia> f(1.5im, 2.5)
2.5 + 3.0im
```

При диспетчеризации может возникать коллизия: два или более метода подходят для вызова. В этом случае Julia выдаст ошибку `MethodError`.

На методах основаны интерфейсы в языке. Например, вы можете создавать собственные структуры данных, у которых будет поведение массивов. Как только вы создадите методы интерфейса для своего типа, вы сможете пользоваться всеми функциями, определенными для `AbstractArray{T,N}`. Или, скажем, вы можете встроить свои структуры данных в интерфейс цикла `for`.

Помимо этого, методы могут быть параметрическими, и в их теле вам будет доступен тип аргумента *без вызова* `typeof(x)`, т.е. на этапе компиляции, а не в runtime.

С помощью методов также создаются типы, ведущие себя как функции: их можно вызывать (*callable*). На этом основаны замыкания (*closures*) в Julia.

```{tip}
Изобретено множество дизайн-паттернов с использованием методов и типов. За подробностями по теме методов обращайтесь в мануал **[[url]](https://docs.julialang.org/en/v1/manual/methods/)**.
```

## Линейная алгебра
% броадкаст

## Модули
