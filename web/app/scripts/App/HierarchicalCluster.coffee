# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "./DataWrapper"
    "underscore"
    "d3"
], (
    Config
    Utils
    DataWrapper
    _
    d3
) ->
    'use strict'
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
            @clusterLines = _.sortBy(@clusterLines, "level").reverse()
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
            
            
    return HierarchicalCluster
)