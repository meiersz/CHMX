FROM python:3.7-alpine

WORKDIR /usr/src/app

COPY script/python/requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

COPY script/python/ .

CMD [ "python3", "./clock.py" ]

