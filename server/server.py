#!/usr/bin/env python
# -*- coding: utf-8 -*-

import process
from flask import request, Flask, json
#import flask
try:
    from flask.ext.cors import CORS, cross_origin  # The typical way to import flask-cors
except ImportError:
    # Path hack allows examples to be run without installation.
    import os
    parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.sys.path.insert(0, parentdir)

    from flask.ext.cors import CORS, cross_origin
    
    
app = Flask(__name__)
app.debug = True
app.config['CORS_HEADERS'] = 'Content-Type'

@app.route('/')
def hello_world():
    return 'Hello World!'
    
@app.route('/mds', methods=['GET', 'POST'])
@cross_origin()
def mds():
    csv_input = False
    metric = True
    drtype = "mds"
    components = 2
    if request.method == 'POST':
        dataset = request.json["dataset"]
        metric = request.json["metric"]
        drtype = request.json["drtype"]
        components = request.json["components"]

    output = process.do_stuff(dataset, metric, drtype, components)
    return json.jsonify(**output)

if __name__ == '__main__':
    app.run(host='0.0.0.0')