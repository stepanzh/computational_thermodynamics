# Обусловленность линейных систем

По аналогии с обусловленностью вычисления скалярной функции, вводится понятие обусловленности линейной системы

$$
\mathbf{A} \mathbf{x} = \mathbf{b}.
$$

Нас интересует, как относительное изменение правой части повлияет на относительное изменение решения. Т.е. рассмотрим возмущенную систему

$$
\mathbf{A} (\mathbf{x} + \delta\mathbf{x}) = \mathbf{b} + \delta\mathbf{b}.
$$

И найдём оценку для величины

$$
\frac{
    \dfrac{\|\delta \mathbf{x}\|}{\|\mathbf{x}\|}}{
    \dfrac{\|\delta \mathbf{b}\|}{\|\mathbf{b}\|}
}
= \frac{\|\delta \mathbf{x}\|}{\| \delta\mathbf{b} \|}
  \frac{\| \mathbf{b} \|}{\|\mathbf{x}\|}
$$

Поскольку $\mathbf{b} = \mathbf{A}\mathbf{x}$, то $\|\mathbf{b}\| \le \|\mathbf{A}\| \|\mathbf{x}\|$. В свою очередь, из возмущённой системы следует, что $\delta\mathbf{x} = \mathbf{A}^{-1}\mathbf{b}$, отсюда получаем

$$
\frac{
    \dfrac{\|\delta \mathbf{x}\|}{\|\mathbf{x}\|}}{
    \dfrac{\|\delta \mathbf{b}\|}{\|\mathbf{b}\|}
} \le \| \mathbf{A}^{-1} \| \| \mathbf{A} \|.
$$ 

Так, вводится определение.

```{index} число обусловленности матрицы
```
````{proof:definition}
Числом обусловленности обратимой квадратной матрицы $\mathbf{A}$ называют

$$
\kappa(\mathbf{A}) = \| \mathbf{A}^{-1} \| \| \mathbf{A} \|.
$$

Значение $\kappa(\mathbf{A})$ зависит от выбора нормы. Для вырожденной матрицы $\kappa(\mathbf{A}) = \infty$.
````

Число обусловленности матрицы является числом обусловленности решения линейной системы. Выше выведено утверждение при возмущении правой части, аналогичное утверждение имеет место и при возмущении матрицы системы {cite}`fnc2017`.

````{proof:proposition} Обусловленность линейной системы
При возмущенной правой части системы $\mathbf{A} (\mathbf{x} + \delta \mathbf{x}) = \mathbf{b} + \delta\mathbf{b}$ справедлива оценка

$$
\frac{\|\delta\mathbf{x}\|}{\| \mathbf{x} \|} \le \kappa(\mathbf{A}) \frac{\|\delta\mathbf{b}\|}{\|\mathbf{b}\|}.
$$

При возмущённой матрицы системы $(\mathbf{A} + \delta\mathbf{A}) (\mathbf{x} + \delta \mathbf{x}) = \mathbf{b}$ справедлива оценка

$$
\frac{\|\delta\mathbf{x}\|}{\|\mathbf{x}\|} \le \kappa(\mathbf{A}) \frac{\|\delta\mathbf{A}\|}{\|\mathbf{A}\|}, \quad \|\delta\mathbf{A}\| \to 0.
$$
````

## Оценка ошибок

Обозначим для линейной системы $\mathbf{A}\mathbf{x}=\mathbf{b}$ найденное (численное) решение через $\tilde{\mathbf{x}}$. В большинстве случаев изучать ошибку $\mathbf{x} - \tilde{\mathbf{x}}$ невозможно, поскольку истинное решение неизвестно. Однако, можно показать {cite}`fnc2017`, что

$$
\frac{\|\mathbf{x} - \tilde{\mathbf{x}} \|}{\|\mathbf{x}\|}
\le \kappa(\mathbf{A}) \frac{\| \mathbf{b} - \mathbf{A}\tilde{\mathbf{x}}\|}{\|\mathbf{b}\|}.
$$

Эта оценка устанавливает связь между относительной ошибкой решения и относительной невязкой  решения. Невязку $\mathbf{b} - \mathbf{A}\tilde{\mathbf{x}}$, в свою очередь, подсчитать можно.
