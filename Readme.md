# Probing Projections

Multidimensional Scaling is a technique to visualise similarities in datasets. It works by projecting a high-dimensional dataset into a two-dimensional space. While the resulting visualisations clearly show if samples are similar or dissimilar, they fail to communicate the why. Furthermore, the visualisations usually contain some degree of error that isn’t visible, inspiring false confidence in the resulting projections.

This project tries to solve these problems by introducing a set of interaction and visualisation techniques to examine dimensionality-reduced datasets.


## Setup

Everything runs in the browser: the projection (metric or non-metric MDS, computed with the SMACOF algorithm) and the hierarchical clustering (Ward linkage) are calculated client-side, so the prototype can be hosted as static files anywhere. The frontend lives in `./web`.



## Building

You need a current [node.js](https://nodejs.org). Then, in `./web`:

    ./build.sh

This fetches the frontend dependencies (via bower), compiles the CoffeeScript and Sass sources, and puts a ready-to-host version into `./web/dist`. The result has to be served over http, e.g. with `./build.sh serve` (starts a local server on [localhost:9000](http://localhost:9000/)), or by uploading `./web/dist` to any static web host.


## Attribution

The prototype was designed and built by [Julian Stahnke](https://julianstahnke.com/) for his bachelor thesis *Exploring Multidimensional Projections* (University of Applied Sciences Potsdam, 2015, [PDF](https://julianstahnke.com/probing-projections/static/julian-stahnke---exploring-multidimensional-projections.pdf)). The original code is at [github.com/julians/probing-projections](https://github.com/julians/probing-projections) (MIT license). This fork moves the projection and clustering from the Python backend into the browser.

The research is described in the paper:

> Julian Stahnke, Marian Dörk, Boris Müller, and Andreas Thom. *Probing Projections: Interaction Techniques for Interpreting Arrangements and Errors of Dimensionality Reductions.* IEEE Transactions on Visualization and Computer Graphics 22(1), 2016 (InfoVis 2015). [doi:10.1109/TVCG.2015.2467717](https://doi.org/10.1109/TVCG.2015.2467717), [PDF](https://julianstahnke.com/probing-projections/static/probing-projections-infovis-2015.pdf)

Overview page with a video walkthrough: [julianstahnke.com/probing-projections](https://julianstahnke.com/probing-projections/)
