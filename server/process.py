#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import sys
import csv
import StringIO
from collections import defaultdict
import numpy as np
from sklearn import manifold
from sklearn.cluster import AgglomerativeClustering as ac
from sklearn.metrics import euclidean_distances
from sklearn.decomposition import PCA
from tempfile import mkdtemp
import math

def do_stuff(dataset = None, metric = True, drtype = "mds", components = 2):
    data_for_mds = np.array(dataset)
    
    if drtype:
        if drtype == "mds":
            mds = manifold.MDS(n_components=components, n_init=10, max_iter=3000, dissimilarity="euclidean", n_jobs=1, metric=metric)
            mds_result = mds.fit(data_for_mds)
        elif drtype == "pca":
            pca = PCA(n_components=2)
            mds_result = pca.fit(euclidean_distances(data_for_mds)).transform(data_for_mds)
        elif drtype == "tsne":
            model = manifold.TSNE(n_components=2, random_state=0, learning_rate=1000, early_exaggeration=10.0)
            mds_result = model.fit_transform(data_for_mds)
    
    clusterings = {}
    for i in range(10, 1, -1):
        clustering = ac(n_clusters=i, memory=mkdtemp())
        clusterings[i] = clustering.fit(data_for_mds).labels_.tolist()
        
    clustering = ac(n_clusters=1, memory=mkdtemp())
    clustering.fit(data_for_mds)
    
    output = {
        "drInfo": None,
        "embedding": None,
        "clustering": {
            "tree": clustering.children_.tolist(),
            "labels": clusterings
        }
    }
    if drtype:
        median_distance = False
        stress1 = False
        raw_stress = False
        if drtype == "mds":
            raw_stress =  mds_result.stress_
            disparities = euclidean_distances(data_for_mds)
            disparityHalfMatrix = np.triu(disparities)
            sumSquaredDisparities = np.sum(np.square(disparityHalfMatrix))
            stress1 = math.sqrt(mds_result.stress_ / sumSquaredDisparities)
            median_distance = np.median(euclidean_distances(mds_result.embedding_))
            embedding = mds_result.embedding_.tolist()
            print mds_result.stress_
        else:
            embedding = mds_result.tolist()
        output["drInfo"] = {
            "type": drtype,
            "metric": metric,
            "components": components,
            "stress1": stress1,
            "rawStress":raw_stress,
            "medianDistance": median_distance
        }
        output["embedding"] = embedding

    return output
    
    
if __name__ == "__main__":
    print "sorry, only works with the server"