# Модули

```{tip}
Подробнее в секции мануала [Modules](https://docs.julialang.org/en/v1/manual/modules/).
```

В Julia можно разбивать исходный код программы на модули (*modules*). Модуль создаёт собственное пространство имён и может быть прекомпилирован.

Основной синтаксис выглядит так.

```julia
module Points

using LinearAlgebra

export dist, Point

include("types.jl")
include("functions.jl")

private_foo() = println("Hello!")

end # module
```

Всё, что между командами `module ... end` представляет собой модуль.
В данном примере создаётся модуль `Points`. 

Инструкция `using LinearAlgebra` импортирует публичные имена из модуля `LinearAlgebra`.
При таком вызове, например, функция `LinearAlgebra.norm` из модуля доступна просто по имени `norm`.
Фактически, программист так указывает зависимости модуля `Points` от других модулей.

Модуль `Points` также делает имена `dist` и `Point` публичными. Т.е., когда кто-нибудь импортирует `Points` командой `using`, то ему будут доступны имена `dist` и `Point`. Точно также где-то в исходном коде модуля `LinearAlgebra` происходит экспорт имени `norm`.

Функция `include("<path_to_file>")` делает подстановку содержимого файла в модуль.
В Julia позднее связывание имён, поэтому вы можете спокойно экспортировать что-то, а объявить где-то позднее.

**Как импортировать свой модуль?**

Если модуль `Points` помещён в файл `myscripts/Points.jl`, то можно импортировать модуль так
```julia
include("myscripts/Points.jl")  # В общем случае полный путь до файла с исходным кодом модуля
using .Points

@show dist(Point(1, 2))
```
Здесь функцией `include` совершается подстановка содержимого файла с модулем, как будто бы мы его скопировали сюда.
Затем используется `using .Points` -- заметьте точку.
По умолчанию Julia ищет модули (а точнее, пакет) в текущем окружении.
Глобальное окружение вы можете посмотреть в REPL командой `] status` -- она покажет список установленных пакетов (но не покажет стандартные библиотеки).
В нашем случае пакет не создавался и регистрировался в глобальном окружении, поэтому команда `using Points` привела бы к ошибке.
Но, с помощью `.` поиск модуля осуществляется относительно скрипта, а не окружения.
Кроме того, есть `..` для обращения к родительскому модулю.


**using и import**

Для импортирования существуют инструкции `using` и `import`.
Их главное отличие в назначении.

Инструкция `using` предназначена для использования кода модуля *пользователем*.
Например, `using LinearAlgebra` позволяет нам, как пользователям модуля `LinearAlgebra`, использовать функции `norm`, `cross`...

Инструкция `import` отличается от `using` тем, что позволяет переопределять и создавать новые методы для функций, определённых в импортированном модуле.
Другими словами, `import` для разработчиков.
Например, чтобы добавить метод скалярного произведения для собственного типа данных, придётся воспользоваться `import LinearAlgebra`.

**Что импортируется, а что нет**

Можно импортировать только некоторый функционал модуля, для этого используется двоеточие `:`.
Можно переименовывать импортируемые имена с помощью `as`.
В таблице ниже показано, какие имена доступны при использовании разных вариантов `using` и `import`.

```{list-table}
:header-rows: 1

* - Команда импорта
  - Какие имена доступны
* - `using Points`
  - `Points`, и публичные `dist`, `Point`, остальные через точку: `Points.private_foo`
* - `using Points: dist`
  - Только `dist`
* - `using Points: dist as d`
  - Только `d`
* - `import Points`
  - `Points`, остальные через точку
* - `import Points as Pnts`
  - `Pnts`, остальные через точку
```

## Пример разработки модуля

Ниже показана разработка модуля в несколько этапов. В нём привычная структура `Point{T}`, а её интерфейс оборачивается в модуль. Затем, для примера, структура встраивается в существующую экосистему языка: можно скалярно умножать точки, складывать или умножать на скаляр.

::::{tab-set}

:::{tab-item} Базовая разработка

{file}`Points.jl`

```julia
module Points

export dist
export Point

struct Point{T}
    x::T
    y::T
end

dist(p::Point) = sqrt(p.x^2 + p.y^2)
random_point() = Point(rand(2)...)

end # module
```

{file}`script.jl`

```julia
include("path/to/Points.jl")
using .Points

println(dist(Point(3, 4)))
println(Points.random_point())
```
:::

:::{tab-item} Скалярное произведение

{file}`Points.jl`

```julia
module Points

import LinearAlgebra  # для добавления метода к скалярному произведению

export dist
export Point

struct Point{T}
    x::T
    y::T
end

dist(p::Point) = sqrt(p.x^2 + p.y^2)
random_point() = Point(rand(2)...)

# Добавление метода к скалярному произведению LinearAlgebra.dot
LinearAlgebra.dot(p1::Point, p2::Point) = p1.x * p2.x + p1.y * p2.y

end # module
```

{file}`script.jl`

```julia
include("path/to/Points.jl")
using .Points
using LinearAlbgebra  # Для dot(x, y)

println(dot(Point(-1, 2), Point(-2, -3)))
```
:::

:::{tab-item} Линейные операции

{file}`Points.jl`

```julia
module Points

import LinearAlgebra

export dist
export Point

struct Point{T}
    x::T
    y::T
end

dist(p::Point) = sqrt(p.x^2 + p.y^2)
random_point() = Point(rand(2)...)

LinearAlgebra.dot(p1::Point, p2::Point) = p1.x * p2.x + p1.y * p2.y

# Расширяение стандартной библиотеки языка, модуля Base
# `+` коммутативно
Base.:+(p1::Point, p2::Point) = Point(p1.x + p2.x, p1.y + p2.y)
# `*` не коммутативно
Base.:*(α::Number, p::Point) = Point(α * p.x, α * p.y)
Base.:*(p::Point, α::Number) = α * p

end # module
```


{file}`script.jl`
```julia
include("path/to/Points.jl")
using .Points

println(Point(1, 2) + Point(3.0, 4.1))
println(2 * Point(1, 2))
println(Point(1, 2) * 2.0)
```
:::
::::

**Разбиение исходного кода на файлы**

Когда исходный код разрастается, его разбивают на отдельные файлы.
Для библиотеки кода в Julia типично наличие корневого файла, в котором объявлен модуль, зависимости от других библиотек и экспортируемые имена, а оставшийся код библиотеки подставлятся с помощью `include`.
Весь код библиотеки помещают в директорию `src`, а корневой файл называют также, как и главный модуль библиотеки.

```{margin}
От реальной структуры отличается только отстутсвием файла с зависимостями пакета.
```
Ниже показана типичная структура исходного когда библиотеки.

::::{grid} 2

:::{grid-item-card} Структура библиотеки и {file}`Points.jl`

Структура директории.
```
src/
  operators.jl
  interface.jl
  types.jl
  Points.jl
```

Код модуля {file}`src/Points.jl`.

```julia
module Points

import LinearAlgebra

export dist
export Point

include("types.jl")
include("interface.jl")
include("operators.jl")

end # module
```

:::

:::{grid-item-card} Остальной код

{file}`src/types.jl`
```julia
struct Point{T}
    x::T
    y::T
end
```

{file}`src/interface.jl`

```julia
dist(p::Point) = sqrt(p.x^2 + p.y^2)
random_point() = Point(rand(2)...)
```

{file}`src/operators.jl`

```julia
LinearAlgebra.dot(p1::Point, p2::Point) = p1.x * p2.x + p1.y * p2.y

Base.:+(p1::Point, p2::Point) = Point(p1.x + p2.x, p1.y + p2.y)

Base.:*(α::Number, p::Point) = Point(α * p.x, α * p.y)
Base.:*(p::Point, α::Number) = α * p
```
:::
::::
