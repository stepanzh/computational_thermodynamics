using BenchmarkTools
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
    x = range(a + h/2, b; step=h)
    int = h * sum(f, x)
    return int
end


"""
Вычисляет по формуле трапеций интеграл ∫`f`dx на отрезке [`a`, `b`]
с равномерной сеткой из `n` интервалов.
Возвращает значение интеграла, узлы и значения функции в узлах.
"""
function trapezoid(f, a, b, n)
    x = range(a, b; length=n+1)
    h = step(x)
    if isone(n)
        int = h * (f(x[1]) + f(x[2])) / 2
    else
        @views int = h * (sum(f, x[2:n]) + (f(x[1]) + f(x[n+1])) / 2)
    end
    return int
end

"""
Вычисляет по формуле Симпсона интеграл ∫`f`dx на отрезке [`a`, `b`]
с равномерной сеткой из `n` (чётное) интервалов.
Возвращает значение интеграла.
"""
function simpson(f, a, b, n)
    return (1/3) * (4*trapezoid(f, a, b, n) - trapezoid(f, a, b, n÷2))
end

"""
Вычисляет интеграл ∫`f`dx на [`a`, `b`] с точностью `atol` по формуле трапеций,
удваивая число разбиений интервала, но не более `maxstep` раз.
Возвращает значение интеграла.
"""
function trapezoid_tol(f, a, b; atol=1e-3, maxstep::Integer=100)
    nc, hc::Float64 = 1, b - a
    Tc = hc * (f(a) + f(b)) / 2
    for step in 1:maxstep
        Tp, np = Tc, nc
        hc /= 2
        nc *= 2
        Tc = Tp / 2 + hc * sum(f, (a + hc*(2i-1) for i in 1:np))
        abs(Tc - Tp) < atol && return Tc
    end
    error("Точность не удовлетворена.")
end

"""
Вычисляет интеграл ∫`f`dx на отрезке [`a`, `b`] методом Ромберга.
Разбивает отрезок пополам не более `maxstep` раз.
Возвращает значение интеграла, если приближения отличаются не более чем на `atol`.
"""
function romberg(f, a, b; atol=1e-6, maxstep::Integer=100)
    maxstep = max(1, maxstep)  # хотя бы одно разбиение
    I = Matrix{Float64}(undef, maxstep+1, maxstep+1)
    I[1, 1] = (b - a) * (f(a) + f(b)) / 2
    for i in 2:maxstep+1
        let hc = (b - a) / 2^(i-1), np = 2^(i-2)
            I[i, 1] = I[i-1, 1] / 2 + hc * sum(f, (a + hc * (2i-1) for i in 1:np))
        end
        for k in i-1:-1:1
            I[k, i-k+1] = (2^i*I[k+1, i-k] - I[k, i-k]) / (2^i - 1)
        end
        abs(I[1, i] - I[2, i-1]) < atol && return I[1, i]
    end
    error("Точность не удовлетворена.")
end

function rombergwstep(f, a, b; atol=1e-6, maxstep::Integer=100)
    maxstep = max(2, maxstep)
    I = Matrix{Float64}(undef, maxstep+1, maxstep+1)
    I[1, 1] = (b - a) * (f(a) + f(b)) / 2
    for i in 2:maxstep+1
        let hc = (b - a) / 2^(i-1), np = 2^(i-2)
            I[i, 1] = I[i-1, 1] / 2 + hc * sum(f, (a + hc * (2i-1) for i in 1:np))
        end
        for k in i-1:-1:1
            I[k, i-k+1] = (2^i*I[k+1, i-k] - I[k, i-k]) / (2^i - 1)
        end
        abs(I[1, i] - I[2, i-1]) < atol && return I[1, i], i
    end
    error("Точность не удовлетворена.")
end

"""
    intadapt(f, a, b, tol[, xtol=eps()])

Адаптивно вычисляет ∫`f`dx на отрезке [`a`, `b`], подстраивая сетку. Точность приближения `E` на подотрезке контролируется `tol`: `|E| < tol * (1 + tol * |int_i|)`. Сетка не может быть мельче `xtol`. Возвращает величину интеграла и сетку. Если точность не может быть достигнута, вызывает ошибку.
"""
function intadapt(f, a, b, tol, xtol=eps(), fa=f(a), fb=f(b), m=(b-a)/2, fm=f(m))
    if a > b; a, b = b, a; end

    xl = (a + m)/2; fl = f(xl)  # расположение:
    xr = (m + b)/2; fr = f(xr)  # a -- xl -- m -- xr -- b

    T = Vector{Float64}(undef, 3)
    h = b - a
    T[1] = h * (fa + fb)/2
    T[2] = T[1]/2 + h/2 * fm
    T[3] = T[2]/2 + h/4 * (fl + fr)
    S = (4*T[2:end] - T[1:2]) / 3

    err = (S[2] - S[1]) / 15

    if abs(err) < tol * (1 + tol * abs(S[2]))
        Q = S[2]
        nodes = [a, xl, m, xr, b]
    else
        b - a ≤ xtol && error("Достигнут предел точности отрезка интегрирования.")
        Ql, nodesl = intadapt(f, a, m, tol, xtol, fa, fm, xl, fl)
        Qr, nodesr = intadapt(f, m, b, tol, xtol, fm, fb, xr, fr)
        Q = Ql + Qr
        nodes = [nodesl; nodesr[2:end]]
    end
    return (Q, nodes)
end

#####
##### Нелинейные уравнения
#####

"""
Ищет неподвижную точку функции `g`, начиная с `x₁`. Выполняет итерации до тех пор,
пока подшаг к ответу ≥ `xtol`, но не более `maxiter` раз.
"""
function fixedpoint(g, x₁; xtol=eps(), maxiter=25)
    x = float(x₁)
    for i in 1:maxiter
        xprev = x
        x = g(xprev)
        abs(x - xprev) < xtol && return x
    end
    error("Число итераций превышено.")
end
