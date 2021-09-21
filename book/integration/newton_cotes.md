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

include("../src.jl")
```

# Формулы Ньютона-Котеса

Идея вывода формул Ньютона-Котеса заключаются в *кусочной полиномиальной интерполяции* подыинтегральной функции $f$.

## Формула прямоугольников

В формуле прямоугольников функция на отрезке $[x_{i-1}, x_i]$ считается постоянной:

```{margin}
Существуют также левый правый вариант, но у них хуже точность.
```
```{math}
\int_{x_{i-1}}^{x_i} f(x)\diff x \approx f(x_{i-1/2}) h,
```

где

```{math}
x_{i-1/2} = \frac{x_i - x_{i-1}}{2}
```

поэтому её ещё называют *midpoint rule*.

Составная формула прямоугольников имеет вид

```{math}
\int_a^b f(x)\diff x \approx \sum_{i=1}^n f(x_{i-1/2}) h.
```

:::{admonition} Функция : `midpoint`

**Формула прямоугольников.**

```julia
"""
Вычисляет интеграл ∫`f`dx на отрезке [`a`, `b`]
с равномерной сеткой из `n` интервалов.
Возвращает значение интеграла, узлы и значения функции в узлах.
"""
function midpoint(f, a, b, n)
    h = (b-a)/n
    x = [h/2 + i * h for i in 0:n-1]
    y = f.(x)
    int = h * sum(y)
    return int, x, y
end
```
:::

%%% demo

**Демонстрация работы.**

Ниже представлены графики численного интеграла

```{math}
\int_0^3 x \exp(\sin(2x))
```

для разного числа точек.

```{code-cell}
foo(x) = x * exp(sin(2x))
plt = plot(layout=(2,1), leg=:none, xlabel=L"x")
for (i, n) in enumerate((8, 16))
    _, x, y = midpoint(foo, 0, 3, n)
    plot!(foo, 0, 3; subplot=i, linewidth=2, linecolor=:red)

    for (px, py) in zip(x, y)
        h = 3 / n
        plot!([px-h/2, px+h/2], [py, py];
            subplot=i, fill=(0, 0.1, :blue), linecolor=:blue, linewidth=2
        )
    end
    scatter!(x, y; subplot=i, marker=:o, markercolor=:lightblue)
end
plt
```

Можно показать, что формула прямоугольников имеет второй порядок сходимости

```{math}
|\tau_f(h)| = \frac{h^2(b-a)}{24} \max_{x\in [a,b]} |f''(x)| \sim O(h^2).
```

При этом отсюда видно, что ошибка становится *нулевой* для линейных функций (для них $f'' \equiv 0$).
