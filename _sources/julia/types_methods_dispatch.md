# Типы, методы и multiple dispatch

В Julia типы упорядочены в *дерево*, образуя систему. В этом дереве есть самые разные ветви: для числовых типов, строковых, массивов... В свою очередь, для функции можно написать любое количество *методов*, указывая в объявлении метода при каком наборе типов аргументов, или даже целых ветвей, он будет вызываться. Процесс выбора метода для функции называется *диспетчеризацией*. При этом Julia, если возможно, создаёт эффективную (машинную) реализацию используемых методов.

Эти три инструмента: дерево типов, методы и диспетчеризация, являются ядром дизайна Julia, дающим гибкость в написании кода вообще и быстрого кода в частности.

Подробнее о рассматриваемых здесь темах можно почитать в разделах [Types](https://docs.julialang.org/en/v1/manual/types/), [Methods](https://docs.julialang.org/en/v1/manual/methods/) и [wiki:Multiple dispatch](https://en.wikipedia.org/wiki/Multiple_dispatch#Languages_with_built-in_multiple_dispatch).

(type_system)=
## Система типов

В Julia **сильная динамическая** система типов.

:::{margin}
Однако, стоит избегать и потенциально предугадывать места, в которых переменная меняет свой тип. Компилятор вас поощрит.
:::
Поскольку в Julia динамическая типизация, то переменная может менять свой тип в процессе работы программы.

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

Julia не допустила присвоение `y = 10.0`, потому что оно меняет тип переменной `y::Int64`. Однако, присваивать значения `Int64` переменной `y` всё-таки можно, но не стоит этого делать.

### Декларация типов

С помощью оператора `::` вы можете *декларировать* тип объекта. Обычно это делается для

- переменных;
- аргументов функции;
- возвращаемого функцией значения;
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

Также вы можете декларировать тип возвращаемого значения функцией (хотя, делается это редко, поскольку компилятор выводит типы, если возможно).

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

В Julia система типов является деревом, корень которого тип `Any`. Листьями дерева типов являются **конкретные типы**. У значения такого типа известна структура в памяти. **Абстрактные** типы нужны в качестве промежуточных узлов дерева типов, выстраивая иерархию.

```{note}
:class: dropdown

Кроме того, объявление неабстрактного параметрического типа `T1{T2}`  создаёт **UnionAll** тип `T1`. Последний ведёт себя как супертип (родительский) для параметризованных потомков.

Например, `Rational{T}` порождает UnionAll `Rational`, и `Rational` будет супертипом для всех `Rational{T}`: `Rational{Int64}`, `Rational{Int8}`...

В дереве ниже `UnionAll` типы помещены в параллелограммы.
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

**Примитивные** типы представляются в виде набора бит. Примерами являются `Int`-ы и `Float`-ы.

```{note}
Создание собственных абстрактных и примитивных типов здесь не разбирается.
```

(julia_composite)=
### Композитные типы

**Композитный** тип имеет более сложную структуру в памяти, чем примитивный тип. Этот тип является набором именованных полей, а экземпляром такого типа можно манипулирвовать как одним значением. В других языках им соответствуют объекты (*objects*) или структуры (*structs*). Примерами встроенных композитых типов являются `Complex{T}`, `Rational{T}`, `Tuple`, `String`, `Array`, `IO`...

Классический пример &ndash; структура для точки на плоскости.

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

Присвоение можно разрешить, сделав структуру изменяемой (`mutable`).

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

Тем не менее, в поле обычной структуры можно хранить значение изменяемого типа. В таком случае поле хранит *ссылку на изменяемый объект*. Объект поменять можно, а ссылку &ndash; нет. Например, так хранятся массивы внутри структур.

Конструктор (*constructor*) `Point(x, y)` для композитного типа можно поменять. Более того, можно создать несколько конструкторов.

### Параметрические композитные типы

```{margin}
Абстрактные параметрические типы тоже существуют.
```
**Параметрический** тип это тип, который в своём объявлении содержит дополнительную информацию. Например, тип `Complex` в языке объявлен следующим образом **[[source]](https://github.com/JuliaLang/julia/blob/1326e4b00e6f27a4120c30eb12b578a6cee28039/base/complex.jl#L3)**.

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
В качестве параметров могут быть типы и значения примитивных типов. Например, в Julia объявлен тип для массивов ` AbstractArray{T,N}`, где под `T` подразумевается тип значений, а под `N` размерность массива (1 для векторов, 2 для матриц...).

Параметрические типы порождают целое семейство типов. Член такого семейства &ndash; *любая  комбинация разрешенных значений* параметров типа.

Таким образом, с помощью параметризации композитного типа мы можем дать подсказки для компилятора, чтобы тот создавал оптимизированный код.

#### Пример

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

Измерим время работы. Точный бенчмарк показывает разницу времени работы в два порядка.

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

У сложения `+` в Julia 1.6.2 190 методов.

```julia-repl
julia> methods(+)
# 190 methods for generic function "+":
[1] +(x::T, y::T) where T<:Union{Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8} in Base at int.jl:87
[2] +(c::Union{UInt16, UInt32, UInt64, UInt8}, x::BigInt) in Base.GMP at gmp.jl:528
[3] +(c::Union{Int16, Int32, Int64, Int8}, x::BigInt) in Base.GMP at gmp.jl:534
...
```

Узнать, какой метод вызвался можно макросом `@which`.

```julia-repl
julia> @which 1 + 2
+(x::T, y::T) where T<:Union{Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8} in Base at int.jl:87

julia> @which 1.0 + 2.0
+(x::Float64, y::Float64) in Base at float.jl:326

julia> @which 1.0 + 2
+(x::Number, y::Number) in Base at promotion.jl:321
```

Можно сказать, что функция определяет дефолтное действие с аргументами. А методы функции содержат частные реализации этих действий на случаи тех или иных аргументов. Например, метод `sum` для вектора сложит все элементы и это займёт линейное время, а `sum` для арифметической прогрессии займёт константное время, используя формулу. При этом с точки зрения пользователя сигнатура вызова одна и та же: `sum(A)`.

Процесс выбора нужного метода называется **диспетчеризацией** (*dispatch*). В Julia диспетчеризация производится **по типам *всех* позиционных аргументов функции**. Этот механизм называется *multiple dispatch*. Он гибче и продуктивнее, нежели диспетчеризация по одному типу, например, как в Python (`type(x).__add__(x, y)`). При этом, в отличие от языков со статической типизацией, нет необходимости указывать типы аргументов.

Строго говоря, *generic function* единственна, а методов у неё много. Однако, всё же принято называть методы функциями, если контекст позволяет.

Методы создаются как функции, но с указанием типа хотя бы одного аргумента.

```julia-repl
julia> f(x, y) = 2x + y
f (generic function with 1 method)

julia> f(x::Float64, y::Float64) = 3x + y
f (generic function with 2 methods)

julia> methods(f)
# 2 methods for generic function "f":
[1] f(x::Float64, y::Float64) in Main at REPL[28]:1
[2] f(x, y) in Main at REPL[26]:1
```

Здесь же посмотрим на диспетчеризацию
```julia-repl
julia> f(1, 1)
3

julia> f(1.0, 1.0)  # два Float64, подходит f(x::Float64, y::Float64)
4.0

julia> f(1.0, 1)    # Float64 и Int64, подходит f(x, y)
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

**Как создаётся быстрый код?** При запуске функции или метода от данного набора аргументов в первый раз, Julia

- Запоминает типы аргументов при вызове (типы могут быть и абстрактные);
- Выводит типы переменных в теле функции (*type inference*), для которых это возможно;
- Компилирует функцию для данного набора типов аргументов и сохраняет машинный код, если все типы переменных **стабильны**, т.е. не зависят от *значений* аргументов;
- При дальнейших вызовах функции с теми же типами аргументов будет использоваться компилированная (быстрая) версия.

Кроме того, до запуска скрипта (*compilation time*) Julia просматривает методы и некоторые из них может прекомпилировать.

Методы могут быть параметрическими, и в их теле вам будет доступен тип аргумента на этапе компиляции (`typeof(x)` не нужен).

```{tip}
:class: dropdown

На методах основаны интерфейсы в языке. Например, вы можете создавать собственные структуры данных, у которых будет поведение массивов. Как только вы объявите методы интерфейса для своего типа, вы сможете пользоваться всеми функциями, определенными для `AbstractArray{T,N}`. Или, скажем, вы можете встроить свои структуры данных в интерфейс цикла `for`.

С помощью методов также создаются типы, ведущие себя как функции: их можно вызывать (*callable*). На этом основаны замыкания (*closures*) в Julia.

Изобретено множество дизайн-паттернов с использованием методов и типов. За подробностями по теме методов обращайтесь в мануал **[[url]](https://docs.julialang.org/en/v1/manual/methods/)**. Много паттернов описано в книге {cite}`Kwong2020`.
```