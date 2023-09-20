(syslinear-ex)=
# Задания

## Прямая и обратная подстановка

Реализуйте прямую и обратную подстановки для решения треугольных систем

$$
\mathbf{L} x = \mathbf{b}
\\ \mathbf{U} x = \mathbf{b}
$$

где $\mathbf{L}$ и $\mathbf{U}$ квадратные нижнетреугольная и верхнетреугольная матрицы, соответственно, а $\mathbf{b}$ -- вектор правой части системы.

Функция должны иметь следующую сигнатуру вызова

```julia
function forwardsub(L::AbstractMatrix, b::AbstractVector) end
function backwardsub(U::AbstractMatrix, b::AbstractVector) end
```

а возвращать вектор из `Float64` чисел.

Добавьте в функции несколько проверок

1. На размерность --- матрица квадратная, размер матрицы системы и правой части корректны;
2. На треугольность системы (см. [Julia/LinearAlgebra](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/));
3. На вырожденность системы.

Дополнительно

- Напишите doc-string к каждой из функций (см. [Julia/Documentation](https://docs.julialang.org/en/v1/manual/documentation/));
- Напишите версии функций, не аллоцирующих память под вектор-решение $x$, а принимающих вектор на запись ответа в качестве аргумента:
    + `forwardsub!(x, L, b)`,
    + `backwardsub!(x, U, b)`.
    
## Метод прогонки

При численном решении дифференциальных уравнений часто возникает система

$$
a_i x_{i-1} + b_i x_i + c_i x_{i+1} = f_i, \quad i=1,\ldots,n,
$$

где $a_1 = c_n = 0$, а $\mathbf{f}$ -- вектор правой части системы.

В матричном виде система записывается как $\mathbf{A} \mathbf{x} = \mathbf{f}$, где матрица системы --- трёхдиагональная

$$
\begin{bmatrix}
b_1 & c_1 &        &         &         & \\
a_2 & b_2 & c_2    &         &         & \\
    & a_3 & b_3    & c_3     &         & \\
    &     & \ddots & \ddots  & \ddots  & \\
    &     &        & a_{n-1} & b_{n-1} & c_{n-1} \\
    &     &        &         & a_n     & b_n
\end{bmatrix}
$$


```{index} метод; прогонки
```
Для таких систем существует эффективный $O(n)$ алгоритм решения, называемый *методом прогонки* или алгоритмом Томаса.

Напишите функцию `tridiagsolve`, реализующую метод прогонки.
У функции должно быть два метода

- `tridiagsolve(a, b, c, f) -> x`;
- `tridiagsolve(A::Tridiagonal, f) -> x`, где `Tridiagonal` тип определён в `LinearAlgebra`.

Описание метода прогонки можно посмотреть здесь: {cite}`Ryabenkiy2016` (Раздел 4.4.2), [Википедия](https://ru.wikipedia.org/wiki/%D0%9C%D0%B5%D1%82%D0%BE%D0%B4_%D0%BF%D1%80%D0%BE%D0%B3%D0%BE%D0%BD%D0%BA%D0%B8).

## Системы уравнений

Решите следующие системы уравнений. Для каждого примера создайте функцию, которая не принимает аргументов и возвращает решение системы и невязку $\mathbf{b} - \mathbf{A}\mathbf{x}$.

Например,

```julia
function solution_a()
    A = [1 0; 0 1]
    b = [3, 4]
    x = A \ x
    return x, b - A * x
end
```

**(а)**

$$
\begin{bmatrix}
8 & 9 & 4 & -1 \\
0 & 4 & 1 & 0 \\
0 & 0 & -1 & 6 \\
0 & 0 & 0 & 11 \\
\end{bmatrix}
\mathbf{x}
= \begin{bmatrix}
9 \\
3 \\
-1 \\
2 \\
\end{bmatrix}
$$

**(б)**

$$
\begin{bmatrix}
-2 & 1 & 0 & 0 & 0 \\
1 & -2 & 1 & 0 & 0 \\
0 & 1 & -2 & 1 & 0 \\
0 & 0 & 1 & -2 & 1 \\
0 & 0 & 0 & 1 & -2 \\
\end{bmatrix}
\mathbf{x}
= \begin{bmatrix}
1 \\
1 \\
1 \\
1 \\
1 \\
\end{bmatrix}
$$

**(в)**

$$
\begin{bmatrix}
    1 & 8 & -3 & 9 \\
    0 & 4 & 10 & -2 \\
    8 & 2 & -5 & 1 \\
    3 & 1 & 6 & 12 \\
\end{bmatrix}
\mathbf{x}
= \begin{bmatrix}
    3 \\
    6 \\
    1 \\
    4 \\
\end{bmatrix}
$$

