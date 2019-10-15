FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
  build-essential \
  python3 \
  python3-pip \
  gosu \
  libpq-dev \
  postgresql-client

ADD requirements.txt /opt/requirements.txt
RUN pip3 install -r /opt/requirements.txt

COPY ./src /opt/app

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["python3", "-u", "main.py"]
