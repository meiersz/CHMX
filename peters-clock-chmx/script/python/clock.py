#!/usr/bin/env python3

from datetime import datetime
from flask import Flask

app = Flask(__name__)
@app.route("/")
def clock(): 
    now = datetime.now().strftime("%I:%M")
    print("now:", now)
    #now = input("Please, enter the time to convert (i.e: 07:33):  ")
    time = now.split(':')
    hour = int(time[0])
    minute = int(time[1])
    rststr = str()

    rstmin = 60 - minute
    rsthour = 11 - hour

    if rstmin == 60:
      rstmin -=60
      rsthour += 1
    if rsthour <= 0:
      rsthour += 12
    if rsthour > 9 :
      rststr = str(rsthour) + ":"
    else:
      rststr = '0' + str(rsthour) + ':'
    if rstmin > 9:
      rststr += str(rstmin)
    else:
      rststr += '0' + str(rstmin)
    
    print ("Mirrored: " + rststr)
    return ("now: "+ now + "\n mirrored: " + rststr)

if __name__ == "__main__":
  app.run(host='0.0.0.0', port=5000)
