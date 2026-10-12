import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import DataWrapper from "./DataWrapper.coffee"
import { sortBy } from "es-toolkit"
import * as d3 from "d3"

class HierarchicalCluster
    constructor: (clusterData) ->
        @clusterData = null
        @setClustering(clusterData)
        
    
    setClustering: (clusterData) =>
        @clusterLines = null
        @levelExtent = null
        @pjDistanceExtent = null
        @hdDistanceExtent = null
        @clusterData = clusterData
        
        sampleList = DataWrapper.sampleList

        if sampleList?.samples.length and sampleList.samples[0].mdsPosition
            @clusterLines = []
            minLevel = Infinity
            maxLevel = 0
            minPjDistance = Infinity
            maxPjDistance = 0
            minHdDistance = Infinity
            maxHdDistance = 0
            minDistanceRatio = Infinity
            maxDistanceRatio = 0
            for cluster in clusterData.tree
                pjPositions = []
                hdPositions = []
                level = 0
                
                for node in cluster
                    if node < sampleList.samples.length
                        level += 1
                        pjPositions.push(sampleList.samples[node].mdsPosition)
                        hdPositions.push(sampleList.samples[node].getVector())
                    else
                        level += @clusterLines[node-sampleList.samples.length].level
                        pjPositions.push(@clusterLines[node-sampleList.samples.length].pjCenter)
                        hdPositions.push(@clusterLines[node-sampleList.samples.length].hdCenter)
                
                pjDistance = Utils.euclideanDistance(pjPositions[0], pjPositions[1])
                hdDistance = Utils.euclideanDistance(hdPositions[0], hdPositions[1])
                distanceRatio = pjDistance / hdDistance
                
                if level > maxLevel then maxLevel = level
                if level < minLevel then minLevel = level
                if pjDistance > maxPjDistance then maxPjDistance = pjDistance
                if pjDistance < minPjDistance then minPjDistance = pjDistance
                if hdDistance > maxHdDistance then maxHdDistance = hdDistance
                if hdDistance < minHdDistance then minHdDistance = hdDistance
                if distanceRatio > maxDistanceRatio then maxDistanceRatio = distanceRatio
                if distanceRatio < minDistanceRatio then minDistanceRatio = distanceRatio
                
                @clusterLines.push(
                    level: level
                    pjPositions: pjPositions
                    pjCenter: @calculateCenter(pjPositions[0], pjPositions[1])
                    pjDistance: pjDistance
                    hdPositions: hdPositions
                    hdCenter: @calculateCenter(hdPositions[0], hdPositions[1])
                    hdDistance: hdDistance
                    distanceRatio: distanceRatio
                )
        
        # sort by level so that the highest level lines will be drawn first,
        # being overlapped by the more important lower leve lines
        @clusterLines = sortBy(@clusterLines, ["level"]).reverse()
        @levelExtent = [minLevel, maxLevel]
        @pjDistanceExtent = [minPjDistance, maxPjDistance]
        @hdDistanceExtent = [minHdDistance, maxHdDistance]
        @distanceRatioExtent = [minDistanceRatio, maxDistanceRatio]
        
    
    getClustering: =>
        return {
            clusterLines: @clusterLines
            levelExtent: @levelExtent
            distanceRatioExtent: @distanceRatioExtent
        }
    
    
    getClusterForSample: (sample, numberOfClusters) =>
        sampleIndex = DataWrapper.sampleList.getIndexForSample(sample)
        return @clusterData.labels[numberOfClusters][sampleIndex]
    
    
    calculateCenter: (a, b) =>
        center = []
        for value, index in a
            center.push((value+b[index]) / 2)
        
        return center


    # Agglomerative clustering with Ward linkage in the high-dimensional
    # space, replacing scikit-learn's AgglomerativeClustering that the
    # server used to run. Returns the same structure the server did:
    #
    #   tree    array of [a, b] merges, in merge order. Indices below
    #           the number of samples are samples, index n+i refers to
    #           the cluster created by merge i (scikit-learn's children_)
    #   labels  object mapping a number of clusters k (2..maxClusters)
    #           to an array with a cluster index (0..k-1) per sample
    #
    # Labels are assigned so that they stay stable when going from k
    # to k+1 clusters: the split cluster keeps its index and the new
    # cluster gets index k.
    @ward: (vectors, maxClusters = 10) ->
        n = vectors.length

        # pairwise distances between the active clusters (Ward distances,
        # which for single samples are the euclidean distances)
        distances = for i in [0...n]
            (0 for j in [0...n])
        for i in [0...n]
            for j in [i+1...n]
                distances[i][j] = distances[j][i] = Utils.euclideanDistance(vectors[i], vectors[j])

        sizes = (1 for i in [0...n])
        ids = (i for i in [0...n])     # node id of the active cluster in each slot
        active = (true for i in [0...n])
        tree = []

        for merge in [0...n-1]
            # find the closest pair of active clusters
            best = Infinity
            bi = bj = -1
            for i in [0...n]
                continue unless active[i]
                for j in [i+1...n]
                    continue unless active[j]
                    if distances[i][j] < best
                        best = distances[i][j]
                        bi = i
                        bj = j

            tree.push([Math.min(ids[bi], ids[bj]), Math.max(ids[bi], ids[bj])])

            # merge bj into bi, updating the distances with the
            # Lance-Williams formula for Ward's criterion
            ni = sizes[bi]
            nj = sizes[bj]
            dij = distances[bi][bj]
            for k in [0...n]
                continue if not active[k] or k == bi or k == bj
                nk = sizes[k]
                dik = distances[bi][k]
                djk = distances[bj][k]
                d = Math.sqrt(((ni + nk) * dik * dik + (nj + nk) * djk * djk - nk * dij * dij) / (ni + nj + nk))
                distances[bi][k] = distances[k][bi] = d
            sizes[bi] = ni + nj
            ids[bi] = n + merge
            active[bj] = false

        # cut the tree: start with the root and repeatedly split the
        # most recently created cluster
        leavesOf = (node) ->
            return [node] if node < n
            children = tree[node - n]
            return leavesOf(children[0]).concat(leavesOf(children[1]))

        labels = {}
        clusters = [n + tree.length - 1]
        maxK = Math.min(maxClusters, n)
        for k in [2..maxK] by 1
            index = 0
            for node, i in clusters
                index = i if node > clusters[index]
            children = tree[clusters[index] - n]
            # the bigger child keeps the label, the smaller one gets the new one
            if leavesOf(children[1]).length > leavesOf(children[0]).length
                children = [children[1], children[0]]
            clusters[index] = children[0]
            clusters.push(children[1])

            labels[k] = (0 for i in [0...n])
            for node, i in clusters
                for leaf in leavesOf(node)
                    labels[k][leaf] = i

        return {
            tree: tree
            labels: labels
        }
        
        
export default HierarchicalCluster
