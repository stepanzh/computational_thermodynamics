# Задания

## Основные квадратурные формулы

В этом задании вам необходимо доработать модуль `Integration`, имплементировав требуемые методы.

Шаблон модуля разработан за вас и находится здесь [CTTaskIntegration.jl](https://github.com/stepanzh/CTTaskIntegration.jl), модуль включает систему тестов для самопроверки.

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
