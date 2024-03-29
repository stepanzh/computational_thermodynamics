```{eval-rst}
.. meta::
   :description: В этом разделе мы рассмотрим метод BFGS для решения задачи оптимизации.
   :keywords: bfgs, бфгс, квазиньютоновский, метод ньютона, разложение холецкого, поиск вдоль направления, line search, оптимизация, минимизация, вычислительная математика, вычматы
```

# Метод BFGS

{ref}`Метод Ньютона <sec:optim:newton>` требует (дорогой) поддержки положительной определённости матрицы Гессе и, вообще, вычисления матрицы.
Одной из альтернатив методу Ньютона являются _квазиньютоновские_ методы.

Квазиньютоновские методы оптимизации также используют ньютоновское направление убывания.
Однако, в отличие от метода Ньютона, эти методы не вычисляют гессиан на итерации, а обновляют его по некоторому правилу (например, используя матрицу Гессе с предыдущей итерации).
Методы отличаются между собой формулой обновления, ниже мы рассмотрим широко-используемый *метод Бройдена -- Флетчера -- Гольдфарба -- Шанно* (*Broyden -- Fletcher -- Goldfarb -- Shanno*) или, более кратко, метод *BFGS*.


## Метод

Обозначим приближение гессиана на $k$-ой итерации через $\mathbf{B}_k$. После того, как направление вычислено как направление Ньютона

```{math}
:label: optim_bfgs_dir

\mathbf{d}_k = -\mathbf{B}_k^{-1} \nabla f(\mathbf{x}_k),
```

находится новое приближение решения

```{math}
\mathbf{x}_{k+1} = \mathbf{x}_k + \alpha \mathbf{d}_k,
```

где $\alpha$ подобрано линейным поиском.

Поскольку $\mathbf{x}_{k+1}$ известно, можно учесть кривизну функции по векторам

```{math}
\mathbf{s}_k = \mathbf{x}_{k+1} - \mathbf{x}_k
,\quad \mathbf{y}_k = \nabla f(\mathbf{x}_{k+1}) - \nabla f(\mathbf{x}_k),
```

используя их для нового приближения гессиана $\mathbf{B}_{k+1}$.

В методе BFGS используется следующее правило обновления

```{proof:definition} Правило BFGS
:::{math}
:label: optim_bfgs_rule

\mathbf{B}_{k+1} = \mathbf{B}_k
  + \frac{\mathbf{y}_k\mathbf{y}_k^\top}{\mathbf{y}_k^\top\mathbf{s}_k}
  - \frac{
        \mathbf{B}_k \mathbf{s}_k \mathbf{s}_k^\top \mathbf{B}_k^\top
    }{
        \mathbf{s}_k^\top\mathbf{B}_k\mathbf{s}_k
    }
.
:::
```

Однако, $\mathbf{B}_k$ требует решение линейной системы {eq}`optim_bfgs_dir`. Чтобы этого не делать, можно аналитически обратить {eq}`optim_bfgs_rule` и работать с обратным приближением гессиана $\mathbf{B}^{-1}_k$, тогда {eq}`optim_bfgs_dir` уже будет представлен не систему уравнений, а матрично-векторное умножение.

```{proof:definition} Правило BFGS для обратного гессиана
:::{math}
\mathbf{B}^{-1}_{k+1} = \mathbf{B}^{-1}_k
  + \frac{
        (\mathbf{s}_k^\top \mathbf{y}_k + \mathbf{y}_k^\top \mathbf{B}^{-1}_k \mathbf{y}_k)
    }{
        (\mathbf{s}_k^\top \mathbf{y}_k)^2
    } (\mathbf{s}_k \mathbf{s}_k^\top)
  - \frac{
        \mathbf{B}^{-1}_k \mathbf{y}_k \mathbf{s}_k^\top
        + \mathbf{s}_k \mathbf{y}_k^\top \mathbf{B}^{-1}_k
    }{
        \mathbf{s}^\top_k \mathbf{y}_k
    }
.
:::
```

В качестве начального приближения $\mathbf{B}_0$ используют обычно истинный гессиан или его модифицированное разложение Холецкого. Также используют диагональные матрицы, например, единичную или построенную по разностной схеме из градиента в начальной точке.

Для начального приближения обратного гессиана можно также использовать диагональные матрицы. Если требуется истинный обратный гессиан, можно перед запуском алгоритма высчитать его один раз. Кроме того, для устойчивости алгоритма, можно сделать и модифицированное разложение Холецкого для $\mathbf{B}^{-1}_0$.

## Реализация

Модифицированное разложение Холецкого приведено в {ref}`Приложении <appendix_ch_mcholesky>`.

Ниже дан шаблон метода BFGS с обратным гессианом, который нужно будет завершить в домашнем задании.

Структура данных для результата алгоритма

```julia
struct BFGSResult{T<:Real}
    converged::Bool      # метод сошёлся
    argument::Vector{T}  # найденный минимум
    iters::Int           # число прошедших итераций
end
```

```{proof:function} bfgs

**Метод BFGS (шаблон)**

:::julia
"""
    bfgs(f, ∇f, x0[, invH0; maxiter=200, gtol=1e-5])

Поиск минимума методом BFGS функции `f` с градиентом `∇f`, начиная с `x0`.
Оптимизация длится не более `maxiter` итераций, при этом, если норма градиента не превышает `gtol`, завершается досрочно.

- `f::Function`: по вектору x возвращает значение функции, `f(x)`: `Vector` → `Real`;
- `∇f::Function`: по вектору x возвращает градиент `f`, `∇f(x)`: `Vector` → `Vector`;
- `invH0::Matrix`: приближение обратного гессиана в `x0`, по умолчанию -- единичная матрица.
"""
function bfgs(f, ∇f, x0, invH0=diagm(0=>ones(length(x)));
    maxiter=200,
    gtol=1e-5,
)
    x = float.(x0)
    
    # проверяем сходимость по норме-2 градиента
    g = ∇f(x)
    # ... && BFGSResult(true, x, 0)

    # обратный квази-гессиан
    # invB = ...

    for i in 1:maxiter
        # выбор направления
        # d = ...
        
        # подбор шага вдоль d
        # α = ...
        # ... && return BFGSResult(false, x, i)  # α не найдено
        
        # совершение шага
        # x = ...
        
        # проверка сходимости
        g = ∇f(x)
        # ... && return BFGSResult(true, x, i)

        # обновление обратного квази-гессиана для следующей итерации
        # invB = ...
    end
    return BFGSResult(false, x, maxiter)
end
:::
```
