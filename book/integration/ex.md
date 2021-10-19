# Задания

## Основные квадратурные формулы

В этом задании вам необходимо доработать модуль `Integration`, имплементировав требуемые методы.

Шаблон модуля разработан за вас, скачайте его по ссылке [CT_Integration.jl](https://github.com/stepanzh/CT_Integration.jl). Если пользуетесь git, можете склонировать проект или форкнуть, в остальных случаях скачайте `Code -> Download ZIP`.

**Устройство модуля**

Модуль `Integration` находится в `src/Integration.jl` и устроен следующим образом.

Для пользователя модуля создана API-функция `integrate` с двумя методами

```julia
integrate(f, a, b; method)
integrate(f, a, b, nnodes; method)
```

И набор синглетонов для указания метода `method` для интегрирования

```julia
Gauss, Kronrod, Midpoint, Trapezoid, Simpson
```

Так `integrate(x -> 2x, -1, 3; method=Midpoint())` вычисляет $\int_{-1}^3 2x\:\diff x$ по формуле средних прямоугольников. А `integrate(x -> 2x, -1, 3, 10; method=Midpoint())` вычисляет тот же интеграл, но предварительно разбивает отрезок 10 равноотстоящими узлами.

В свою очередь, разработчиками организован диспатч по синглетонам, и имплементация формулы средних прямоугольников выглядит так

```julia
#= Ещё код =#

# Диспетчеризация интерфейса
integrate(args...; method) = __integrate_impl(method, args...)

#= Ещё код =#

"Формула средних прямоугольников"
struct Midpoint <: AbstractMethod end

__integrate_impl(method::Midpoint, f, a, b) = (b-a) * f((b+a)/2)

# составной метод для формулы прямоугольников
function __integrate_impl(method::Midpoint, f, a, b, nnodes)
    h = (b - a) / (nnodes - 1)
    x = range(a + h/2, b; step=h)
    int = h * sum(f, x)
    return int
end

#= Ещё код =#
```


**Задание**

Вам необходимо имплементировать методы, которые в шаблоне определены как

```julia
__integrate_impl(method::T, f, a, b) = error("Не имплементирован")
```

**Самопроверка**

Для самопроверки предоставлены unit-тесты модуля `Integration`. Они находятся в `test/runtests.jl`.

При скачанном шаблоне должны проходить только тесты для формулы прямоугольников:

Чтобы запустить тесты, есть две возможности.

Сначала перейдите в корневую директорию модуля (там, где находится файл `Project.toml`)

1. Запуск тестов из `pkg>` режима Julia REPL.
    
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

    julia> ]<Enter>

    (@v1.6) pkg> activate .
      Activating environment at `~/JIHT/computational_thermodynamics_notes/03_integration/CT_Integration.jl_task/Project.toml`

    (Integration) pkg> test

    # много всяких сообщений об ошибках из-за несозданных методов

    Test Summary:                        | Pass  Error  Total
    Integration                          |    6     19     25
      Midpoint                           |    6             6
      Trapezoid                          |           6      6
        Квадратурная формула             |           4      4
        Составная квадратурная формула   |           2      2
      Simpson                            |           4      4
        Квадратурная формула             |           2      2
        Составная квадратурная формула   |           2      2
      Gauss                              |           4      4
        Интегрирование полинома          |           2      2
        Интегрирование 1/(1+x²)          |           2      2
          Составная квадратурная формула |           1      1
      Kronrod                            |           5      5
        Интегрирование полинома          |           3      3
        Интегрирование 1/(1+x²)          |           2      2
          Составная квадратурная формула |           1      1
    ERROR: LoadError: Some tests did not pass: 6 passed, 0 failed, 19 errored, 0 broken.
    ```

2. Запуск тестов из терминала одной командой

    ```console
    % julia --color=yes --project=. test/runtests.jl
    ```

    Вы получите вывод, аналогичный пункту 1.

Первый метод позволяет не выходить из REPL, делать изменения в модуле, и запускать в дальнейшем одной командной `(Integration) pkg> test` *без перезапуска сессии*.

Так, вы можете имплементировать метод один за другим и проверять себя на каждом шаге.
