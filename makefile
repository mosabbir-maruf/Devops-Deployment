dev:
	docker run --rm -it \
		--name jatriswap-dev \
		-p 3000:3000 \
		-v $(PWD):/app \
		-v /app/node_modules \
		-w /app \
		node:24-slim \
		sh -c "npm install && npm run dev"

build:
	docker build -t jatriswap .

run:
	docker run --rm -it \
		--name jatriswap-prod \
		-p 3000:3000 \
		jatriswap

stop:
	docker stop jatriswap-dev jatriswap-prod || true

logs:
	docker logs -f jatriswap-prod

shell:
	docker run --rm -it \
		-v $(PWD):/app \
		-v /app/node_modules \
		-w /app \
		node:24-slim \
		sh

install:
	docker run --rm -it \
		-v $(PWD):/app \
		-v /app/node_modules \
		-w /app \
		node:24-slim \
		npm install

audit:
	docker run --rm -it \
		-v $(PWD):/app \
		-w /app \
		node:24-slim \
		npm audit

clean:
	docker container prune -f

deep-clean:
	docker system prune -a -f