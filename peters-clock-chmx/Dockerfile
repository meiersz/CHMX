FROM python:3.7-alpine

WORKDIR /usr/src/app

#COPY script/python/requirements.txt ./
#RUN pip install --no-cache-dir -r requirements.txt

COPY script/python/ .

CMD [ "python", "./clock.py" ]
