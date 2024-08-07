---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.16.4
kernelspec:
  display_name: Julia 1.10.4
  language: julia
  name: julia-1.10
---

```{eval-rst}
.. meta::
   :description: Задачи и упражения на интерполяцию.
   :keywords: задачи, упражнения, интерполяция, вычислительная математика, вычматы
```

```{code-cell}
:tags: [remove-cell]

include("interpolation.jl")
```

# Задания

## Вязкость разреженного газа

Многие корреляционные модели вязкости (например, {cite}`Assael1992`) предоставляют формулу для вычислений

```{math}
\eta_{\text{c}}(\upsilon, T),
```

где $\upsilon$ молярный объём и $T$ температура. Индекс $\text{c}$ отражает тот факт, что внутри формула параметризована для конкретного вещества. Как правило, параметризация производится по экспериментальным данным, а набор параметров для некоторых веществ приводится вместе с моделью.

Подобные корреляции включают в свою модель вязкость разреженного газа $\eta_{0\text{c}}$ как низкоплотный предел

```{math}
\eta_{\text{c}}(\upsilon, T) \to \eta_{0\text{c}}(T), \quad \upsilon \to \infty.
```

В свою очередь, низкоплотные пределы исследуются *аналитически*. В этом задании вам предстоит реализовать одну такую модель.

**Модель разреженного газа.**

%%% bib

Модель ниже приводится из {cite}`GolubevGnezdilov1971`.

Уравнение модели получено из физической кинетики. Выведено для низкоплотного состояния неполярного газа. Модель учитывает кинетическое взаимодействие и взаимодействие по [потенциалу Ленарда-Джонса](https://en.wikipedia.org/wiki/Lennard-Jones_potential) (Л-Ж) между частицами вещества.

Модель даёт уравнение

```{math}
:label: dilute

\eta_{0\text{c}}(T) = 8.44107\times 10^{-5}\cdot\frac{\sqrt{M T}f_\eta(T^*)}{\sigma^2 \Omega^{(2,2)*}(T^*)},
```

где

- $\eta_{0\text{c}}$ -- вязкость разреженного газа [Па с];
- $T$ -- температура газа [К];
- $M$ -- молярная масса газа [кг моль⁻¹];
- $T^*$ -- приведённая температура, $T^* = kT / \varepsilon$, где $\varepsilon/k$ [K]
  + $\varepsilon$ -- энергетический параметр в Л-Ж потенциале
  + $k$ -- постоянная Больцмана;
- $f_\eta(T^*)$ -- уточняющий фактор;
- $\sigma$ -- пространственный параметр в потенциале Л-Ж [Å];
- $\Omega^{(2,2)*}(T^*)$ -- приведённый интеграл столкновения;
- численный множитель получается после подстановки значений физических констант.

В уравнении {eq}`dilute` вещество $\text{c}$ определяется тремя параметрами $M$, $\sigma$ и $\varepsilon/k$.

Функции $f_\eta(T^*)$ и $\Omega^{(2,2)*}(T^*)$ в {cite}`GolubevGnezdilov1971` задаются в табличном виде, ссылки на таблицы приведены ниже

- табличное определение функции $f_\eta(T^*)$, {{ url_feta_table }};
- табличное определение функции $\Omega^{(2,2)*}(T^*)$, {{ url_omega22_table }}.

Таким образом, при реализации модели {eq}`dilute` возникает задача интерполяции.

**Задание.**

Вам необходимо реализовать модель разреженного газа {eq}`dilute` и посчитать вязкости для веществ из таблицы ниже в диапазоне температур $T\in[T_\min, T_\max]$.

```{code-cell}
:tags: [remove-input]

CO₂url = "https://webbook.nist.gov/cgi/fluid.cgi?D=0.001&TLow=220&THigh=1000&TInc=20&Applet=on&Digits=5&ID=C124389&Action=Load&Type=IsoChor&TUnit=K&PUnit=bar&DUnit=kg%2Fm3&HUnit=kJ%2Fmol&WUnit=m%2Fs&VisUnit=uPa*s&STUnit=N%2Fm&RefState=DEF"

CH₄url = "https://webbook.nist.gov/cgi/fluid.cgi?D=0.001&TLow=100&THigh=600&TInc=10&Applet=on&Digits=5&ID=C74828&Action=Load&Type=IsoChor&TUnit=K&PUnit=bar&DUnit=kg%2Fm3&HUnit=kJ%2Fmol&WUnit=m%2Fs&VisUnit=uPa*s&STUnit=N%2Fm&RefState=DEF"

O₂url = "https://webbook.nist.gov/cgi/fluid.cgi?D=0.001&TLow=60&THigh=1000&TInc=20&Applet=on&Digits=5&ID=C7782447&Action=Load&Type=IsoChor&TUnit=K&PUnit=bar&DUnit=kg%2Fm3&HUnit=kJ%2Fmol&WUnit=m%2Fs&VisUnit=uPa*s&STUnit=N%2Fm&RefState=DEF"

data = [
    "CO₂" 44.009 3.996 190 300 1000 Markdown.parse("[[ссылка]]($(CO₂url))");
    "CH₄" 16.043 3.822 137 100  600 Markdown.parse("[[ссылка]]($CH₄url)");
    "O₂"  31.999 3.433 113 100 1000 Markdown.parse("[[ссылка]]($O₂url)");
]

pretty_table(data;
    header=["Вещество", "M, г/моль", "σ, Å", "ε/k, K", "Tmin, K", "Tmax, K", "NIST"],
    backend=Val(:html),
    alignment=:c,
)
```

В качестве ответа вам необходимо предоставить следующее.

1. Julia-пакет, реализующий описанную выше модель разреженного газа, имеющий следующий интерфейс
    - Структура для задания вещества;
    - Функция вычисления вязкости по структуре и температуре $T$.
2. С помощью разработанного пакета подсчитать вязкости для веществ из таблицы в указанных диапазонах температур с шагом в 1 Кельвин;
3. Построить по графику $\eta_{0\text{c}}(T)$ для каждого вещества (форматы .jpg, .png или .pdf). На график нанести
    - Подсчитанную вязкость вещества из модели
    - Данные NIST по вязкости для вещества (5-6 точек). (Ссылка указана в таблице, необходимо только поменять ось Y на "Viscosity (μ Pa \* s)".)

Структура ответа

```
- Julia-пакет/
- Output data/
  - co2.tsv
  - co2.nist.tsv
  - ...
- Output plots/
  - co2.{jpg|png|pdf}
  - ...
- Скрипты, по которым подсчитаны данные (и построены графики)
- ...
```

```{note}
The National Institute of Standards and Technology (NIST) Сhemistry Webbook [[ссылка]](https://webbook.nist.gov/chemistry/) является базой данных по свойствам веществ. Часть данных экспериментальная, другая часть построена по корреляциям. Страница вещества с данными содержит список источников, где это можно уточнить.
```

```{admonition} Подсказки
:class: dropdown

Сгенерировать пакет можно с помощью команды `pkg> generate <package_name>`. Основной модуль будет лежать в директории `<package_name>/src/<package_name>.jl`.

Для работы с табличными данными есть встроенная библиотека `DelimitedFiles`.

Для генерации сеток см. `range`.

Для броадкаста по собственной структуре данных см. {ref}`sec:julia:broadcast`.

Для построения графиков можно. (1) Записать в файл данные и построить график какой-нибудь программой (табличный процессор или, например, gnuplot). (2) Воспользоваться [Plots.jl](https://docs.juliaplots.org/stable/).
```
