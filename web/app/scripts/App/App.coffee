# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "./DataEntry"
    "./DataWrapper"
    "./Selection"
    "./SelectionList"
    "./SampleList"
    "./Heatmap"
    "./SelectionListDisplay"
    "./DimensionDisplay"
    "./PanelDisplay"
    "./MDS"
    "./Scatterplot"
    "./ExplorationTooltip"
    "hbs!./templates/App"
    "hbs!./templates/ControlLabelTooltip"
    "components/MicroEvent"
    "jquery"
    "underscore"
    "components/Tooltip"
], (
    Config
    Utils
    DataEntry
    DataWrapper
    Selection
    SelectionList
    SampleList
    Heatmap
    SelectionListDisplay
    DimensionDisplay
    PanelDisplay
    MDS
    Scatterplot
    ExplorationTooltip
    AppTemplate
    ControlLabelTooltipTemplate
    MicroEvent
    $
    _
    Tooltip
) ->
    'use strict'
    class App extends MicroEvent
        constructor: (options) ->
            Config.baseColour = d3.hcl(0, 0, 60)
            @$container = $(options.container)
            @$container.html(AppTemplate())

            DataWrapper.addSelectionList(new SelectionList(
                id: "user"
            ), "user")
            DataWrapper.addSelectionList(new SelectionList(
                id: "classes"
            ), "classes")
            DataWrapper.addSelectionList(new SelectionList(
                id: "clusters"
            ), "clusters")
            DataWrapper.setActiveSelections("clusters")

            @explorationTooltip = new ExplorationTooltip(
                container: $("body")
            )

            @$visualisationContainer = @$container.find(".visualisation")
            @$mainContainer = @$container.find(".mainContainer")

            @dataEntry = new DataEntry(
                container: @$container.find(".dataEntry")
                data: null
            )
            @dataEntry.bind("change", @createVisualisation)
            @dataEntry.bind("cancel", =>
                @$mainContainer.removeClass("flipped")
            )

            @scatterplot = new Scatterplot(
                container: @$container.find(".scatterplot")
            )
            @heatmap = new Heatmap(@scatterplot)

            @userSelectionDisplay = new SelectionListDisplay(
                container: @$container.find(".userSelectionDisplay .selectionListDisplay")
                selectionList: DataWrapper.getSelectionList("user")
            )
            @classDisplay = new SelectionListDisplay(
                container: @$container.find(".classDisplay .selectionListDisplay")
                selectionList: DataWrapper.getSelectionList("classes")
            )
            @clusterDisplay = new SelectionListDisplay(
                container: @$container.find(".clusterDisplay .selectionListDisplay")
                selectionList: DataWrapper.getSelectionList("clusters")
            )

            @dimensionDisplay = new DimensionDisplay(
                container: @$container.find(".dimensionDisplay")
                heatmap: @heatmap
            )
            @panelDisplays = []
            @$container.find(".sidebar .panel").each((index, element) =>
                @panelDisplays.push(new PanelDisplay(
                    container: element
                ))
            )

            $("#numberOfClusters").on("input", @clusterControlChange)
            $("#numberOfClusters").on("change", @clusterControlEnd)
            $("#editProjectionButton").click(@editProjection)

            @$dendrogramCheckbox = $("#showDendrogram")
            @$dendrogramCheckbox.change(@toggleDendrogram)

            @$errorDisplayCheckbox = $("#showErrorDisplay")
            @$errorDisplayCheckbox.change(@toggleErrorDisplay)

            @$labelDisplayCheckbox = $("#showlabels")
            @$labelDisplayCheckbox.change(@toggleLabelDisplay)

            @$hoverHelpButtons = @$container.find(".hoverHelp")
            @hoverHelpTooltip = new Tooltip(
                container: @$container
            )
            @$hoverHelpButtons.on("mouseenter mouseleave", (event) =>
                if event.type == "mouseenter"
                    $el = $(event.currentTarget)
                    type = $el.data("helpfor")

                    pos = $el.offset()
                    x = pos.left + ($el.width()/2)
                    y = pos.top + ($el.height()/2)
                    @hoverHelpTooltip.setTargetDimensions($el.width(), $el.height())
                    @hoverHelpTooltip.setContent(ControlLabelTooltipTemplate(
                        dendrogram: type == "dendrogram"
                        errordisplay: type == "errordisplay"
                        clustercontrol: type == "clustercontrol"
                    ))
                    @hoverHelpTooltip.setPosition(x, y, "top bottom")
                    @hoverHelpTooltip.show()
                else
                    @hoverHelpTooltip.hide()
            )

            @scatterplot.bind("dot:over", @dotOver)
            @scatterplot.bind("dot:out", @dotOut)
            @scatterplot.bind("selection", @scatterplotSelection)

            @dimensionDisplay.bind("dimension:over", @dimensionOver)
            @dimensionDisplay.bind("dimension:out", @dimensionOut)
            @dimensionDisplay.bind("dimension:click", @dimensionClick)

            DataWrapper.bind("brushed:selection", @selectionBrushed)
            @explorationTooltip.bind("tooltipAction", @tooltipAction)

            @updateLayout()

            @$container.find(".dataEntry form").submit()
            $(window).resize(_.throttle(@redraw, 300, {leading: false}))


        resetSelectionLists: (exceptions) =>
            DataWrapper.clearAllSelectionLists(exceptions)
            DataWrapper.setActiveSelections("clusters")


        createVisualisation: (data) =>
            @$mainContainer.removeClass("flipped")

            if data.parsedCsv
                @resetSelectionLists()
                DataWrapper.sampleList = new SampleList()
                DataWrapper.sampleList.setData(data.parsedCsv.data)

            if ~window.location.host.indexOf("jujujulian.com")
                url = "//probing-projections.herokuapp.com/mds"
            else
                url = "//localhost:5000/mds"

            $.ajax(url,
                type: "POST"
                contentType: "application/json; charset=utf-8"
                dataType: "json"
                data: JSON.stringify(
                    dataset: DataWrapper.sampleList.serialise()
                    metric: data.metric
                    drtype: if DataWrapper.sampleList.precalculatedMDS then false else data.drType
                    components: 2
                )
                success: (data) =>
                    @$container.find(".classDisplay").show()
                    DataWrapper.sampleList.updateFromServer(data)

                    if DataWrapper.sampleList.sampleClasses.isEmpty()
                        @$container.find(".classDisplay").hide()
                    else
                        @$container.find(".classDisplay").show()
                        DataWrapper.setActiveSelections("classes")
                    #@completeCSV()
                    @createPositionExportJson()
            )


        editProjection: (event) =>
            @$mainContainer.addClass("flipped")


        toggleDendrogram: (event) =>
            @scatterplot.setDendrogramVisibility($("#showDendrogram").prop("checked"))


        toggleErrorDisplay: (event) =>
            DataWrapper.displayErrors = $("#showErrorDisplay").prop("checked")
            @scatterplot.setErrorDisplayVisibility($("#showErrorDisplay").prop("checked"))


        toggleLabelDisplay: (event) =>
            @scatterplot.setLabelVisibility(@$labelDisplayCheckbox.prop("checked"))


        clusterControlEnd: (event) =>
            clusterSelections = DataWrapper.getSelectionList("clusters")
            clusterSelections.turnOffEvents()
            for selection, index in clusterSelections.selections
                selection.setActive(false)
            clusterSelections.trigger("change")
            clusterSelections.turnOnEvents()
            DataWrapper.setActiveSelections(@previousSelectionKeyBeforeClustering)
            @previousSelectionKeyBeforeClustering = null


        clusterControlChange: (event) =>
            unless @previousSelectionKeyBeforeClustering
                @previousSelectionKeyBeforeClustering = DataWrapper.activeSelections.id
            numberOfClusters = parseInt($(event.currentTarget).val())
            if @previousClusterNumberValue and numberOfClusters == @previousClusterNumberValue
                return true

            @previousClusterNumberValue = numberOfClusters
            DataWrapper.setActiveSelections("clusters")
            clustering = DataWrapper.sampleList.hierarchicalClustering

            clusterSelections = DataWrapper.getSelectionList("clusters")

            $label = $("#numberOfClustersLabel")
            if numberOfClusters < 2
                $label.html("no clusters")
            else
                $label.html("#{numberOfClusters} clusters")

            if numberOfClusters == 1
                clusterSelections.clear()
            else
                clusterSelections.turnOffEvents()
                csLength = clusterSelections.selections.length
                if csLength > numberOfClusters
                    for x in [numberOfClusters...csLength]
                        clusterSelections.remove(clusterSelections.selections[clusterSelections.selections.length-1])
                else
                    for x in [csLength...numberOfClusters]
                        clusterSelections.add(new Selection())

                for sample in DataWrapper.sampleList.samples
                    clusterNumber = clustering.getClusterForSample(sample, numberOfClusters)

                    for selection, index in clusterSelections.selections
                        if index == clusterNumber
                            selection.add(sample)
                        else
                            selection.remove(sample)

                for selection, index in clusterSelections.selections
                    selection.setLabel("Cluster #{index+1}")
                    selection.setActive(true)

                clusterSelections.autoColour(Config.clusterColourOffset)
                clusterSelections.trigger("change")
                clusterSelections.turnOnEvents()


        dimensionOver: (dimension) =>
            @heatmap.setActiveDimension(dimension)


        dimensionOut: (dimension) =>
            @heatmap.setActiveDimension(null)


        dimensionClick: (dimension) =>
            if @scatterplot.getVisual("size") == dimension
                dimension = null
            @scatterplot.setVisual("size", dimension)


        selectionBrushed: (selection) =>
            if selection
                selections = [selection]
                activeSelections = DataWrapper.activeSelections.getActiveSelections()
                if activeSelections.length
                    selections = _.uniq(selections.concat(activeSelections))

                # get position for tooltip
                offset = @scatterplot.$container.offset()

                if selections.length == 1
                    leftmost = _.min(selection.samples, (sample) ->
                        return sample.mdsPosition[0]
                    )
                    rightmost = _.max(selection.samples, (sample) ->
                        return sample.mdsPosition[0]
                    )
                    topmost = _.max(selection.samples, (sample) ->
                        return sample.mdsPosition[1]
                    )
                    bottommost = _.min(selection.samples, (sample) ->
                        return sample.mdsPosition[1]
                    )
                    possiblePos = [
                        {x: leftmost.mdsPosition[0], y: leftmost.mdsPosition[1], order: "left"}
                        {x: topmost.mdsPosition[0], y: topmost.mdsPosition[1], order: "top"}
                        {x: bottommost.mdsPosition[0], y: bottommost.mdsPosition[1], order: "bottom"}
                        {x: rightmost.mdsPosition[0], y: rightmost.mdsPosition[1], order: "right"}
                    ]

                    for pos in possiblePos
                        pos.x = @scatterplot.x(pos.x) + offset.left + @scatterplot.margin
                        pos.y = @scatterplot.y(pos.y) + offset.top + @scatterplot.margin
                    @explorationTooltip.showForContentAtPosition(
                        content:
                            selections: selections
                        positions: possiblePos
                    )
                else
                    centroids = for s in selections
                        centroid = s.getCentroid()
                        [
                            @scatterplot.x(centroid[0]) + offset.left + @scatterplot.margin
                            @scatterplot.y(centroid[1]) + offset.top + @scatterplot.margin
                        ]

                    if centroids.length == 2
                        pos = Utils.lerp(centroids[0], centroids[1], 0.5)
                    else
                        pos = d3.geom.polygon(centroids).centroid()

                    @explorationTooltip.showForContentAtPosition(
                        content:
                            selections: selections
                        x: pos[0]
                        y: pos[1]
                    )
            else
                @explorationTooltip.hide()


        scatterplotSelection: (selectionObject) =>
            if selectionObject.shiftKey
                DataWrapper.toggleTemp(selectionObject.samples)
            else
                DataWrapper.setTemp(selectionObject.samples)


        tooltipAction: (event) =>
            if event.action == "correctDistance"
                @scatterplot.togglePositionsRelativeTo(event.sample)


        dotOver: (event) =>
            x = event.boundingRect.left + event.boundingRect.width/2
            y = event.boundingRect.top + event.boundingRect.height/2

            activeSelections = DataWrapper.activeSelections.getActiveSelections()
            if DataWrapper.tempSelection.samples.length == 1 and event.sample != DataWrapper.tempSelection.samples[0]
                @explorationTooltip.showForContentAtPosition(
                    content:
                        samples: [event.sample, DataWrapper.tempSelection.samples[0]]
                    x: x
                    y: y
                )
            else if activeSelections.length
                selections = [new Selection(
                    samples: [event.sample]
                    label: event.sample.getLabel()
                    colour: event.sample.getColour()
                )]
                selections = _.uniq(selections.concat(activeSelections))
                @explorationTooltip.showForContentAtPosition(
                    content:
                        selections: selections
                    x: x
                    y: y
                )
            else
                @explorationTooltip.showForContentAtPosition(
                    content:
                        sample: event.sample
                    x: x
                    y: y
                )


        dotOut: (event) =>
            window.setTimeout(=>
                @explorationTooltip.hide()
            , 10)


        redraw: =>
            @updateLayout()
            @scatterplot.draw()
            @heatmap.draw()


        updateLayout: =>
            sidebarMinWidth = 450
            width = $(window).width()
            width -= sidebarMinWidth
            height = $(window).height()
            dimension = Math.min(width, height)
            @$container.find(".sidebar").width($(window).width() - dimension)
            padding = @$mainContainer.outerWidth() - @$mainContainer.width()

            dimension -= padding
            @$mainContainer.width(dimension)
            @$mainContainer.find(".flipper").width(dimension).height(dimension)
            @$mainContainer.find(".back").width(dimension).height(dimension)
            @$mainContainer.find(".front").width(dimension).height(dimension)

            @scatterplot.updateLayout()
            @heatmap.updateLayout()
            @dimensionDisplay.updateLayout()


        distanceMatrixCSV: =>
            labels = [""]
            rows = []
            for sample in DataWrapper.sampleList.samples
                labels.push(sample.getLabel())
                distances = for distance in DataWrapper.sampleList.getAllHdDistancesFromSample(sample)
                    parseFloat(distance.toPrecision(2))
                rows.push([sample.getLabel()].concat(distances))
            csvRows = [labels].concat(rows)
            window.csvRows = csvRows
            return Papa.unparse(csvRows)


        completeCSV: =>
            rawCSV = @dataEntry.getData()
            newCSV = []
            for row, index in rawCSV.data
                row["mds:x"] = DataWrapper.sampleList.samples[index].mdsPosition[0]
                row["mds:y"] = DataWrapper.sampleList.samples[index].mdsPosition[1]
                newCSV.push(row)

            console.log Papa.unparse(newCSV)


        createPositionExportJson: =>
            positions = for sample in DataWrapper.sampleList.samples
                sample.mdsPosition.concat([sample.getLabel()])
            @dataEntry.setExport(JSON.stringify(positions))


    return App
)
