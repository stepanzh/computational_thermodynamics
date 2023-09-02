(arrays_linops)=
# Линейная алгебра

```{tip}
Больше информации тут **[[url]](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/)**.
```

В Julia богатая стандартная библиотека операций линейной алгебры. Часто используемые инструменты доступны сразу.

Ниже представлены примеры операций для этих векторов и матриц.

```julia-repl
julia> a = [1, 2, 3]; b = [4, 5, 6];

julia> A = [1 2; 3 4]; B = [-1 -2; -3 -4];
```

::::{tab-set}
:::{tab-item} Линейные
```julia-repl
julia> c = 2*a + b - a / 2
3-element Vector{Float64}:
  5.5
  8.0
 10.5

julia> A/2 + 2*B
2×2 Matrix{Float64}:
 -1.5  -3.0
 -4.5  -6.0
```
:::
:::{tab-item} Матричное умножение
```julia-repl
julia> A * [1, 2]
2-element Vector{Int64}:
  5
 11

julia> A * B
2×2 Matrix{Int64}:
  -7  -10
 -15  -22
```
:::
:::{tab-item} Транспонирование
```julia-repl
julia> a'
1×3 adjoint(::Vector{Int64}) with eltype Int64:
 1  2  3

julia> a' * b
32

julia> A * A'
2×2 Matrix{Int64}:
  5  11
 11  25
```
Для комплексных матриц `'`-оператор выполняет эрмитово сопряжение.
:::
:::{tab-item} Решение СЛАУ
Решается система $A x = [1, 2]^\top$, `inv(A)`$= A^{-1}$.
```julia-repl
julia> x = A \ [1, 2]
2-element Vector{Float64}:
 0.0
 0.5

julia> A * x
2-element Vector{Float64}:
 1.0
 2.0

julia> inv(A) * [1, 2] == x
true
```
:::
::::

Дополнительный набор инструментов импортируется из стандартной библиотеки `LinearAlgebra`.

```julia-repl
julia> using LinearAlgebra

julia> det(A), tr(A), norm(a)  # детерминант, след, норма
(-2.0, 5, 3.7416573867739413)

julia> a ⋅ b, A ⋅ B  # скалярное умножение, \cdot; или dot(a, b), dot(A, B)
(32, -30)

julia> a × b  # векторное умножение, \times; или cross(a, b)
3-element Vector{Int64}:
 -3
  6
 -3
```

`LinearAlgebra` также содержит

- типы для матриц специального вида;
- решатели СЛАУ;
- разложения матриц;
- функции над матрицами;
- низкоуровневые операции;
- [BLAS](https://ru.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms)-функции;
- обёртку над [LAPACK](https://ru.wikipedia.org/wiki/LAPACK).
