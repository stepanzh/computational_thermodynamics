## ---------------------------------
## make команды для работы с книгой.
## ---------------------------------

# Название docker (image) образа.
# и название docker контейнера для генерации файлов книги.
DOCKER_IMAGE_NAME = compthermobook-image
DOCKER_CONTAINER_NAME = compthermobook

# Локальный порт для сервера
# и порт для контейнера.
DOCKER_LOCAL_PORT = 8080
DOCKER_CONTAINER_PORT = 80

# Путь до исходных файлов книги в контейнере.
CONTAINER_BOOK_PATH = /root/book/
# Путь до html файлов книги в контейнере.
CONTAINER_HTML_PATH = $(CONTAINER_BOOK_PATH)/_build/html/


help:	## Показать это сообщение с помощью.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST) | column -ts $$'\t'
	@echo 'Имя docker контейнера:' $(DOCKER_CONTAINER_NAME)
	@echo 'Имя docker образа:' $(DOCKER_IMAGE_NAME)

html:	## Создать веб-версию книги или обновить изменённые страницы.
	docker exec -t $(DOCKER_CONTAINER_NAME) jupyter-book build book
	docker exec -t $(DOCKER_CONTAINER_NAME) bash -c 'python3 $(CONTAINER_BOOK_PATH)/gensitemap.py > $(CONTAINER_HTML_PATH)/sitemap.xml'

html-all:	## Создать веб-версию книги с принудительной сборкой всех страниц.
	docker exec -t $(DOCKER_CONTAINER_NAME) jupyter-book build --all book
	docker exec -t $(DOCKER_CONTAINER_NAME) bash -c 'python3 $(CONTAINER_BOOK_PATH)/gensitemap.py > $(CONTAINER_HTML_PATH)/sitemap.xml'

html-clean:	## Очистить директорию с веб-версией книги, но оставить jupyter-book кэш.
	@echo 'Очищаю артефакты html, без jupyter-book кэша'
	docker exec -t $(DOCKER_CONTAINER_NAME) jupyter-book clean book

html-clean-all:	## Очистить директорию с веб-версией книги, включая jupyter-book кэш.
	@echo 'Очищаю артефакты html и jupyter-book кэш'
	docker exec -t $(DOCKER_CONTAINER_NAME) jupyter-book clean --all book

github-pages:	## Опубликовать веб-версию книги, используя GitHub Pages.
	@echo 'Публикация файлов локальных файлов книги на github pages'
	ghp-import -n -p -f book/_build/html

docker-image:	## Создать Docker образ для работы с книгой.
	@echo 'Создаю docker image (образ)'
	docker build -t $(DOCKER_IMAGE_NAME) .

docker-container:	## Создать Docker контейнер на основе образа для работы с книгой.
	@echo 'Создаю docker контейнер для работы с книгой'
	docker run \
		-td \
		-v ${PWD}/book:$(CONTAINER_BOOK_PATH) \
		-p $(DOCKER_LOCAL_PORT):$(DOCKER_CONTAINER_PORT) \
		--name $(DOCKER_CONTAINER_NAME) \
	  $(DOCKER_IMAGE_NAME)

docker-container-start:	## Запустить Docker контейнер.
	docker start $(DOCKER_CONTAINER_NAME)

docker-container-stop:	## Остановить работу Docker контейнера.
	docker stop $(DOCKER_CONTAINER_NAME)

docker-container-inspect:	## Подключиться к контейнеру (bash оболочка).
	docker exec -it $(DOCKER_CONTAINER_NAME) bash

local-server:	## Запустить локальный сервер в контейнере.
	@echo 'Создаю локальный сервер в контейнере для просмотра книги'
	docker exec -d $(DOCKER_CONTAINER_NAME) python3 -m http.server --directory $(CONTAINER_HTML_PATH) $(DOCKER_CONTAINER_PORT)
	@echo "Сервер с книгой должен быть доступен по адресу http://localhost:$(DOCKER_LOCAL_PORT)"


.PHONY: html html-all html-clean html-clean-all
.PHONY: github-pages
.PHONY: docker-image
.PHONY: docker-container docker-container-start docker-container-stop docker-inspect-container
.PHONY: local-server
.PHONY: help
