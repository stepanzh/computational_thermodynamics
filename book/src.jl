using LaTeXStrings
using LinearAlgebra
using Plots
using PrettyTables
using Markdown


#=
==
== Интерполяция
==
=#

"Возвращает полиномиальный интерполянт, проходящий через точки (`t[i]`, `y[i]`)."
function polyinterp(t, y)
    V = vandermonde(t)
    c = V \ y
    return x -> horner(c, x)
end

"Возвращает матрицу Вандермонда."
function vandermonde(x)
    V = zeros(eltype(x), size(x, 1), size(x, 1))
    for j in 1:size(V, 2)
        V[:, j] .= x .^ (j-1)
    end
    return V
end

"Вычисляет полином `c[1] + c[2]*x + c[3]*x^2 + ...` алгоритмом Горнера."
function horner(c, x)
    ans = last(c)
    for i in lastindex(c)-1:-1:1
        ans = (ans * x) + c[i]
    end
    return ans
end

"""
Возращает hat-функцию φₖ(x) для отсортированной сетки `t`.
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

"Возвращает кусочно-линейный интерполянт для точек (`t[i]`, `y[i]`)."
function pwlininterp(t, y)
    basis = [hatfunc(t, k) for k in 1:size(t, 1)]
    return x -> sum(y[k]*basis[k](x) for k in 1:size(y, 1))
end


"Возвращает полином вида `c[1] + c[2]*x + c[3]*x^2 + ...`."
polynomial(c) = x -> horner(c, x)


"Возвращает кубический сплайн, проходящий через точки (`t[i]`, `y[i]`)"
function spinterp(t, y)
    n = size(t, 1) - 1

    In = I(n)
    E = In[1:end-1, :]
    J = diagm(0 => ones(n), 1 => -ones(n-1))
    Z = zeros(n, n)
    h = [t[k+1] - t[k] for k in 1:n]
    H = diagm(0 => h)

    # 1.а Значения на левой границе
    AL = [In Z Z Z]
    vL = y[1:end-1]

    # 1.б Значения на правой границе
    AR = [In H H^2 H^3]
    vR = y[2:end]

    # 2. Непрерывность первой производной
    A1 = E * [Z J 2*H 3*H^2]
    v1 = zeros(n-1)

    # 3. Непрерывность второй производной
    A2 = E * [Z Z J 6*H]
    v2 = zeros(n-1)

    # 4. Not-a-knot
    nakL = [zeros(1, 3*n) 1 -1 zeros(1, n-2)]  # слева
    nakR = [zeros(1, 3*n) zeros(1, n-2) 1 -1]  # справа

    # Собираем систему и решаем
    A = [AL; AR; A1; A2; nakL; nakR]
    v = [vL; vR; v1; v2; 0; 0]
    coefs = A \ v

    # Разбираем коэффициенты
    a = coefs[1:n]
    b = coefs[n+1:2*n]
    c = coefs[2*n+1:3*n]
    d = coefs[3*n+1:4*n]

    S = [polynomial([a[k], b[k], c[k], d[k]]) for k in 1:n]

    return function (x)
        if x < first(t) || x > last(t)
            return NaN
        elseif x == first(t)
            return first(y)
        else
            k = findlast(x .> t)  # k такое, что x ∈ (tₖ₋₁, tₖ)
            return S[k](x - t[k])
        end
    end
end


#=
==
== Интегрирование
==
=#

"""
Вычисляет по формуле прямоугольников интеграл ∫`f`dx на отрезке [`a`, `b`]
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


"""
Вычисляет по формуле трапеций интеграл ∫`f`dx на отрезке [`a`, `b`]
с равномерной сеткой из `n` интервалов.
Возвращает значение интеграла, узлы и значения функции в узлах.
"""
function trapezoid(f, a, b, n)
    h = (b-a)/n
    x = collect(range(a, b; length=n+1))
    y = f.(x)
    int = h * (sum(y[2:n]) + 0.5*(y[1] + y[n+1]))
    return int, x, y
end

"""
Вычисляет по формуле Симпсона интеграл ∫`f`dx на отрезке [`a`, `b`]
с равномерной сеткой из `n` (чётное) интервалов.
Возвращает значение интеграла.
"""
function simpson(f, a, b, n)
    return (1/3) * (4*trapezoid(f, a, b, n)[1] - trapezoid(f, a, b, n÷2)[1])
end
