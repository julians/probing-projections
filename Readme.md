Multidimensional Scaling is a technique to visualise similarities in datasets. It works by projecting a high-dimensional dataset into a two-dimensional space. While the resulting visualisations clearly show if samples are similar or dissimilar, they fail to communicate the why. Furthermore, the visualisations usually contain some degree of error that isn’t visible, inspiring false confidence in the resulting projections.

This project tries to solve these problems by introducing a set of interaction and visualisation techniques to examine dimensionality-reduced datasets.


# Getting this to run

Technically, there are two parts, a frontend (in `./web`) and backend (in `./server`).

The server is a flask/gunicorn app meant to be running on Heroku, but can be deployed anywhere (I had it running on [uberspace](https://uberspace.de) at some point).


## Frontend

Can be hosted anywhere, needs grunt and an old (2014/2015-ish) version of node to build. Sorry ;) Setup instructions are in `./web/Readme.md`.


## Backend

Needs Python 3.6. Everything’s in place to run this on Heroku using `Heroku Git`.

Do the following in this repository’s root directory to run locally:

1. `python3 -m venv venv` (creates a new [virtual environment](http://docs.python-guide.org/en/latest/dev/virtualenvs/))
2. `source venv/bin/activate` (activates virtual environment)
3. `pip install -r requirements.txt` (installs dependencies)
4. Start with `gunicorn server.server:app`
