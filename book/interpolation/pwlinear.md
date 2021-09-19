---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
kernelspec:
  display_name: Julia
  language: julia
  name: julia-1.6
---

```{code-cell}
:tags: [remove-cell]

include("interpolation.jl")
```

# Кусочно-линейная интерполяция

Что самое простое можно сделать с набором точек? Соединить отрезками. В этом и состоит кусочно-линейная интерполяция.

Математически: на каждом отрезке $[t_k, t_{k+1}]$ интерполянт является отрезком прямой, соединяющей точки $(t_k, y_k)$ и $(t_{k+1}, y_{k+1})$

```{math}
:label: pwlin

p(x) = y_k + \frac{y_{k+1} - y_k}{t_{k+1} - t_k} (x - t_k),\quad x \in [t_k, t_{k+1}]
```

Простой способ реализации формулы {eq}`pwlin` заключается в поиске отрезка $[t_k, t_{k+1}]$, которому принадлежит $x$, а затем уже в применении {eq}`pwlin`.

Мы же поступим более общим способом.

## Hat-функции

Искомый интерполянт лишь одна из *непрерывных кусочно-линейных* функций, которые образуют *линейное пространство*. В этом пространстве функция выражается в виде

```{math}
:label: pwlin_decomp

p(x) = \sum_{k=1}^n c_k \varphi_k(x),\quad x \in [t_1, t_n].
```

Где набор функций $\{\varphi_k(x)\}$ является *базисом* пространства, а коэффициенты (веса, координаты) $c_k$ однозначно задают $p(x)$. В качестве такого базиса широко используются hat-функции.

Hat-функция $\varphi_k$ это функция треугольного вида, задающаяся аналитически в виде

```{math}
:label: hatfunc

\varphi_k(x) = \begin{cases}
\dfrac{x-t_{k-1}}{t_k - t_{k-1}},& x \in [t_k, t_{k-1}],\\
\dfrac{t_{k+1}-x}{t_{k+1} - t_k},& x \in [t_{k+1}, t_k],\\
0, & иначе.
\end{cases},\quad k = 2,...,n-1
```

Мы здесь не будем специально выписывать формулы для $\varphi_1$ и $\varphi_n$, которые являются половинчатыми hat-функциями.

Реализуем hat-функции через замыкание.

```julia
"""
Возращает hat-функцию φ_k(x) для отсортированной сетки абсцисс `t`.
Индекс `k ∈ [1, size(t, 1)]`.
"""
function hatfunc(t, k)
    n = size(t, 1)
    return function (x)
        if k ≥ 2 && t[k-1] ≤ x ≤ t[k]
            return (x - t[k-1]) / (t[k] - t[k-1])
        elseif k ≤ n-1 && t[k] ≤ x ≤ t[k+1]
            return (t[k+1] - x) / (t[k+1] - t[k])
        else  # x вне [t[1], t[end]] или неподходящий k
            return zero(x)
        end
    end
end
```

Допустим, интерполяция производится по четырём точкам $t_1 = 1.0, t_2 = 1.3, t_3 = 3.1, t_4 = 4.0$ (абсциссы), соответствующий базис имеет вид.

```{code-cell}
ts = [1.0, 1.3, 3.1, 4.0]
xs = range(first(ts), last(ts); length=200)
plt = plot(layout=(4,1),xlabel=L"x", ylims=[-0.1,1.1], ytick=[1], leg=:outertopleft)
for k in 1:size(ts, 1)
    φ_k = hatfunc(ts, k)
    plot!(xs, φ_k.(xs); label="φ_$k", subplot=k)
    scatter!(ts, φ_k.(ts); label="", subplot=k)
end
plt
```

## Интерполяция

Поскольку hat-функции обладают свойством

```{math}
\varphi_k(t_l) = \begin{cases}
1, & k = l,\\
0, & k \ne l.
\end{cases}
```

То коэффициенты $c_k$ в разложении {eq}`pwlin_decomp` равняются $y_k$

```{math}
p(x) = \sum_{k=1}^n y_k \varphi_k(x),\quad x \in [t_1, t_n].
```

Ниже реализация

```julia
"Возвращает кусочно-линейный интерполянт для точек (`t[i]`, `y[i]`)."
function pwlininterp(t, y)
    basis = [hatfunc(t, k) for k in 1:size(t, 1)]
    return x -> sum(y[k]*basis[k](x) for k in 1:size(y, 1))
end
```

```{note} Пояснения по синтаксису

> `basis = [hatfunc(t, k) for k in 1:size(t, 1)]`

Создание вектора из функций с помощью [Array comprehensions](https://docs.julialang.org/en/v1/manual/arrays/#man-comprehensions).

> `sum(y[k]*basis[k](x) for k in 1:size(y, 1))`

- Внутри `sum` стоит [генератор](https://docs.julialang.org/en/v1/manual/arrays/#Generator-Expressions), что очень похоже на Array Comprehension, но не аллоцирует массив;
- `basis[k](x)` стоит читать как `(basis[k])(x)`: извлечение `k`-го элемента массива `basis`, что является функцией и затем вызов этой функции с аргументом `x`.
```

## Обусловленность и сходимость
