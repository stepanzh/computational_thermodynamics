# Docker образ для редактирования книги.

# Под капотом голая ubuntu.
# Пользователь - root.
FROM ubuntu:22.04

# Порт образа (и контейнеров на его основе), доступный для общения с хостом (локальной машиной, вашим компьютером). 
EXPOSE 80

# Home директория root пользователя.
WORKDIR /root/

COPY python-requirements.txt .
COPY julia-requirements.toml .

RUN <<EOF
apt update

# python 3 and wget
apt install -y python3 curl

# pip
curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3

# Python packages
pip install -r python-requirements.txt


# Julia 1.10+
## Juliaup
curl -fsSL https://install.julialang.org | sh -s -- --yes --default-channel 1.10
## Экспорт команд julia и juliaup
. ~/.bashrc
# Julia пакеты из Project.toml

## Инициализация глобального окружения julia (/root/.julia директория).
julia -e "using Pkg; Pkg.instantiate()"
## Проставляем глобальное окружение Julia в контейнере.
## Не оставляйте `/root/Project.toml`!!! Иначе jupyter-book будет (неявно) ссылаться на него, а не на глобальное окружение.
##  Именно с этой целью файл с зависимостями Julia назван julia-requirements.toml, а не Project.toml.

cp julia-requirements.toml ~/.julia/environments/v1.10/Project.toml

## Грузим и устанавливаем пакеты, перечисленные в Project.toml.
julia -e "using Pkg; Pkg.resolve(); Pkg.instantiate(); Pkg.precompile()"

EOF
