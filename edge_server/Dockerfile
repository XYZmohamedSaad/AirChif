FROM python:3.12.5-slim

WORKDIR /

COPY ./edge_server /edge_server
COPY ./edge_server/requirements.txt /requirements.txt

RUN pip install --no-cache-dir -r /requirements.txt

CMD ["uvicorn", "edge_server.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
