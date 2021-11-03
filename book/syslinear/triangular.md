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

# Треугольные системы

Прежде всего рассмотрим решение треугольной системы.

Рассмотрим частный случай для системы $\mathbf{L}\mathbf{x}=\mathbf{b}$, где $\mathbf{L}$ -- **нижнетреугольная** матрица размера 4

```{math}
\begin{bmatrix}
L_{11} & 0 & 0 & 0 \\
L_{21} & L_{22} & 0 & 0 \\
L_{31} & L_{32} & L_{33} & 0 \\
L_{41} & L_{42} & L_{43} & L_{44}
\end{bmatrix}
\begin{bmatrix}
x_1 \\ x_2 \\ x_3 \\ x_4
\end{bmatrix}
=
\begin{bmatrix}
b_1 \\ b_2 \\ b_3 \\ b_4
\end{bmatrix}
```

```{index} подстановка; прямая
```
Эта система может быть решена итерационно, начиная с $x_1$

```{math}
\begin{split}
x_1 &= \frac{b_1}{L_{11}}\\
x_2 &= \frac{b_2 - L_{21}x_1}{L_{22}}\\
x_3 &= \frac{b_3 - (L_{31}x_1 + L_{32}x_2)}{L_{33}}\\
x_4 &= \frac{b_4 - (L_{41}x_1 + L_{42}x_2 + L_{43}x_3)}{L_{44}}
\end{split}
```

Алгоритм, который здесь применён называют **прямой подстановкой** (*forward substitution*).

```{index} подстановка; обратная
```

Аналогично, система $\mathbf{U}\mathbf{x}=\mathbf{b}$, где $\mathbf{U}$ -- **верхнетреугольная** матрица, может быть решена алгоритмом **обратной подстановки** (*backward substitution*). Например, для случая $\mathbf{U}$ размера 4

```{math}
\begin{bmatrix}
U_{11} & U_{12} & U_{13} & U_{14} \\
0 & U_{22} & U_{23} & U_{24} \\
0 & 0 & U_{33} & U_{34} \\
0 & 0 & 0 & U_{44}
\end{bmatrix}
\begin{bmatrix}
x_1 \\ x_2 \\ x_3 \\ x_4
\end{bmatrix}
=
\begin{bmatrix}
b_1 \\ b_2 \\ b_3 \\ b_4
\end{bmatrix}
```

алгоритм обратной подстановки начинается с $x_4$ и включает следующие шаги

```{math}
\begin{split}
x_4 &= \frac{b_4}{U_{44}}\\
x_3 &= \frac{b_3 - U_{34}x_4}{U_{33}}\\
x_2 &= \frac{b_2 - (U_{23}x_3 + U_{24}x_4)}{U_{22}}\\
x_1 &= \frac{b_1 - (U_{12} x_2 + U_{13}x_3 + U_{14}x_4)}{U_{11}}.
\end{split}
```

Алгоритм постановки показывает следующее утверждение.

```{proof:proposition}
Треугольная матрица вырождена тогда и только тогда, когда хотя бы один ёё диагональнй элемент нулевой.
```

## Реализация

```{proof:function} forwardsub

**Алгоритм прямой подстановки**

:::julia
"Возвращает решение системы `L`x = `b`, где `L` - нижнетреугольная квадратная матрица."
function forwardsub(L::AbstractMatrix, b::AbstractVector)
    x = float(similar(b))
    x[1] = b[1] / L[1, 1]
    for i in 2:size(L, 1)
        s = sum(L[i, j]*x[j] for j in 1:i-1)
        x[i] = (b[i] - s) / L[i, i]
    end
    return x
end
:::

Конструкция `similar(b)` создаёт неинициализированный массив того же типа и размера, что и `b`.
Вектор `b` может содержать, например, и целые числа `::Integer`.
Поскольку в алгоритме деление приведёт к появлению чисел с плавающей точкой, массив `x` сразу приводится к массиву на основе `::Float`-чисел конструкцией `float(similar(b))`.
```

```{proof:function} backwardsub

**Алгоритм обратной подстановки**

:::julia
"Возвращает решение системы `U`x = `b`, где `U` - верхнетреугольная квадратная матрица."
function backwardsub(U::AbstractMatrix, b::AbstractVector)
    n = size(U, 1)
    x = float(similar(b))
    x[n] = b[n] / U[n, n]
    for i in size(U, 1)-1:-1:1
        s = sum(U[i, j] * x[j] for j in i+1:n)
        x[i] = (b[i] - s) / U[i, i]
    end
    return x
end
:::
```

```{proof:demo}
```
```{raw} html
<div class="demo">
```

Применение прямой подстановки

```{code-cell}
A = [
    1 0 0;
    2 1 0;
    4 2 3;
]
b = [2, 3, 5]
x = forwardsub(A, b)
x, A*x - b
```

```{raw} html
</div>
```
