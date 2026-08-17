.PHONY: build validate smoke up down clean

build:
	docker compose build

validate:
	./scripts/validate.sh

smoke:
	./tests/smoke.sh

up:
	docker compose up -d --build

down:
	docker compose down

clean:
	docker compose down --rmi local --volumes --remove-orphans
