build:
	docker build docker -t andrchalov/pgmailer:1.0.0

run:
	docker run -it --name pgmailer andrchalov/pgmailer:1.0.0

push:
	docker push andrchalov/pgmailer:1.0.0
