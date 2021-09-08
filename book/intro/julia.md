---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
kernelspec:
  display_name: Julia
  language: julia
  name: julia-1.6
---

% substitutions: urldownload

# Основы языка программирования Julia

В данном разделе излагаются основные инструменты языка Julia, которые понадобятся в практикуме.

## Инструкции по установке

Ниже расположены инструкции по установке исполнителя языка Julia для Linux-based операционных систем (ОС), MacOS и ОСWindows.

```{admonition} Инструкция для пользователей Linux-based ОС
:class: dropdown

Инструкция появится позже.
```

```{admonition} Инструкция для пользователей MacOS
:class: dropdown

1. Скачать `Julia-1.6.app`-пакет с официального сайта языка {{ urldownload }};
2. Стандартно для `.app` приложений установить;

Исполнитель языка находится здесь

:::
/Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia
:::

Вы можете доступиться до него через терминал и запустить [Julia REPL](repl_guide).

Однако, чтобы в будущем не доступаться до Julia по абсолютному пути, добавьте `alias` в rc файл вашего терминала.

::::{admonition} Как найти rc файл
:class: dropdown

Узнайте ваш `shell`

:::console
% echo $SHELL
/bin/zsh
:::

- Если это `zsh`, то файл для настройки `~/.zshrc`.
    - Если файл отсутствует, создайте его `touch ~/.zshrc`.
- Если это `bash`, то файл для настройки `~/.bash_console`.
    - Если файл отсутствует, создайте его `touch ~/.bash_console`.
::::

Добавление `alias` (пример для `zsh`, для `bash` аналогично):

:::console
% open ~/.zshrc

# в открывшемся редакторе будет содержимое `.zshrc`, добавьте в файл строчку
alias julia='/Applications/Julia-1.6.app/Contents/Resources/julia/bin/julia'
# сохраните .zshrc

% source ~/.zshrc  # изменения вступят в силу (можно также просто перезапустить терминал)
% julia --version  # проверка, всё ли работает
julia version 1.6.2
:::
```

```{admonition} Инструкция для пользователей ОС Windows
:class: dropdown

Инструкция появится позже.
```

(repl_guide)=
## Интерактивный режим: Julia REPL

```{margin}
Это аналогично интерактивному режиму работы в Python.
```
Знакомство языка начнём с интерактивного режима. Для этого необходимо запустить Julia REPL (Read-Evaluate-Print-Loop).

На unix ОС (Linux-based, MacOS) в терминале необходимо набрать команду `julia`

```console
% julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.6.2 (2021-07-14)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia>
```


## Переменные

В языке Julia стандартный синтаксис присвоения значения переменной

```{code-cell}
x = 5
println(x)
a, b = 4, 3
println(a, ' ', b)
```
