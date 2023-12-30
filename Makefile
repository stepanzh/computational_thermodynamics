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

html:
	docker exec -t $(DOCKER_CONTAINER_NAME) jupyter-book build book

html-all:
	docker exec -t $(DOCKER_CONTAINER_NAME) jupyter-book build --all book

html-clean:
	@echo 'Очищаю артефакты html, без jupyter-book кэша'
	docker exec -t $(DOCKER_CONTAINER_NAME) jupyter-book clean book

html-clean-all:
	@echo 'Очищаю артефакты html и jupyter-book кэш'
	docker exec -t $(DOCKER_CONTAINER_NAME) jupyter-book clean --all book

github-pages:
	@echo 'Публикация файлов локальных файлов книги на github pages'
	ghp-import -n -p -f book/_build/html

docker-image:
	@echo 'Создаю docker image (образ)'
	docker build -t $(DOCKER_IMAGE_NAME) .

docker-container:
	@echo 'Создаю docker контейнер для работы с книгой'
	docker run \
		-td \
		-v ${PWD}/book:$(CONTAINER_BOOK_PATH) \
		-p $(DOCKER_LOCAL_PORT):$(DOCKER_CONTAINER_PORT) \
		--name $(DOCKER_CONTAINER_NAME) \
	  $(DOCKER_IMAGE_NAME)

docker-container-start:
	docker start $(DOCKER_CONTAINER_NAME)

docker-container-stop:
	docker stop $(DOCKER_CONTAINER_NAME)

docker-container-inspect:
	docker exec -it $(DOCKER_CONTAINER_NAME) bash

local-server:
	@echo 'Создаю локальный сервер в контейнере для просмотра книги'
	docker exec -d $(DOCKER_CONTAINER_NAME) python3 -m http.server --directory $(CONTAINER_BOOK_PATH)/_build/html/ $(DOCKER_CONTAINER_PORT)
	@echo "Сервер с книгой должен быть доступен по адресу http://localhost:$(DOCKER_LOCAL_PORT)"

help:
	@echo 'No help provided, read Makefile :c'
	@echo 'Имя docker контейнера:' $(DOCKER_CONTAINER_NAME)
	@echo 'Имя docker образа:' $(DOCKER_IMAGE_NAME)

.PHONY: html html-all html-clean html-clean-all
.PHONY: github-pages
.PHONY: docker-image
.PHONY: docker-container docker-container-start docker-container-stop docker-inspect-container
.PHONY: local-server
.PHONY: help
