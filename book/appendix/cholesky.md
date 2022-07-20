(appendix_ch_mcholesky)=
# Разложение Холецкого

Стандартное разложение Холецкого доступно в стандартной библиотеке `LinearAlgebra.cholesky`.

Ниже представлено модифицированное разложение Холецкого по (Gill, Murray & Wright, Practical optimization (1981), p.111).

```{proof:function} γξ
:::julia
"""
    γξ(A::AbstractMatrix)

Наибольшие абсолютные значения на диагонали и вне диагонали симметричной матрицы `A`.
"""
function γξ(A::AbstractMatrix)
    n = LinearAlgebra.checksquare(A)
    γ = ξ = zero(eltype(A))
    for j in 1:n
        for i in 1:j-1
            ξ = max(ξ, abs(A[i,j]))
        end
        γ = max(γ, abs(A[j,j]))
    end
    return γ, ξ
end
:::
```

```{proof:function} mcholesky!

**Модифицированное разложение Холецкого**

:::julia
"""
    mcholesky!(A::AbstractMatrix)

In-place модифицированное разложение Холецкого матрицы `A`.
Возвращает объект разложения типа `LinearAlgebra.Cholesky`.

Gill, Murray & Wright, Practical optimization (1981), p.111
"""
function mcholesky!(A::AbstractMatrix{T}; δ=convert(T, 1e-3)) where {T}
    n = LinearAlgebra.checksquare(A)
    γ, ξ = γξ(A)
    ν = max(1, sqrt(n^2 - 1))
    β² = max(γ, ξ / ν, eps(T))
    θ = zero(T)
    u = UpperTriangular(A)
    c = u
    @inbounds for j in 1:n
        c_jj = A[j,j]
        θ = zero(c_jj)
        for k in 1:j-1
            u[k,j] /= u[k,k]
        end
        for i in j+1:n
            c_ij = c[j,i]
            for k in 1:j-1
                c_ij -= u[k,j] * c[k,i] / u[k,k]
            end
            θ = max(abs(c_ij), θ)
            c[j,i] = c_ij
        end
        d_j = max(abs(c_jj), θ^2 / β², δ)
        u[j,j] = sqrt(d_j)
        for i in j+1:n
            c[i,i] -= (c[j,i] / u[j,j])^2
        end
    end
    return Cholesky(A, 'U', 0)
end

:::
```