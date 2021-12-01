# Предварительные сведения

```{proof:definition} Градиент

Градиент функции $\nabla f(\mathbf{x}) \in \real^n$ называется вектор из частных производных

:::{math}
\nabla f(\mathbf{x}) = \begin{bmatrix}
\frac{\part f}{\part x_1}\\
\frac{\part f}{\part x_2}\\
\vdots\\
\frac{\part f}{\part x_n}\\
\end{bmatrix}.
:::
```

```{proof:definition} Гессиан

Гессианом функции $\nabla^2 f(\mathbf{x})$ называют матрицу из вторых частных производных

:::{math}
\nabla^2 f(\mathbf{x}) = \begin{bmatrix}
\frac{\part^2 f}{\part x_1 \part x_1}(\mathbf{x}) & \frac{\part^2 f}{\part x_1 \part x_2}(\mathbf{x}) & \cdots & \frac{\part^2 f}{\part x_1 \part x_n}(\mathbf{x})\\
\frac{\part^2 f}{\part x_2 \part x_1}(\mathbf{x}) & \frac{\part^2 f}{\part x_2 \part x_2}(\mathbf{x}) & \cdots & \frac{\part^2 f}{\part x_2 \part x_n}(\mathbf{x})\\
\vdots & \vdots & & \vdots \\
\frac{\part^2 f}{\part x_n \part x_1}(\mathbf{x}) & \frac{\part^2 f}{\part x_n \part x_2}(\mathbf{x}) & \cdots & \frac{\part^2 f}{\part x_n \part x_n}(\mathbf{x})
\end{bmatrix}.
:::

Гессиан является квадратной матрицей размера $n$ и в случае дважды гладкой $f$ симметричен.
```

```{proof:theorem} Разложение Тейлора
Пусть функция $f: \real^n \to \real$ гладкая, тогда

:::{math}
f(\mathbf{x} + \mathbf{d}) = f(\mathbf{x}) + \nabla f(\mathbf{x} + t\: \mathbf{d})^\top \mathbf{d},\quad t \in (0, 1).
:::

Если при этом $f$ -- дважды гладкая, то верно

:::{math}
f(\mathbf{x} + \mathbf{d}) = f(\mathbf{x})
+ \nabla f(\mathbf{x})^\top \mathbf{d}
+ \frac{1}{2}\mathbf{d}^\top \nabla^2 f(\mathbf{x} + t\:\mathbf{d})\mathbf{d}
,\quad t \in (0, 1).
:::
```

```{proof:definition} Положительно определённая матрица
Положительно определённой называют симметричную матрицу $\mathbf{A}$, такую, что

:::{math}
\mathbf{x}^\top \mathbf{A} \mathbf{x} > 0, \quad \forall \mathbf{x} \neq \mathbf{0}.
:::

Если неравенство нестрогое, то матрицу называют положительно полуопределённой.
```

```{proof:definition} Строгий локальный минимум
Вектор $\mathbf{x}^*$ называется строгим локальным минимумом функции $f$, если существует окрестность точки, в которой $f(\mathbf{x}^*) < f(\mathbf{x})$, $\mathbf{x}^* \neq \mathbf{x}$.
```

```{proof:theorem} Достаточные условия минимума
Пусть

- гессиан функции $\nabla^2 f$ непрерывен в окрестности $\mathbf{x}^*$,
- градиент функции $\nabla f (\mathbf{x}^*) = 0$,
- и гессиан $\nabla^2 f (\mathbf{x}^*)$ положительно-определён,

тогда $\mathbf{x}^*$ является строгим локальным минимумом $f$.
```

```{proof:definition} Направление убывания функции
Направлением убывания функции в точке $\mathbf{x}$ будем называть вектор $\mathbf{d}$, для которого найдутся малые $t \in (0, \epsilon)$ такие, что

:::{math}
f(\mathbf{x} + t\:\mathbf{d}) < f(\mathbf{x}).
:::

Для направления убывания в точке $\mathbf{x}$ верно

:::{math}
\nabla f(\mathbf{x})^\top \mathbf{d} < 0.
:::
```
