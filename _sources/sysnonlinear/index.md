# Нелинейные системы уравнений

В данном разделе рассматривается решение нелинейных систем уравнений

```{math}
\begin{split}
f_1(x_1, x_2, \ldots, x_n) &= 0,\\
f_2(x_1, x_2, \ldots, x_n) &= 0,\\
\vdots\\
f_n(x_1, x_2, \ldots, x_n) &= 0.
\end{split}
```

Кратко мы будем записывать системы выше в виде

```{math}
:label: sysnonlinear

\mathbf{f}(\mathbf{x}) = \mathbf{0},
```

где $\mathbf{f}$ функция вида $\real^n \to \real^n$.

Прежде всего отметим, что у системы {eq}`sysnonlinear` может быть несколько решений, а может не быть ни одного. Поэтому не существует общего метода для решения нелинейных систем, в отличие от решения нелинейного скалярного уравнения.