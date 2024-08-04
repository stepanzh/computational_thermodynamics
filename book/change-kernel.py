# Обновление julia kernel для MyST файлов.
# Скрипт итерируется по файлам книге, отыскивая Markdown файлы с заголовком от MyST.
# 
# ПРЕДУПРЕЖДЕНИЕ
# ПЕРЕД ЗАПУСКОМ ПРОВЕРЬТЕ ПЕРЕМЕННЫЕ JUPYTER_KERNELSPEC_FOR_JULIA и BOOK_LOCATION_INSIDE_CONTAINER.
#
# Подразумевается, что должен менять эту часть файла
# ---
# jupytext:
#   formats: md:myst
#   text_representation:
#     extension: .md
#     format_name: myst
#     format_version: 0.13      --> (автоматически)
#     jupytext_version: 1.16.4  --> (автоматически)
# kernelspec:
#   display_name: Julia 1.10.4  --> (автоматически)
#   language: julia
#   name: julia-1.10            --> JUPYTER_KERNELSPEC_FOR_JULIA
# ---
#
# Степан Захаров stepanzh@gmail.com
# 2024


import os
import subprocess

# Название ядра jupyter, созданного IJulia
JUPYTER_KERNELSPEC_FOR_JULIA = 'julia-1.10'
BOOK_LOCATION_INSIDE_CONTAINER = '/root/book/'


def show_container_warning():
    print('Обнаружен запуск из-под пользовательской машины')
    print('Запустите этот скрипт из docker-контейнера')




# Проверка на то, что скрипт исполняется в контейнере

# Пытаемся прочесть содержание /run/systemd/container
# На моём компе в контейнере прописано 'docker'
_container_file = '/run/systemd/container'
if not os.path.exists(_container_file):
    show_container_warning()
    exit(1)

_container_file_content = ''
with open(_container_file) as io:
    _container_file_content = io.read()

if not _container_file_content.startswith('docker'):
    show_container_warning()
    exit(1)




root = BOOK_LOCATION_INSIDE_CONTAINER
files_for_update = []

# Фильтруем файлы с расширением .md и содержащие jupytext
# настройки для исполнения кода
for (dirpath, dirnames, filenames) in os.walk(root):
    for filename in filenames:
        filepath = os.path.join(dirpath, filename)
        _, suffix = os.path.splitext(filepath)

        if suffix != '.md':
            continue

        with open(filepath) as io:
            content = io.read()
            if content.startswith('---\njupytext'):
                files_for_update.append(filepath)


print('Следующие файлы будут обновлены')
for x in files_for_update:
    print('', x)

# Здесь полагаемся на встроенную утилиту jupyter-book myst init.

for x in files_for_update:
    subprocess.run([
        'jupyter-book',
        'myst',
        'init',
        '--kernel',
        JUPYTER_KERNELSPEC_FOR_JULIA,
        x,
    ])
