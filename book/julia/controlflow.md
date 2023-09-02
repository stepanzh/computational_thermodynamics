# Управляющие конструкции

Подробнее в мануале **[[url]](https://docs.julialang.org/en/v1/manual/control-flow/)**. Здесь освещены не все конструкции и не так подробно.

## Ветвление

Основная конструкция это `if-elseif-else` блок.

```julia-repl
julia> x, y = 10, 20;

julia> if x < y
           "x is less than y"
       elseif x > y
           "x is greater than y"
       else
           "x is equal to y"
       end
"x is less than y"
```

- В `if` и `elseif` должно стоять boolean выражение;
- Количество `elseif` не ограничено.

Блок `if-elseif-else`, как и `begin-end` является выражением и возвращает значение. В примере выше возвращается результат первой ветви исполнения -- строка "x is less than y".

Также в вашем распоряжении тернарный оператор `cond ? whentrue : whenfalse`.

```julia-repl
julia> count = 24;

julia> "$count apple$(count > 1 ? "s" : "")"
"24 apples"
```

Помимо этого, в Julia есть `try/catch` для обработки программных исключений.

## Циклы

Julia предоставляет два цикла: `while` и `for`.

```julia-repl
julia> i = 1;

julia> while i <= 5
           println(i)
           i += 1
       end
1
2
3
4
5
```

Цикл `while` создаёт собственное пространство имён, что может вызвать фрустрацию. В REPL всё пространство имён глобальное, поэтому пример выше работает. Если же вы используете `while`-цикл в глобальном пространстве скрипта, то при обращении к переменной `i` будет ошибка. В этом случае можно внутри цикла указать `global i`, чтобы внутри `while` она была видна. Более лучший вариант это обернуть пример выше в функцию, функции создают собственное пространство имён и конфликта со вложенным в неё `while` не будет.

У `for`-цикла следующий синтаксис.

```julia
for item in iterator
    ...
end
```

Переменная цикла `item` создаётся внутри видимости цикла `for` автоматически. После исполнения цикла она недоступна, если не была объявлена во внешней области видимости.

```julia-repl
julia> for j in 1:3
           println(j)
       end
1
2
3

julia> j
ERROR: UndefVarError: j not defined
```

Здесь использован *range operator* `start:stop`, создающий генератор арифметической прогрессии.
Также есть функция `range`, позволяющая создавать такие генераторы через длину последовательности.

```julia-repl
help?> 1:3
  (:)(start, [step], stop)

  Range operator. a:b constructs a range from a to b with a step size of 1 (a UnitRange),
  and a:s:b is similar but uses a step size of s(a StepRange).

help?> range(1, 3)
  range(start, stop, length)
  range(start, stop; length, step)
  range(start; length, stop, step)
  range(;start, length, stop, step)

  Construct a specialized array with evenly spaced elements and optimized storage from the arguments...
```

Итерировать можно и по коллекциям. Ниже пример для кортежа `Tuple`.

```julia-repl
julia> for j in (1, 2, "hello")
           println(j)
       end
1
2
hello
```

Доступно множество утилит для итерирования: `zip`, `enumerate`, `drop`, `rest`...

```julia-repl
julia> for (i, val) in enumerate((1, 2, "hello"))
           println("$i: $val")
       end
1: 1
2: 2
3: hello
```

Для циклов доступны стандартные команды досрочного завершения итерации `continue` и всего цикла `break`.

Циклы могут быть вложенными. Для вложенного `for`-цикла существует альтернативный вариант синтаксиса.

::::{tab-set}
:::{tab-item} Вложенный `for`
```julia-repl
julia> for j in 1:2
           for i in 3:4
               println("i = $i, j = $j")
           end
       end
i = 3, j = 1
i = 4, j = 1
i = 3, j = 2
i = 4, j = 2
```
:::
:::{tab-item} Альтернативный синтаксис
```julia-repl
julia> for j in 1:2, i in 3:4
           println("i = $i, j = $j")
       end
i = 3, j = 1
i = 4, j = 1
i = 3, j = 2
i = 4, j = 2
```
:::
::::
