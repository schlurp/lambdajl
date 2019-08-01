JL_VERSION=1.1.1

build:
	docker build \
		--build-arg JL_VERSION=$(JL_VERSION) \
		-t octech/lambdajl:$(JL_VERSION) .

shell:
	docker run --rm -it -v $(PWD):/var/host octech/lambdajl:$(JL_VERSION) bash
