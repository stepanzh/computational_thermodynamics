# Уравнение состояния ван дер Ваальса

Для решения системы {eq}`ptstab_chempot_stationary_system_final` необходимо знать коэффициент летучести $\varphi_i$ (или вид свободной энергии Гиббса, или вид химпотенциала). Фактически, мы можем решать эту задачу для разных физических моделей флюида. В термодинамике, моделью вещества является уравнение состояния.

В этом разделе мы в качестве примера воспользуемся уравнением состояния ван дер Ваальса.

Для одного вещества уравнение ван дер Ваальса определяется как
```{math}
:label: ptstab_vdw_eos_component

P = \frac{N R T}{V - N b} - \frac{N^2 a}{V^2} = \frac{R T}{\upsilon - b} - \frac{a}{\upsilon^2}
```
где $a$ и $b$ коэффициенты уравнения, а $N = \sum_i N_i$ -- общее количество вещества.

В случае смеси коэффициенты уравнения зависят от состава
```{math}
:label: ptstab_vdw_eos_mixture

P = \frac{N R T}{V - \mathcal{B(\boldsymbol{N})}} - \frac{\mathcal{A}(\boldsymbol{N})}{V^2}.
```
Таким образом, уравнения для одного компонента и смеси имеют одинаковый функциональный вид.

```{index} правило ; смешения
```
Формулы для коэффициентов смеси $\mathcal{A}$, $\mathcal{B}$ называют **правилами смешения**. Одно из простых правил смешения следующее[^mixing_rule] {cite}`kwak_mansoori_1986`
```{math}
:label: ptstab_vdw_eos_mixing_rules

\begin{aligned}
\mathcal{A} &= \sum_i \sum_j N_i N_j a_{i j},\ a_{i j} = \sqrt{a_i a_j},
\\ \mathcal{B} &= \sum_i N_i b_i.
\end{aligned}
```
[^mixing_rule]: На практике для парного коэффициента $a_{i j}$ вводят поправку в виде $a_{i j} = (1 - k_{i j})\sqrt{a_i a_j}$, повышающую точность уравнения на каких-нибудь экспериментальных данных, например, на данных по составам в фазовом равновесии. Для учебных целей поправки положены нулевыми $k_{i j} = 0$.



## Вид коэффициента летучести

Для уравнений состояния, выражающих явно давление, коэффициент летучести может быть найден интегрированием {cite}`Brusilovsky2002`
```{math}
:label: ptstab_fugacity_coef_integral

\ln{\varphi_i} = \int_V^\infty \bigg[\frac{1}{R T} \frac{\partial P}{\partial N_i}(\boldsymbol{N}, \xi, T) - \frac{1}{\xi} \bigg] d\xi - \ln{z}
```
где $z = P V / N R T$ -- сжимаемость (сверхсжимаемость, z-фактор) вещества, для идеального газа $z = 1$.

Используя {eq}`ptstab_fugacity_coef_integral` для уравнения ван дер Ваальса {eq}`ptstab_vdw_eos_mixture` с правилами смешения {eq}`ptstab_vdw_eos_mixing_rules` получим
```{math}
:label: ptstab_fugacity_coef_vdw

\begin{aligned}
\ln{\varphi_i} &=
\ln{\frac{V}{V-\mathcal{B}}} + \frac{b_i N}{V - \mathcal{B}} - \frac{\mathcal{A}_{N_i}}{R T V} - \ln{z}
\\ &= -\ln(z - B) + \frac{b_i P}{RT(z - B)} - \frac{P (2 \sum_j x_j a_{i j})}{z (R T)^2}
\end{aligned}
```
где
```{math}
:label: ptstab_fugacity_coef_vdw_coefficients

\begin{aligned}
\mathcal{A}_{N_i} \equiv \partial\mathcal{A}/\partial N_i = 2\sum_j N_j a_{i j}
\\ A = \frac{\mathcal{A} P}{N^2 R^2 T^2},\quad B = \frac{\mathcal{B} P}{N R T}
\end{aligned}
```



## Объём фазы

Как видно, для вычисления $\ln \varphi_i$ {eq}`ptstab_fugacity_coef_vdw` необходимо знать объём $V$ или сжимаемость $z$ фазы, тогда как исходная задача ставится для состава, давления и температуры. Обычно находят сжимаемость $z = P V / N R T$, а объём же, если нужно, из неё пересчитывают.

Перепишем уравнение ван дер Ваальса {eq}`ptstab_vdw_eos_mixture` относительно сжимаемости
```{math}
:label: ptstab_vdw_eos_cubic_z

z^3 + (- B - 1) z^2 + A z - A B = 0,
```
где коэффициенты $A$ и $B$ определены ранее {eq}`ptstab_fugacity_coef_vdw_coefficients`. Из-за вида уравнения {eq}`ptstab_vdw_eos_cubic_z` уравнение состояния ван дер Ваальса относят к кубическому семейству.

Уравнение на сжимаемость {eq}`ptstab_vdw_eos_cubic_z` может иметь до двух различных действительных корней. Меньший из них соотвествует жидкой (плотной) фазе, а больший корень -- газовой (менее плотной) фазе.



## Вычисление коэффициента летучести

Итак, в нашей (и вообще в изобарно-изотермической) задаче вычисление коэффициента летучести для кубического уравнения состояния требует нескольких шагов.

1. Определить, для какой фазы считается коэффициент летучести;
2. Решить кубическое уравнение {eq}`ptstab_vdw_eos_cubic_z` на сжимаемость;
3. Выбрать корень кубического уравнения в соответствии с заданной фазой;
4. Посчитать коэффициент летучести {eq}`ptstab_fugacity_coef_vdw`.



## Упражнения

1. Получите выражение {eq}`ptstab_fugacity_coef_vdw` коэффициента летучести для смеси веществ, заданных уравнением ван дер Ваальса.