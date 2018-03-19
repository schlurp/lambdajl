build:
	docker build -t lambdajl .

shell:
	docker run --rm -it -v $(PWD):/var/host lambdajl bash
