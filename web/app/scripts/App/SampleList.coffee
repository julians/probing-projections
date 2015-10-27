# global define
# global Modernizr
# global Papa

define([
    "exports"
    "Config"
    "Utils"
    "./DataWrapper"
    "./Sample"
    "./DimensionList"
    "./Selection"
    "./SelectionList"
    "./HierarchicalCluster"
    "./MDS"
    "components/MicroEvent"
    "underscore"
    "d3"
    "science"
    "underscoreMath"
], (
    exports
    Config
    Utils
    DataWrapper
    Sample
    DimensionList
    Selection
    SelectionList
    HierarchicalCluster
    MDS
    MicroEvent
    _
    d3
    science
) ->
    'use strict'
    class SampleList extends MicroEvent
        constructor: () ->
            @__resetEverything()
        
        
        __resetEverything: =>
            @precalculatedMDS = false
            @drInfo = {}
            @minDistance = false

            @samples = []
            @sampleHash = {}
            @sampleIndex = {}
            @sampleClasses = DataWrapper.getSelectionList("classes")
            
            @mdsExtent =
                x: [0, 0]
                y: [0, 0]
            
            @hierarchicalClustering = null            
            @dimensionList = null
            
            @resetProjectionDistanceMatrix()
            @resetHdDistanceMatrix()
            @resetDistanceErrorMatrix()
            @resetStress1Matrix()
            
        
        setData: (data) =>
            @__resetEverything()
            
            @sampleClasses.turnOffEvents()
            for d, index in data
                sample = new Sample(d, @)
                @samples.push(sample)
                @sampleHash[sample.id] = sample
                @sampleIndex[sample.id] = index
        
                if "Class" of d
                    sampleClass = @sampleClasses.getByLabel(d.Class)
                    unless sampleClass
                        sampleClass = new Selection(
                            label: d.Class
                        )
                        @sampleClasses.add(sampleClass)
                    sampleClass.add(sample)
                    sample.classSelection = sampleClass
            @sampleClasses.autoColour()
            @sampleClasses.turnOnEvents()
            
            @dimensionList = new DimensionList(@)
            @updateSamples()
            
            unless @sampleClasses.isEmpty()
                @sampleClasses.trigger("change")
            @trigger("change:samples")

        
        serialise: =>
            serialisedDataset = for sample in @samples
                sample.getVector()
        
        
        getSampleClasses: =>
            return if _.keys(@sampleClasses).length then _.keys(@sampleClasses) else null
        
        
        getIndexForSample: (sample) =>
            return @sampleIndex[sample.id]
        
        
        getSampleFromId: (id) =>
            return @sampleHash[id]
        
        
        updateFromServer: (data) =>
            @setMDS(data.embedding)
            @setHierarchicalClustering(data.clustering)
            @trigger("change")
            unless @sampleClasses.isEmpty()
                @sampleClasses.trigger("change")
            DataWrapper.trigger("change:sampleList")
            
        
        updateSamples: =>
            if "mds:x" of @samples[0].data and "mds:y" of @samples[0].data
                @precalculatedMDS = true
                for sample, index in @samples
                    sample.mdsPosition = [
                        sample.data["mds:x"]
                        sample.data["mds:y"]
                    ]
                    sample.dimensionList = @dimensionList
                @calculateHdDistanceMatrix()
                #@calculateProjectionDistanceMatrix()
                #@calculateDistanceErrorMatrix()
            else
                for sample, index in @samples
                    sample.dimensionList = @dimensionList
                @calculateHdDistanceMatrix()
                            
        
        setHierarchicalClustering: (clusterData) =>
            @hierarchicalClustering = new HierarchicalCluster(clusterData)
            @trigger("change:clustering")
        
        
        setMDS: (positions) =>
            if positions
                for position, index in positions
                    @samples[index].mdsPosition = position
            @calculateProjectionDistanceMatrix()
            @calculateDistanceErrorMatrix()
            @calculateStress1Matrix()
            
            # figure out min/max values and set scale domains
            xMinMaxDefault = d3.extent(@samples, (d) =>
                d.mdsPosition[0]
            )
            yMinMaxDefault = d3.extent(@samples, (d) =>
                d.mdsPosition[1]
            )
            
            width = Utils.difference(xMinMaxDefault[0], xMinMaxDefault[1])
            height = Utils.difference(yMinMaxDefault[0], yMinMaxDefault[1])

            longest = Math.max(width, height)
            if width == longest
                toScale = yMinMaxDefault
                diff = 1 - height/width
            else if height == longest
                toScale = xMinMaxDefault
                diff = 1 - width/height
            
            new1 = Math.min(toScale[0], toScale[1])
            new1 = new1 - Math.abs(new1 * diff/2)
            new2 = Math.max(toScale[0], toScale[1])
            new2 = new2 + Math.abs(new2 * diff/2)
            toScale[0] = new1
            toScale[1] = new2
            
            # .reverse() only for the test
            @mdsExtent =
                x: xMinMaxDefault#.reverse()
                y: yMinMaxDefault#.reverse()

            @trigger("change:projection")
        
        
        calculateMDS: =>
            unless @mds
                @mds = MDS.classic(@calculateHdDistanceMatrix(), 2)
                @resetProjectionDistanceMatrix()
            return @mds
        
        
        resetProjectionDistanceMatrix: =>
            @projectionMedianDistance = null
            @projectionKClosestMeanDistances = {}
            @projectionDistanceMatrix = []
            for mainSample, mainIndex in @samples
                @projectionDistanceMatrix[mainIndex] = []
        
        
        calculateProjectionDistanceMatrix: =>
            console.log "calculateProjectionDistanceMatrix"
            @resetProjectionDistanceMatrix()
            
            for mainSample, mainIndex in @samples
                for otherSample, otherIndex in @samples
                    if mainSample == otherSample
                        @projectionDistanceMatrix[mainIndex][otherIndex] = 0
                    else
                        if @projectionDistanceMatrix.length > otherIndex and @projectionDistanceMatrix[otherIndex].length > mainIndex
                            @projectionDistanceMatrix[mainIndex][otherIndex] = @projectionDistanceMatrix[otherIndex][mainIndex]
                        else
                            @projectionDistanceMatrix[mainIndex][otherIndex] = Utils.euclideanDistance(mainSample.mdsPosition, otherSample.mdsPosition)
        
        
        getAllProjectionDistancesFromSample: (sample) =>
            if @projectionDistanceMatrix?[@sampleIndex[sample.id]].length
                return @projectionDistanceMatrix[@sampleIndex[sample.id]]
            else
                distances = for i in @samples
                    Utils.euclideanDistance(sample.mdsPosition, i.mdsPosition)
                @projectionDistanceMatrix[@sampleIndex[sample.id]] = distances
                return distances
        
        
        getProjectionDistanceBetweenSamples: (a, b) =>
            if @projectionDistanceMatrix
                aIndex = @sampleIndex[a.id]
                if aIndex >= 0 and @projectionDistanceMatrix.length > aIndex
                    bIndex = @sampleIndex[b.id]
                    if bIndex >= 0 and @projectionDistanceMatrix[aIndex].length > bIndex
                        return @projectionDistanceMatrix[aIndex][bIndex]
            
            return Utils.euclideanDistance(a.mdsPosition, b.mdsPosition)
                
        
        getMedianProjectionDistance: =>
            unless @projectionMedianDistance
                @projectionMedianDistance = _.chain(@projectionDistanceMatrix).flatten().median().value()
                #console.log science.stats.quantiles(_.flatten(@projectionDistanceMatrix), [0.25, 0.5, 0.75])
            
            return @projectionMedianDistance
        
        
        getMeanDistanceToKClosest: (k) =>
            unless k of @projectionKClosestMeanDistances
                value = 0
                for row, index in @projectionDistanceMatrix
                    distances = row.slice().sort()[0...k]
                    value += distances.reduce((a, b) -> a + b) / k
                    
                @projectionKClosestMeanDistances[k] = value / @projectionDistanceMatrix.length
                
            return @projectionKClosestMeanDistances[k]
        
        
        resetHdDistanceMatrix: =>
            @hdDistanceMatrix = []
            @hdKClosestMeanDistances = {}
            for mainSample, mainIndex in @samples
                @hdDistanceMatrix[mainIndex] = []
                
        
        calculateHdDistanceMatrix: =>
            console.log "calculateHdDistanceMatrix"
            @resetHdDistanceMatrix()
            
            for mainSample, mainIndex in @samples
                for otherSample, otherIndex in @samples
                    if mainSample == otherSample
                        @hdDistanceMatrix[mainIndex][otherIndex] = 0
                    else
                        if @hdDistanceMatrix.length > otherIndex and @hdDistanceMatrix[otherIndex].length > mainIndex
                            @hdDistanceMatrix[mainIndex][otherIndex] = @hdDistanceMatrix[otherIndex][mainIndex]
                        else
                            @hdDistanceMatrix[mainIndex][otherIndex] = @calculateHdDistanceBetweenSamples(mainSample, otherSample)
            
            
            if @minDistance is true
                k = Math.floor(@samples.length * 0.1)
                console.log k
                if k < 3
                    k = 3
                console.log k
                @minDistance = @getMeanHdDistanceToKClosest(k)
                console.log @minDistance
                
                for mainSample, mainIndex in @samples
                    for otherSample, otherIndex in @samples
                        if mainSample != otherSample
                            if @hdDistanceMatrix[mainIndex][otherIndex] < @minDistance
                                #console.log "overwriting distance: #{@hdDistanceMatrix[mainIndex][otherIndex]} to #{@minDistance}"
                                @hdDistanceMatrix[mainIndex][otherIndex] = @minDistance
                            
            return @hdDistanceMatrix
        
        
        getAllHdDistancesFromSample: (sample) =>
            if @hdDistanceMatrix?[@sampleIndex[sample.id]].length
                return @hdDistanceMatrix[@sampleIndex[sample.id]]
            else
                distances = for i in @samples
                    sample.distanceTo(i)
                @hdDistanceMatrix[@sampleIndex[sample.id]] = distances
                return distances
        
        
        getHdDistanceBetweenSamples: (a, b) =>
            if @hdDistanceMatrix
                aIndex = @sampleIndex[a.id]
                if aIndex >= 0 and @hdDistanceMatrix.length > aIndex
                    bIndex = @sampleIndex[b.id]
                    if bIndex >= 0 and @hdDistanceMatrix[aIndex].length > bIndex
                        return @hdDistanceMatrix[aIndex][bIndex]
            
            return @calculateHdDistanceBetweenSamples(a, b)
        
        
        calculateHdDistanceBetweenSamples: (a, b) =>
            if a.id == b.id
                return 0
            
            return Utils.euclideanDistance(a.getVector(), b.getVector())
            
        
        getMeanHdDistanceToKClosest: (k) =>
            unless k of @hdKClosestMeanDistances
                value = 0
                for row, index in @hdDistanceMatrix
                    distances = row.slice().sort()[0...k]
                    value += distances.reduce((a, b) -> a + b) / k
                    
                @hdKClosestMeanDistances[k] = value / @hdDistanceMatrix.length
                
            return @hdKClosestMeanDistances[k]
        
            
        resetDistanceErrorMatrix: =>
            @distanceErrorMatrix = []
            for mainSample, mainIndex in @samples
                @distanceErrorMatrix[mainIndex] = []
                
                
        calculateDistanceErrorMatrix: =>
            console.log "calculateDistanceErrorMatrix"
            @resetDistanceErrorMatrix()
            
            for mainSample, mainIndex in @samples
                calculatedDistances = @getAllHdDistancesFromSample(mainSample)
                mdsDistances = @getAllProjectionDistancesFromSample(mainSample)
            
                # min/max distances, ignoring 0 values
                distanceScale = d3.scale.linear()
                    .domain(d3.extent(calculatedDistances, (d) -> return (if d == 0 then null else d)))
                    .range(d3.extent(mdsDistances, (d) -> return (if d == 0 then null else d)))
                
                for otherSample, otherIndex in @samples
                    if mainSample == otherSample
                        @distanceErrorMatrix[mainIndex][otherIndex] = 0
                    else
                        if @distanceErrorMatrix.length > otherIndex and @distanceErrorMatrix[otherIndex].length > mainIndex
                            @distanceErrorMatrix[mainIndex][otherIndex] = @distanceErrorMatrix[otherIndex][mainIndex]
                        else
                            correctedDistance = distanceScale(mainSample.distanceTo(otherSample))
                            #correctedDistance = sample.distanceTo(otherSample)
                            @distanceErrorMatrix[mainIndex][otherIndex] = 1 - mdsDistances[otherIndex]/correctedDistance
                            
        
        getAllDistanceErrorsFromSample: (sample) =>
            return @distanceErrorMatrix[@sampleIndex[sample.id]]
        
        
        resetStress1Matrix: =>
            @stress1Matrix = []
            for mainSample, mainIndex in @samples
                @stress1Matrix[mainIndex] = []
        
        
        calculateStress1Matrix: =>
            console.log "calculate stress1Matrix"
            @resetStress1Matrix()
            
            for mainSample, mainIndex in @samples
                disparities = @getAllHdDistancesFromSample(mainSample)
                distances = @getAllProjectionDistancesFromSample(mainSample)
                
                for otherSample, otherIndex in @samples
                    if mainSample == otherSample
                        @stress1Matrix[mainIndex][otherIndex] = 0
                    else
                        if @stress1Matrix.length > otherIndex and @stress1Matrix[otherIndex].length > mainIndex
                            @stress1Matrix[mainIndex][otherIndex] = @stress1Matrix[otherIndex][mainIndex]
                        else
                            stress1 = Math.sqrt(Math.pow(distances[otherIndex] - disparities[otherIndex], 2) / Math.pow(distances[otherIndex], 2))
                            @stress1Matrix[mainIndex][otherIndex] = Math.abs(stress1)
            stress = for row in @stress1Matrix
                science.stats.mean(row)
            console.log science.stats.mean(stress)
            
            
        getStress1ForSample: (sample) =>
            return @stress1Matrix[@sampleIndex[sample.id]]
        
    
    return SampleList
)