build:
	docker build docker -t andrchalov/pgmailer:latest

run:
	docker run -it --name pgmailer andrchalov/pgmailer:latest

push:
	docker push andrchalov/pgmailer:latest
