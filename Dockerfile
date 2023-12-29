# Docker образ для редактирования книги.

# Под капотом голая ubuntu.
# Пользователь - root.
FROM ubuntu:22.04

# Порт образа (и контейнеров на его основе), доступный для общения с хостом (локальной машиной, вашим компьютером). 
EXPOSE 80

# Home директория root пользователя.
WORKDIR /root/

COPY requirements.txt .
COPY Project.toml .

RUN <<EOF
apt update

# python 3 and wget
apt install -y python3 wget

# pip
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py

# Python packages
pip install -r requirements.txt

# Julia 1.9.4
wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.4-linux-x86_64.tar.gz
tar zxvf julia-1.9.4-linux-x86_64.tar.gz
rm julia-1.9.4-linux-x86_64.tar.gz
mv julia-1.9.4 /usr/local/bin/
## доступ к julia внутри контейнера по `julia`
ln -s /usr/local/bin/julia-1.9.4/bin/julia /usr/local/bin/julia

# Julia пакеты из Project.toml

## Инициализация глобального окружения julia (/root/.julia директория).
julia -e "using Pkg; Pkg.instantiate()"
## Проставляем наш Project.toml глобальным окружением Julia в контейнере.
cp Project.toml /root/.julia/environments/v1.9/Project.toml
## Грузим и устанавливаем пакеты, перечисленные в Project.toml.
julia -e "using Pkg; Pkg.resolve(); Pkg.instantiate(); Pkg.precompile()"

EOF
