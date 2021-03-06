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

"""
Решает уравнение вида `f`(x) = 0 методом Ньютона. Требует производную функцию `df` и
начальное приближение корня `x₁`. Выполняет не более `maxiter` итераций.
"""
function newton(f, df, x₁; maxiter=25, ftol=eps(), xtol=eps())
    x = float(x₁)
    for i in 1:maxiter
        fx = f(x)
        δx = - fx / df(x)
        x += δx
        if abs(fx) < ftol || abs(δx) < xtol
            return x
        end
    end
    error("Число итераций превышено.")
end

"""
Ищет корень уравнения `f`(x) = 0 методом секущих, начиная с приближений `x₁`, `x₂`.
Выполняет не более `maxiter` итераций, пока не будет выполнено либо
|`x₁` - `x₂`| < `xtol`, либо |`f(x₂)`| < `ftol`.
"""
function secant(f, x₁, x₂; maxiter=25, ftol=eps(), xtol=eps())
    y₁ = f(x₁)
    for i in 1:maxiter
        y₂ = f(x₂)
        xnew = (y₂ * x₁ - y₁*x₂) / (y₂ - y₁)
        x₁, y₁ = x₂, y₂
        x₂ = xnew

        if abs(y₂) < ftol || abs(x₂ - x₁) < xtol
            return x₂
        end
    end
    error("Число итераций превышено.")
end

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

"""
Вычисляет корень уравнения `f`(x) = 0 методом ложной позиции.
Начальный отрезок задаётся как [`x₁`, `x₂`]. Выполняет не более `maxiter`
итераций. Если при этом интервал не уменьшился до `xtol` или абсолютное значение
функции на нём до `ftol`, то выдаёт ошибку.
"""
function regulafalsi(f, x₁, x₂; maxiter=25, xtol=eps(), ftol=eps())
    if x₁ > x₂; x₁, x₂ = x₂, x₁; end
    y₁, y₂ = f.((x₁, x₂))
    sign(y₁) == sign(y₂) && error("Функция должна иметь разные знаки в концах отрезка")
    y₁ == 0 && return x₁
    y₂ == 0 && return x₂

    for i in 1:maxiter
        y₂ = f(x₂)
        xnew = (y₂*x₁ - y₁*x₂) / (y₂ - y₁)
        ynew = f(xnew)

        if sign(y₂) == sign(ynew)
            x₂, y₂ = xnew, ynew
        elseif sign(y₁) == sign(ynew)
            x₁, y₁ = xnew, ynew
        else
            return xnew
        end
        if abs(ynew) < ftol || abs(x₂ - x₁) < xtol
            return xnew
        end
    end
    error("Число итераций превышено.")
end

"""
    ridders(f, x₁, x₂[; maxiter=25, xtol=eps(), ftol=eps()])

Решает уравнение `f`(x) = 0 методом Риддерса на отрезке [`x₁`, `x₂`].
Если отрезок не уменьшится до `xtol`, или функция не уменьшится до `ftol`
за ≤ `maxiter` итераций, выдаёт ошибку.
"""
function ridders(f, x₁, x₂; maxiter=25, xtol=eps(), ftol=eps())
    if x₁ > x₂; x₁, x₂ = x₂, x₁; end
    y₁, y₂ = f.((x₁, x₂))
    y₁ * y₂ > 0 && error("Функция должна иметь разные знаки в концах отрезка")
    y₁ == 0 && return x₁
    y₂ == 0 && return x₂

    for i in 1:maxiter
        xmid = (x₁ + x₂) / 2
        ymid = f(xmid)
        xnew = xmid + (xmid - x₁) * sign(y₁) * ymid / sqrt(ymid^2 - y₁*y₂)
        ynew = f(xnew)

        ynew == 0 && return xnew

        if sign(ynew) == sign(y₂)
            x₂, y₂ = xnew, ynew
        elseif sign(ynew) == sign(y₁)
            x₁, y₁ = xnew, ynew
        end
        if abs(ynew) < ftol || abs(x₁ - x₂) < xtol
            return xnew
        end
    end
    error("Число итераций превышено.")
end

"""
Метод ITP поиска корня `f`(x) = 0 c точностью `xtol`.
"""
function itproot(f, x₁, x₂; xtol=eps(), ftol=eps(), κ₁=0.1, κ₂=2, n₀=1)
    if x₁ > x₂; x₁, x₂ = x₂, x₁; end
    y₁, y₂ = f(x₁), f(x₂)
    y₁ * y₂ > 0 && error("Функция должна иметь разные знаки в концах отрезка")
    y₁ == 0 && return x₁
    y₂ == 0 && return x₂

    nbisect = ceil(Int, log2((x₂-x₁)/xtol))
    maxiter = nbisect + n₀
    brackorig = x₂ - x₁

    for i in 1:maxiter
        # interpolate
        xf = (y₂*x₁ - y₁*x₂)/(y₂ - y₁)

        # truncate
        xmid = (x₁ + x₂)/2
        σ = sign(xmid - xf)
        δ = κ₁ * (x₂ - x₁)^κ₂ / brackorig
        xt = δ ≤ abs(xmid - xf) ? xf + copysign(δ, σ) : xmid

        # project
        r = xtol * 2.0^(maxiter - i) - (x₂ - x₁)/2
        xnew = abs(xt - xmid) ≤ r ? xt : xmid - copysign(r, σ)

        ynew = f(xnew)
        if sign(y₂) == sign(ynew)
            x₂, y₂ = xnew, ynew
        elseif sign(y₁) == sign(ynew)
            x₁, y₁ = xnew, ynew
        else  # ynew == 0
            return xnew
        end
        if abs(ynew) < ftol || abs(x₂ - x₁) < xtol
            return (x₁ + x₂)/2
        end
    end
    return (x₁ + x₂)/2
end


#=
==
== Линейные системы
==
=#

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

"Нестабильное LU-разложение квадратной матрицы `A`. Возвращает `L`, `U`."
function lufact(A::AbstractMatrix)
    n = size(A, 1)
    L = diagm(0 => ones(n))
    U = zeros(n, n)
    Aₖ = float(copy(A))

    for k in 1:n-1
        U[k, :] .= Aₖ[k, :]
        L[:, k] .= Aₖ[:, k] ./ U[k, k]
        Aₖ .-= L[:, k] * U[k, :]'
    end
    U[n, n] = Aₖ[n, n]
    return LowerTriangular(L), UpperTriangular(U)
end

"PLU-разложение матрицы `A`. Возвращает `L`, `U` и вектор-перестановку."
function plufact(A::AbstractMatrix)
    n = size(A, 1)
    p = zeros(Int, n)

    U = float(similar(A))
    L = similar(U)
    Aₖ = float(copy(A))

    for k in 1:n-1
        p[k] = argmax(abs.(Aₖ[:, k]))
        U[k, :] .= Aₖ[p[k], :]
        L[:, k] .= Aₖ[:, k] ./ U[k, k]
        Aₖ .-= L[:, k] * U[k, :]'
    end

    p[n] = argmax(abs.(Aₖ[:, n]))
    U[n, n] = Aₖ[p[n], n]
    L[:, n] = Aₖ[:, n] / U[n, n]

    return LowerTriangular(L[p, :]), UpperTriangular(U), p
end

#=
==
== Нелинейные системы
==
=#

"""
    newtonsys(f, x, J[; maxiter=50, xtol=1e-6, ftol=1e-6])

Решает нелинейную систему `f`(x) = 0 методом Ньютона, начиная с приближения `x`.
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
        if norm(δx) < xtol || norm(y) < ftol
            return x
        end
    end
    error("Превышено число итераций.")
end

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

#=
==
== ОДУ
==
=#

struct CauchyODEProblem{T<:Real,F<:Function}
    bound::Tuple{T,T}   # отрезок интегрирования
    u₀::T               # начальное значение интегрируемой функции
    f::F                # правая часть ОДУ
    function CauchyODEProblem(; f::Function, tstart::Real, tend::Real, u₀::Real)
        new{Float64, typeof(f)}(
            float.(tuple(tstart, tend)),
            float(u₀),
            f,
        )
    end
end

"""
    euler(problem; nsteps)

Решает задачу Коши `problem` явным методом Эйлера за `nsteps` шагов.
"""
function euler(problem::CauchyODEProblem; nsteps::Integer)
    u = Vector{Float64}(undef, nsteps + 1)
    u[1] = problem.u₀
    tstart, tend = problem.bound
    trange = range(tstart, tend; length=nsteps+1)
    τ = step(trange)
    @inbounds for i in 1:nsteps
        tᵢ, uᵢ = trange[i], u[i]
        u[i+1] = uᵢ + τ * problem.f(tᵢ, uᵢ)
    end
    return trange, u
end

"""
    rk4(problem; nsteps)

Решает задачу Коши `problem` явным 4-этапным методом Рунге-Кутта за `nsteps` шагов.
"""
function rk4(problem::CauchyODEProblem; nsteps::Integer)
    u = Vector{Float64}(undef, nsteps + 1)
    u[1] = problem.u₀
    tstart, tend = problem.bound
    trange = range(tstart, tend; length=nsteps+1)
    τ = step(trange)
    for i in 1:nsteps
        tᵢ, uᵢ = trange[i], u[i]

        k₁ = problem.f(tᵢ, uᵢ)
        k₂ = problem.f(tᵢ + τ/2, uᵢ + τ*k₁/2)
        k₃ = problem.f(tᵢ + τ/2, uᵢ + τ*k₂/2)
        k₄ = problem.f(tᵢ + τ, uᵢ + τ * k₃)

        u[i+1] = uᵢ + τ * (k₁ + 2*(k₂ + k₃) + k₄)/6
    end
    return trange, u
end

"""
    rk23(problem; tol[, maxsteps, maxadjuststeps])

Решает задачу Коши `problem` адаптивным методом Богацкого-Шампина.
Погрешность вычислений задаётся `tol`, а максимальное количество шагов
интегрирования `maxsteps`. Число шагов, разрешённое для адаптации шага `maxadjuststeps`.
"""
function rk23(problem::CauchyODEProblem;
    tol::Real,
    maxsteps::Integer=10000,
    maxadjuststeps::Integer=20,
)
    t₀, T = problem.bound
    trange = [t₀]
    u = [problem.u₀]
    k₁ = problem.f(t₀, problem.u₀)
    τ = 0.5 * tol^(1/3)

    for i in 1:maxsteps
        tᵢ, uᵢ = trange[i], u[i]

        tᵢ == T && break

        if tᵢ + τ == tᵢ
            @warn "Достигнут предел машинной точности по τ"
            break
        end

        for j in 1:maxadjuststeps
            k₂ = problem.f(tᵢ + τ/2, uᵢ + τ*k₁/2)
            k₃ = problem.f(tᵢ + 3τ/4, uᵢ + 3τ*k₂/4)
            unew2 = uᵢ + τ*(2k₁ + 3k₂ + 4k₃)/9  # РК2 приближение
            k₄ = problem.f(tᵢ + τ, unew2)

            Δ = τ * (-5k₁/72 + k₂/12 + k₃/9 - k₄/8)  # разница РК2 и РК3 приближений
            err = norm(Δ, Inf)
            maxerr = tol * (1 + norm(uᵢ, Inf))

            accepted = err < maxerr
            if accepted
                push!(trange, tᵢ + τ)
                push!(u, unew2)
                k₁ = k₄  # FSAL: k₄ = f(tᵢ + τ, uᵢ₊₁) == new k₁
            end

            # подбор нового шага
            q = 0.8 * (maxerr/err)^(1/3)    # оценка шага из погрешности
            q = min(q, 4.0)                 # ограничиваем максимальное увеличение
            τ = min(q*τ, T - trange[end])   # не выходим за предел T

            accepted && break

            j == maxadjuststeps && error("Число шагов по подбору τ превышено.")
        end

        i == maxsteps && @warn "Число шагов превышено, конечное время не достигнуто"
    end
    return trange, u
end
