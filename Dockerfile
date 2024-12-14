FROM python:3.13.1-slim

USER root

WORKDIR .

# "." is the src directory. It is the artifact that is being uploaded
COPY . .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

CMD ["flask", "run"]
