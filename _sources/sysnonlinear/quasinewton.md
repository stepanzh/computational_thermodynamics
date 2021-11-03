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

# Метод Бройдена

Метод Ньютона послужил основой для многих других методов. Недостатком метода является требовательное по времени вычисление якобиана на каждой итерации. Для некоторых приложений это неприемлимо. Вместо прямого вычисления якобиана, **квазиньютоновские** методы заменяют якобиан некоторым приближением.

## Приближение якобиана конечной разностью

В {numref}`%s Методе секущих <chapter-nlroot-secant>` мы фактически сталкивались с приближением производной функции в точке $f'(x_{k+1})$

```{math}
\frac{f(x_{k+1}) - f(x_k)}{x_{k+1} - x_k}.
```

Численный метод, приближающий производную "из определения" ($\lim_{\Delta x \to 0} \Delta f / \Delta x$) называется методом конечной разности. Формулу замены производной её численным аналогом называют *разностной схемой*. Эти методы распространнены в решении дифференциальных уравнений.

Подобным образом можно поступить для приближения якобиана. В общем случае для $\mathbf{f}: \real^n \to \real^m$ якобиан преобразования имеет размер $m \times n$. Выпишем его $j$-ый столбец

```{math}
\mathbf{J}(\mathbf{x}) \mathbf{e}_j
= \begin{bmatrix}
\frac{\partial f_1}{\partial x_j}\\
\frac{\partial f_2}{\partial x_j}\\
\vdots\\
\frac{\partial f_m}{\partial x_j}
\end{bmatrix},
```

где $\mathbf{e}_j$ -- $j$-ый столбец единичной матрицы.

Якобиан состоит из частных производных, таким образом, можно выписать его приближение через конечные разности

```{math}
\mathbf{J}(\mathbf{x}) \mathbf{e}_j
\approx \frac{\mathbf{f}(\mathbf{x} + \delta \mathbf{e}_j) - \mathbf{f}(\mathbf{x})}{\delta},\quad \delta \in \real.
```

Значение $\delta$ выбирают, по умолчанию, близким к $\sqrt{\macheps}$ как предел численной стабильности метода конечных разностей. Этот предел берётся из сопоставления ошибки, даваемой самим методом и ошибкой округления при вычислениях.

```{proof:function} jacobianfd

**Приближение якобиана конечной разностью**

:::julia
"""
    jacobianfd(f, x[; y, δ])

Вычисляет якобиан функции `f` в точке `x` через конечную разность в точках `x` и `x + δ
I[:, j]`, где `δ::Number` - скаляр. Опционально можно подать `y == f(x)`. 
"""
function jacobianfd(f, x; y=f(x), δ=sqrt(eps())*max(norm(x), 1))
    m, n = size(y, 1), size(x, 1)
    J = zeros(m, n)
    x = float(copy(x))
    for j in 1:n
        x[j] += δ
        J[:, j] .= (f(x) .- y) ./ δ
        x[j] -= δ
    end
    return J
end
:::
```

```{proof:demo}
```
```{raw} html
<div class="demo">
```

Сравним на небольшом примере точность приближения якобиана. В качестве функции и точки приближения возьмём

```{math}
\mathbf{f}(\mathbf{x})
= \begin{bmatrix}
x_2 \exp{x_1} + \sin{x_1}\\
\cos{x_2} + x_1 x_3\\
\log{x_3} + x_2^2
\end{bmatrix}
,\quad
\mathbf{x}
= \begin{bmatrix}
\frac{2}{3}\\
-1\\
\sqrt{2}
\end{bmatrix}.
``` 

```{code-cell}
:tags: [remove-output]

function f(x)
    x₁, x₂, x₃ = x
    return [
        x₂*exp(x₁) + sin(x₁),
        cos(x₂) + x₁*x₃,
        log(x₃) + x₂^2,
    ]
end

function J(x)
    x₁, x₂, x₃ = x
    return [
        x₂*exp(x₁)+cos(x₁)   exp(x₁)  0    ;
        x₃                  -sin(x₂)  x₁   ;
        0                    2x₂      1/x₃ ;
    ]
end
```

Вычислим якобиан напрямую `Jexact`, и через конченые раности `Jfd`

```{code-cell}
x = [2/3, -1.0, sqrt(2)]
Jexact, Jfd = J(x), jacobianfd(f, x)
Jexact |> display
Jfd |> display
@show norm(Jexact - Jfd);
```

Отличие в данной точке получилось небольшим. В качестве меры невязки здесь приведена норма Фробениуса для матриц $\sqrt{\sum A_{ij}^2}$.

```{raw} html
</div>
```

## Метод

Обозначим приближение якобиана в точке $\mathbf{x}_k$ через $\mathbf{B}_k$, т.е.

```{math}
\mathbf{J}(\mathbf{x}_k) \approx \mathbf{B}_k.
```

На $k$-ой итерации шаг квазиньютоновского метода будем находить из системы

```{math}
:label: sysnonlinear_quasi_step

\mathbf{B}_k \delta \mathbf{x}_k = - \mathbf{f}_k,
```

здесь обозначены $\delta \mathbf{x}_k = \mathbf{x}_{k+1} - \mathbf{x}_k$, а $\mathbf{f}_k = \mathbf{f}(\mathbf{x}_k)$.

Квазиньютоновское условие на новое приближение якобиана $\mathbf{B}_{k+1}$ состоит в

```{math}
:label: sysnonlinear_quasi_cond
\mathbf{B}_{k+1} \delta \mathbf{x}_k = \mathbf{f}_{k+1} - \mathbf{f}_k.
```

Выбор $\mathbf{B}_{k+1}$ не однозначен. На практике хорошие результаты показывает правило Бройдена, выведенное из минимальной в смысле нормы Фробениуса поправки к $\mathbf{B}_k$

```{math}
:label: sysnonlinear_broyden_cond

\min \|\mathbf{B}_{k+1} - \mathbf{B}_k \|_\text{F},\quad \| \mathbf{A} \|_\text{F}
= \big( \sum_{i, j} |A_{ij}|^2 \big)^{1/2},
```

такой, что условие {eq}`sysnonlinear_quasi_cond` удовлетворится.

```{proof:definition} Правило Бройдена

:::{math}
:label: sysnonlinear_broyden_update

\mathbf{B}_{k+1} = \mathbf{B}_k + \frac{1}{\delta \mathbf{x}^\top_k \delta \mathbf{x}_k}
(\mathbf{f}_{k+1} - \mathbf{f}_k - \mathbf{B}_k \delta \mathbf{x}_k)
\delta \mathbf{x}^\top_k.
:::
```

Самыми ресурсоемкими операциями в правиле Бройдена является матричное умножение ($\mathbf{B}_k \delta \mathbf{x}_k$) и внешнее произведение ($\square \cdot \delta \mathbf{x}^\top_k$). При этом при использовании {ref}`QR-разложения <chapter_syslinear_qr>` получается сэкономить часть операций (для этого разложения $\text{QR}(\mathbf{A} + \mathbf{a}\mathbf{b}^\top)$ выражается через $\text{QR}(\mathbf{A})$).


```{index} метод; Бройдена, Бройдена метод
```
```{proof:algorithm} Метод Бройдена
Пусть дана функция $\mathbf{f}$, начальная точка $\mathbf{x}_1$ и приближение якобиана в этой точке $\mathbf{B}_1$. Последующие приближения $k = 2, 3, \ldots$ получаются примением действий

1. Решить систему {eq}`sysnonlinear_quasi_step`, найдя таким образом шаг $\delta \mathbf{x}_k$;

2. Построить новое приближение корня $\mathbf{x}_{k+1} = \mathbf{x}_k + \delta \mathbf{x}_k$ и вычислить значение функции в нём $\mathbf{f}_{k+1} = \mathbf{f}(\mathbf{x}_{k+1})$;

3. Получить новое приближение для якобиана $\mathbf{B}_{k+1}$ из формулы {eq}`sysnonlinear_broyden_update`.
```

В качестве начального приближения якобиана можно использовать как его конечную разность, так и настоящий якобиан.

## Реализация

```{proof:function} broydensys

**Метод Бройдена**

:::julia
"""
    broydensys(f, x, J[; maxiter, xtol, ftol])

Решает нелинейную систему уравнений `f`(x) = 0 методом Бройдена.
Требует начального приближения корня `x` уравнения и якобиана `J` в этой точке.
Выполняет итерации, пока норма решения `> xtol` или норма функции `> ftol`.
В случае превышения числа итераций `maxiter` вызывает ошибку.
"""
function broydensys(f, x, J; maxiter=50, xtol=1e-6, ftol=1e-6)
    δx = float(similar(x))
    yp, yn = similar.((δx, δx))
    x = float(copy(x))
    B = float(copy(J))
    yn .= f(x)
    for i in 1:maxiter
        yp .= yn
        δx .= .- (B \ yp)
        x .+= δx
        yn .= f(x)
        if norm(δx) < xtol || norm(yn) < ftol
            return x
        end
        g = B * δx
        B .+= (1 / dot(δx, δx)) .* (yn .- yp .- g) .* δx'
    end
    error("Превышено число итераций.")
end
:::

В данной реализации для простоты изложения явно не использовано QR-разложение, имеющее преимещуство перед LU-разложением при обновлении `B`.
```

```{proof:demo}
```
```{raw} html
<div class="demo">
```

Рассмотрим пример использования метода Бройдена. Возьмём функцию и якобиан из {numref}`Демонстрации %s <demo_sysnonlinear_newton>`, где использовался метод Ньютона

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

Сравним решения методом Бройдена, где в качестве $\mathbf{B}_1$ сначала используется истинный якобиан, а затем его конечная разность

```{code-cell}
x = [10.0, 10.0]
rjac = broydensys(f, x, J(x))
rfdjac = broydensys(f, x, jacobianfd(f, x))
@show rjac
@show rfdjac
@show f(rjac);
```

Поищем также другие корни, не используя подлинный якобиан

```{code-cell}
x = [-10.0, 10.0]
root = broydensys(f, x, jacobianfd(f, x))
root, f(root)
```
```{code-cell}
x = [10.0, -10.0]
root = broydensys(f, x, jacobianfd(f, x))
root, f(root)
```
```{code-cell}
x = [-10.0, -10.0]
root = broydensys(f, x, jacobianfd(f, x))
root, f(root)
```

```{raw} html
</div>
```

## Другие версии метода

Изложенная выше версия метода {eq}`sysnonlinear_broyden_update` требует решения линейной системы {eq}`sysnonlinear_quasi_step`. Однако, она сочетается с линейным поиском, обеспечивающим глобальную сходимость метода, т.е. сходимостью к корню из произвольного начального приближения $\mathbf{x}_1$, если корень существует. Правда, для этого необходимо переформулировать постановку задачи $\mathbf{f}(\mathbf{x}) = \mathbf{0}$ под задачу минимизации {cite}`NumRecipes2007`.

Если же линейный поиск не используется, распространены две версии алгоритма, использующие вместо матрицы $\mathbf{B}$ обратную к ней $\mathbf{B}^{-1}$, полученную аналитически. Использование $\mathbf{B}^{-1}$ позволяет не решать систему {eq}`sysnonlinear_quasi_step`, а сразу вычислять шаг

```{math}
\delta \mathbf{x}_k = - \mathbf{B}^{-1}_k \mathbf{f}_k.
```

Самим Бройденом была предложена формула для $\mathbf{B}^{-1}$ на основе применения [формулы Шермана-Моррисона](https://en.wikipedia.org/wiki/Sherman%E2%80%93Morrison_formula) к {eq}`sysnonlinear_broyden_update`

```{math}
\mathbf{B}^{-1}_{k+1}
= \mathbf{B}^{-1}_k
+ \frac{\delta \mathbf{x}_k - \mathbf{B}^{-1}_k \delta \mathbf{f}_k}{
    \delta \mathbf{x}_k^\top \mathbf{B}^{-1}_k \delta \mathbf{f}_k
  }
\delta \mathbf{x}_k^\top \mathbf{B}^{-1}_k,
```

здесь $\delta \mathbf{f}_k = \mathbf{f}_{k+1} - \mathbf{f}_k$. Как и формула {eq}`sysnonlinear_broyden_update`, данная формула минимизирует поправку {eq}`sysnonlinear_broyden_cond` для "прямой" матрицы $\mathbf{B}_{k+1}$. Метод, основанный на данной формуле ещё называют "хорошим методом Бройдена" (*good Broyden's method*).

Вторая версия метода на основе обратной матрицы $\mathbf{B}^{-1}$ использует формулу

```{math}
\mathbf{B}^{-1}_{k+1}
= \mathbf{B}^{-1}_k
+ \frac{\delta \mathbf{x}_k - \mathbf{B}^{-1}_k \delta \mathbf{f}_k}{\delta \mathbf{f}_k^\top \delta \mathbf{f}_k}
\delta \mathbf{f}_k^\top,
```

которая минимизирует норму Фробениуса уже между обратными приближениями якобиана

```{math}
\min \|\mathbf{B}^{-1}_{k+1} - \mathbf{B}^{-1}_k \|_\text{F}.
```

Эта версия распространилась под названием "плохого метода Бройдена" (*bad Broyden's method*). Хотя, слова "плохой" и "хороший" в названии методов имеют нейтральную коннотацию.
