---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.16.0
kernelspec:
  display_name: Julia 1.9.4
  language: julia
  name: julia-1.9
myst:
  substitutions:
    julia_logo: "<img src=\"https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia-dots.svg\" style=\"height: 1em;\">"
---

```{eval-rst}
.. meta::
   :description: Введение в программирование на языке Julia.
   :keywords: julia, программирование, введение, учебник
```

# Основы языка программирования Julia

```{epigraph}
Julia: come for the syntax, stay for the speed

-- *[Nature](https://www.nature.com/articles/d41586-019-02310-3)*
```

**Почему {{ julia_logo }} Julia?**

Язык [Julia](https://julialang.org/) создавался как решение *two-languages problem* в научной и вычислительной среде {cite}`Julia2017`. На одних языках просто писать программы, но они медленно исполняются (например, на Python), с другой стороны, в языках с быстрым исполнением программ сложный синтаксис (например, C/C++, Fortran).

Так, язык Julia созданный в 2012 году, развивается с фокусом на математические вычисления при сохранении удобного синтаксиса. В языке богатая стандартная библиотека, которая легко расширяется под пользовательские структуры данных.

**Кто уже пользуется?**

Julia продолжает набирать популярность. Этот язык уже используется в физике, машинном обучении, финансовых моделях, биологии, медицине, геофизике... А в список пользователей входят: MIT, Princeton, NASA, CISCO, IBM, Adobe...[^usage_proof]

[^usage_proof]: https://juliacomputing.com/case-studies/, https://en.wikipedia.org/wiki/Julia_(programming_language)#Notable_uses

**Как изучить?**

В данном разделе излагаются основные инструменты языка Julia, которые понадобятся в практикуме. Дополнительные материалы по изучению языка находятся в Приложении {ref}`materials_julia`.

```{proof:demo} Синтаксис Julia
```

```{raw} html
<div class="demo">
```

Ниже показано решение уравнения $\exp{x} + \log{x} - 2 = 0$ методом деления пополам.
Можете оценить синтаксис Julia по этому короткому примеру.

```{code-cell}
:tags: [remove-output]

function bisection(f, xl, xr; xtol=eps(), ftol=eps())
    @assert xl < xr

    yl, yr = f.((xl, xr))
    @assert sign(yl) != sign(yr)

    abs(yl) < ftol && return xl
    abs(yl) < ftol && return xr
    
    maxiter = ceil(Int, log2((xr-xl)/xtol))
    
    for i in 1:maxiter
        xmid = (xr + xl) / 2
        ymid = f(xmid)
        
        if sign(yr) == sign(ymid)
            xr, yr = xmid, ymid
        elseif sign(yl) == sign(ymid)
            xl, yl = xmid, ymid
        else
            return xmid
        end
        abs(ymid) < ftol && return xmid
    end
    return (xr + xl)/2
end
```

```{code-cell}
f(x) = exp(x) + log(x) - 2
xsol = bisection(f, 0.1, 2)
```

```{code-cell}
using Plots
using LaTeXStrings

plot(f; label=L"\exp\ x + \log\ x - 2", xlim=(0, 1.5), ylim=(-6, 6), xlabel=L"x", ylabel=L"f(x)")
scatter!([xsol], [f(xsol)]; label="метод бисекции, корень $(round(xsol; digits=5))")
```

```{raw} html
</div>
```
