FROM python:3

RUN pip install flask

ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000
ENV FLASK_ENV=development
ENV FLASK_DEBUG=true

WORKDIR /code

CMD flask run
