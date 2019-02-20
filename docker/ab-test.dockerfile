FROM python:2.7.15-alpine

WORKDIR /home/ab-test

# Install deps
COPY ./requirements.txt ./
RUN apk add --no-cache --virtual .build-deps gcc musl-dev
RUN pip install -r requirements.txt
RUN apk del .build-deps gcc musl-dev

# Expose ports (for orchestrators and dynamic reverse proxies)
EXPOSE 8000

# Start development
ENTRYPOINT ["gunicorn", "--access-logfile", "-", "-w", "8", "-b", "0.0.0.0:8000", "--worker-class=gevent"]
