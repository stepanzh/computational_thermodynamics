---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.16.4
kernelspec:
  display_name: Julia 1.10.4
  language: julia
  name: julia-1.10
---

```{eval-rst}
.. meta::
   :description: В этом разделе мы рассмотрим метод Ньютона для решения нелинейной системы уравнений.
   :keywords: метод ньютона, нелинейное уравнение, система нелинейных уравнений, снау, вычислительная математика, вычматы
```

```{code-cell}
:tags: [remove-cell]

include("../src.jl")
```

(sec-nlsystem-newton)=
# Метод Ньютона

Одним из простых методов решения является обобщение метода Ньютона (Ньютона-Рафсона, *Newton-Raphson method*) на случай многомерной функции $\mathbf{f}$.

Как и для скалярного метода, представим $\mathbf{f}$ линейной моделью

```{math}
:label: sysnonlinear_taylor

f_i(\mathbf{x} + \mathbf{\delta x})
= f_i(\mathbf{x}) + \sum_{j=1}^n \frac{\partial f_i}{\partial x_j}(\mathbf{x}) \delta x_j + O(\mathbf{\delta x}^2)
```

```{margin}
В русскоязычной литературе якобианом называют, как правило, детерминант матрицы Якоби.
```
```{index} якобиан
```
```{index} pair: Якоби; матрица
```
Матрицу $\mathbf{J}(\mathbf{x})$ с элементами $J_{ij}(\mathbf{x}) = \frac{\partial f_i}{\partial x_j}(\mathbf{x})$ называют **матрицей Якоби**, мы же, для краткости, будем называть её просто **якобианом**.

С помощью якобиана система {eq}`sysnonlinear_taylor` записывается в виде

```{math}
\mathbf{f}(\mathbf{x} + \mathbf{\delta x})
= \mathbf{f}(\mathbf{x}) + \mathbf{J}(\mathbf{x}) \delta \mathbf{x} + O(\mathbf{\delta x^2}).
```

Положим теперь $\mathbf{f}(\mathbf{x} + \mathbf{\delta x}) = \mathbf{0}$ и отбросим квадратичную поправку. Тогда получим условие

```{math}
:label: sysnonlinear_newton_step

\mathbf{J}(\mathbf{x}) \delta \mathbf{x} = - \mathbf{f}(\mathbf{x}),
```

которое для *фиксированного* $\mathbf{x}$ является линейной системой на $\delta\mathbf{x}$.

Так, метод Ньютона строит серию приближений

```{math}
\mathbf{x}_\text{new} = \mathbf{x}_\text{old} + \delta\mathbf{x} = \mathbf{x}_\text{old} - \mathbf{J}^{-1}(\mathbf{x}_\text{old})\mathbf{f}(\mathbf{x}_\text{old}).
```

```{index} шаг; ньтоновский (нелинейные системы)
```
В свою очередь, шаг $\delta\mathbf{x}$, найденный из условия {eq}`sysnonlinear_newton_step` называют **ньютоновским** шагом. 


```{index} метод; Ньютона многомерный
```
```{proof:algorithm} Многомерный метод Ньютона
Пусть дана функция $\mathbf{f}(\mathbf{x})$, её якобиан $\mathbf{J}(\mathbf{x})$ и начальное приближение корня $\mathbf{x}_1$. Последующие $\mathbf{x}_k$, $k=2, 3, 4, \ldots$ приближения корня строятся следующим образом.

1. Вычислить значение функции $\mathbf{f}_k = \mathbf{f}(\mathbf{x}_k)$ и якобиан $\mathbf{J}_k = \mathbf{J}(\mathbf{x}_k)$;

2. Решить линейную систему $\mathbf{J}_k \delta \mathbf{x} = - \mathbf{f}_k$ на шаг $\delta \mathbf{x}$;

3. Построить новое приближение корня $\mathbf{x}_{k+1} = \mathbf{x}_k + \delta \mathbf{x}$.
```

## Реализация

```{proof:function} newtonsys

**Метод Ньютона-Рафсона решения системы нелинейных уравнений**

:::julia
"""
    newtonsys(f, x, J[; maxiter=50, xtol=1e-6, ftol=1e-6])

Решает нелинейную систему `f`(x) = 0 методом Ньютона-Рафсона, начиная с приближения `x`.
Функция `J`(x) должна возвращать матрицу Якоби системы. Работа метода ограничена
числом итераций `maxiter`, досрочное завершение происходит при достижении
`norm(x) < xtol` или `norm(f(x)) < ftol`. При превышении числа итераций вызывает
ошибку. Возвращает найденный корень.
"""
function newtonsys(f, x, J; maxiter=50, xtol=1e-6, ftol=1e-6)
    x = float(copy(x))
    δx, y = similar.((x, x))
    for i in 1:maxiter
        y .= f(x)
        δx .= .- (J(x) \ y)
        x .+= δx

        norm(δx) < xtol && return x
        norm(y) < ftol && return x
    end
    error("Превышено число итераций.")
end
:::

:::{note}
В данной реализации необходимая память выделяется до цикла, а затем переиспользуется с помощью механизма броадкаста. Единственное место, всё ещё выделяющее память алгоритмом, является операция `\` решения линейной системы. Поскольку `J(x)` возвращает квадратную матрицу, `\`-операция сначала совершает LU-разложение, требующее аллоцирования. Чтобы избежать этой аллокации, смотрите `LinearAlgebra.ldiv!`.
:::
```

(demo_sysnonlinear_newton)=
```{proof:demo}
```
```{raw} html
<div class="demo">
```

Рассмотрим в качестве примера решение системы

```{math}
\mathbf{f}(\mathbf{x})
= \begin{bmatrix}
x_1^2 - 2 x_2^2 - x_1 x_2 + 2x_1 - x_2 + 1\\
2x_1^2 - x_2^2 + x_1 x_2 + 3 x_2 - 5
\end{bmatrix}
= \mathbf{0}
```

Якобиан данной функции имеет вид

```{math}
\mathbf{J}(\mathbf{x})
= \begin{bmatrix}
2x_1 - x_2 + 2 & -4x_2 - x_1 - 1 \\
4x_1 + x_2     & -2x_2 + x_1 + 3 
\end{bmatrix}
```

Для решения заведём две функции `f` и `J` для функции $\mathbf{f}$ и якобиана $\mathbf{J}$ соответственно

```{code-cell}
:tags: [remove-output]

function f(x)
    x₁, x₂ = x
    return [
        x₁^2 - 2x₂^2 - x₁*x₂ + 2x₁ - x₂ + 1,
        2x₁^2 - x₂^2 + x₁*x₂ + 3x₂ - 5,
    ]
end

function J(x)
    x₁, x₂ = x
    return [
        2x₁-x₂+2 -4x₂-x₁-1;
        4x₁+x₂   -2x₂+x₁+3
    ]
end
```

При наборе якобиана будьте внимательны. В Julia знак пробела или табуляция в литерале массивов означает горизонтальную конкатенацию. И в некоторых версиях языка `[x+y 0;]` (матрица `1 × 2`) может не быть эквивалентом `[x + y 0;]`.

Попробуем запустить метод из разных начальных приближений.

```{code-cell}
root = newtonsys(f, [10.0, 10.0], J)
root, f(root)
```

```{code-cell}
root = newtonsys(f, [-10.0, 10.0], J)
root, f(root)
```

```{code-cell}
root = newtonsys(f, [10.0, -10.0], J)
root, f(root)
```

```{code-cell}
root = newtonsys(f, [-10.0, -10.0], J)
root, f(root)
```

Так, найдено три корня системы.

```{raw} html
</div>
```
