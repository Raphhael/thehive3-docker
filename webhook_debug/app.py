from flask import Flask, request, jsonify
from time import time
from json import dumps

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST','DELETE', 'PATCH'])
def index():
    data = request.get_json()
    headers = dict(request.headers)

    infos = data.get('operation', "") + "_" + data.get('objectType', "")

    app.logger.info(" --- ")
    app.logger.info("headers : %s " % headers)
    app.logger.info("data : %s " % data)
    with open(f"requests/req_%s_%s.json" % (int(time() * 100000), infos), "w") as req:
        req.write(dumps({"headers" : headers, "data" : data}, indent=4))
    return jsonify(request.get_json())
