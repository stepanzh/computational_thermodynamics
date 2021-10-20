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

# Методы бисекции и regula falsi

## Метод бисекции

Для непрерывной функции известно, что, имея разные знаки $f(a)f(b)<0$ на концах отрезка $[a, b]$, функция $f$ имеет также корень $f(x^*)=0$ на этом отрезке $x^* \in [a, b]$.

Метод бисекции пользуется этим утверждением. Разобъём исходный отрезок $[x_1, x_2]$ пополам точкой $x_3 = (x_1 + x_2) / 2$. Тогда, если $x_3$ не является корнем уравнения, то $f$ имеет разные знаки либо на концах отрезка $[x_1, x_3]$, либо на концах отрезка $[x_3, x_2]$. Выберем в качестве нового отрезка тот, на котором функция имеет разные знаки и продолжим процедуру.

Метод бисекции гарантирует локализацию корня. Поскольку за итерацию длина отрезка уменьшается вдвое $\Delta_{k+1} = \Delta_k / 2$, то имеет место *линейная сходимость* метода.

Общая формула длины отрезка имеет вид

```{math}
\Delta_k = \frac{\Delta_0}{2^k}.
```

Тогда, если потребовать точность найденного корня в виде

```{math}
|x_{k+1} - x_k| = \Delta_k < \text{xtol},\quad k = 0, 1, 2, ...
```

то получим необходимое число итераций

```{math}
k_\max = \Big\lceil \log_2\Big(\frac{\Delta_0}{\text{xtol}}\Big) \Big\rceil.
```

```{proof:function} bisection

**Метод бисекции**

:::julia
"""
Ищет корень уравнения `f`(x) = 0 бисекцией с точностью локализации корня `xtol`.
Итерации заканчиваются досрочно, если `f`(xₖ) < `ftol`.
"""
function bisection(f, x₁, x₂; xtol=eps(), ftol=eps())
    if x₁ > x₂; x₁, x₂ = x₂, x₁; end
    y₁, y₂ = f(x₁), f(x₂)
    sign(y₁) == sign(y₂) && error("Функция должна иметь разные знаки в концах отрезка")
    y₁ == 0 && return x₁
    y₂ == 0 && return x₂
    
    maxiter = ceil(Int, log2((x₂-x₁)/(xtol)))
    
    for i in 1:maxiter
        xnew = (x₂ + x₁) / 2
        ynew = f(xnew)
        
        if sign(y₂) == sign(ynew)
            x₂, y₂ = xnew, ynew
        elseif sign(y₁) == sign(ynew)
            x₁, y₁ = xnew, ynew
        else
            return xnew
        end
        abs(ynew) < ftol && return xnew
    end
    return (x₂ + x₁)/2
end
:::
```

```{code-cell}
f = (x) -> -x^2 + x
@show bisection(f, 0.5, 1.6; xtol=1e-6)
@show bisection(f, 0.5, 1.6; xtol=1e-10);
```