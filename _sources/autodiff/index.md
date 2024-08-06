```{eval-rst}
.. meta::
   :description: Данный раздел посвящён автоматическому дифференцированию.
   :keywords: дуальное число, автоматическое дифференцирование вперед, автоматическое дифференцирование назад, backward mode, reverse accumulation, forward mode, forward accumulation, autodiff, forwarddiff, автоматическое дифференцирование, производная, вычислительная математика, вычматы
```

# Автоматическое дифференцирование

```{index} дифференцирование; автоматическое
```
**Автоматическое дифференцирование** является способом вычисления производных функции, заданной программно.
Этот вид дифференцирования опирается на правило дифференцирования сложной функции, представление функции в виде последовательности элементарных операций и перегрузке программных инструкций (функций, операторов).

Автоматическое дифференцирование не является численным дифференцированием.
Численное дифференцирование _приближает_ производную на основе её определения $f'(x) \approx (f(x) + f(x + \delta x)) / \delta x$.
В то время как автоматическое дифференцирование не требует введения шага $\delta x$, а производная вычисляется точно (в пределах машинной арифметики).

Автоматическое дифференцирование не является символьным дифференцированием.
Символьное дифференцирование преобразовывает выражения и применяет правила дифференцирования, чтобы получить _выражение_ производной $f'(x)$.
Впоследствии полученное выражение можно _вычислить_ (и даже создать исходный код для производной).
В автоматическом дифференцировании отсутствует программное представление функции в виде математического (символьного) выражения.

Сравнение способов дифференцирования показано на {numref}`Рисунке %s <autodiff:overview>`.

```{figure} static/baydin-2018-diff-approaches-overview.png
---
name: autodiff:overview
width: 640px
---

Способы дифференцирования.
Символьное вычисление даёт точный результат, но требует преобразования кода `f` к closed-form;
численное дифференцирование неточно ввиду погрешностей метода и округления;
автоматическое дифференцирование точно и позволяет использовать управляющие конструкции языка.
Источник: {cite}`Baydin2015`.
```

```{note}
С автоматическим дифференцированием связано понятие "дифференцируемого" программирования (differential programming).
Это подход к написанию кода, который учитывает возможность автоматически дифференцировать запрограммированные функции. 
```

В данной главе изложены темы дуальных чисел, графа вычислений, а также автоматического дифференцирования вперёд и назад.
Чтение главы вы можете начать с {numref}`Раздела {number} ({name}) <sec:autodiff:dualnumbers>`, пропустив {numref}`Раздел {number} ({name}) <sec:autodiff:complex_step>`.

```{tip}
Подробнее с автоматическим дифференцированием вы можете ознакомиться в следующих работах.

- {cite:ts}`KochenderferWheeler2019`.
- Дмитрий Кропотов.
  Автоматическое дифференцирование.
  ВМК МГУ, кафедра математических методов прогнозирования.
  https://youtu.be/za2LgI8JFCw.
- {cite:ts}`Baydin2015`.
```