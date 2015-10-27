# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "./DataWrapper"
    "./Selection"
    "./ScatterplotThumbnail"
    "hbs!./templates/SelectionDisplay"
    "components/MicroEvent"
    "jquery"
    "underscore"
], (
    Config
    Utils
    DataWrapper
    Selection
    ScatterplotThumbnail
    SelectionDisplayTemplate
    MicroEvent
    $
    _
) ->
    'use strict'
    class SelectionListDisplay extends MicroEvent
        constructor: (options) ->
            @$container = $(options.container)
            @selectionList = options.selectionList
            @key = "id"
            @thumbnails = {}
            @isUserSelection = options.selectionList == DataWrapper.getSelectionList("user")
            
            @selectionList.bind("change", @render)
            @$container.on("mouseenter mouseleave click", ".selection", @mouseEvent)
            @$container.on("click", ".createSelection", @createSelection)
            @$container.on("click", ".removeSelection", @removeSelection)
            @$container.on("click", ".tempAddButton", @makeTempSelectionPermanent)
            if @isUserSelection
                DataWrapper.bind("tempSelection:change", @render)
            
            @render()
    
        
        createSelection: (event) =>
            $el = $(event.currentTarget)
            $parent = $el.closest(".selection")
            id = $parent.data("id")
            selection = @selectionList.getById(id)
            event.preventDefault()
            event.stopPropagation()
            
            newSelection = new Selection(
                samples: selection.samples
                label: selection.label
            )
            DataWrapper.createUserSelectionFrom(newSelection)
            
        
        removeSelection: (event) =>
            $el = $(event.currentTarget)
            $parent = $el.closest(".selection")
            id = $parent.data("id")
            selection = @selectionList.getById(id)
            event.preventDefault()
            event.stopPropagation()
            DataWrapper.removeUserSelection(selection)
            
            
        makeTempSelectionPermanent: (event) =>
            DataWrapper.makeTempPermanent()
            event.preventDefault()
            event.stopPropagation()
        
        
        mouseEvent: (event) =>
            $el = $(event.currentTarget)
            id = $el.data("id")
            selection = @selectionList.getById(id)
            
            if not selection and "#{id}" == DataWrapper.tempSelection.id
                selection = DataWrapper.tempSelection       
            
            if event.type == "mouseenter" and selection.samples.length
                DataWrapper.setBrushedSelection(selection)
            else if event.type == "mouseleave"
                DataWrapper.setBrushedSelection(null)
            else
                unless selection == DataWrapper.tempSelection
                    if $el.hasClass("active")
                        selection.setActive(false)
                        $el.removeClass("active")
                    else
                        selection.setActive(true)
                        $el.addClass("active")

        
        render: =>
            that = @
            
            availableWidth = @$container.width()
            itemWidth = 120
            itemHeight = 98
            itemsPerRow = Math.floor(availableWidth/itemWidth)
            
            if @isUserSelection
                selections = @selectionList.selections.concat(DataWrapper.tempSelection)      
            else
                selections = @selectionList.selections
            
            @$container.css(
                height: "#{Math.ceil(selections.length/itemsPerRow)*itemHeight}px"
            )
            container = d3.select(@$container[0])
            
            keyFunction = null
            if @key == "id"
                keyFunction = (d) ->
                    return d.id
              
            items = container.selectAll(".selection")
                .data(selections, keyFunction)
            
            items.enter()
                .append("li")
                .attr("class", "selection inserted")
                .each((d, index) ->
                    x = index % itemsPerRow
                    row = Math.floor(index/itemsPerRow)
                    $(this).html(SelectionDisplayTemplate(
                        canCreateUserSelection: that.selectionList.id != "user"
                        canRemoveSelection: that.selectionList.id == "user"
                    ))
                    
                    that.thumbnails[d.id] = new ScatterplotThumbnail(
                        container: $(this).find(".thumbnailContainer")
                        selection: d
                    )
                    
                    $(this).css(
                        left: "#{x * itemWidth}px"
                        top: "#{row * itemHeight}px"
                    )
                    if that.isUserSelection
                        unless d == DataWrapper.tempSelection
                            $(this).find(".label")
                                .attr("contenteditable", "true")
                                .addClass("editable")
                        $(this).on("click", ".label.editable").click((event) ->
                            if d == DataWrapper.tempSelection
                                event.preventDefault()
                            else
                                event.stopPropagation()
                        )
                        $(this).find(".label").blur((event) ->
                            unless d == DataWrapper.tempSelection
                                event.stopPropagation()
                                d.setLabel($(this).html())
                        )
                )
                .on("mouseenter", (d) ->
                    $(this).find(".label").css("color", d.colour)
                )
                .on("mouseleave", (d) ->
                    unless d.active
                        $(this).find(".label").css("color", "")
                )
                
            items
                .attr("data-id", (d) ->
                    return d.id
                )
                .each((d, index) ->
                    that.thumbnails[d.id].updateLayout()
                    $(this).find(".label").css("color", "")
                    sampleOrSamples = if d.samples.length == 1 then "sample" else "samples"
                    $(this).find(".sampleOrSamples").html(sampleOrSamples)
                    if d == DataWrapper.tempSelection
                        if d.samples.length
                            $(this).find(".label").html("create selection")
                            $(this).find(".numberOfSamples").html("from #{d.samples.length}")
                        else
                            $(this).find(".label").html("new selection")
                            $(this).find(".numberOfSamples").html("select")
                    else
                        if d.active
                            #colour = d3.hcl(d.colour.h, d.colour.c * 0.5, 60)
                            $(this).find(".label").css("color", d.colour)
                        $(this).find(".label").html(d.label)
                        $(this).find(".numberOfSamples").html(d.samples.length)
                    x = index % itemsPerRow
                    row = Math.floor(index/itemsPerRow)
                    $(this).css(
                        left: "#{x * itemWidth}px"
                        top: "#{row * itemHeight}px"
                    )
                    if that.isUserSelection
                        unless d == DataWrapper.tempSelection
                            $(this).find(".label")
                                .attr("contenteditable", "true")
                                .addClass("editable")
                )
                .classed("active", (d) ->
                    return d.active
                )
                .classed("visible", (d) ->
                    return d.visible
                )
                .classed("temp", (d) ->
                    return d == DataWrapper.tempSelection
                )
                .classed("empty", (d) ->
                    return d.samples.length == 0
                )
                .classed("inserted", false)
            
            itemsExit = items.exit()
                
            itemsExit
                .each((d) ->
                    that.thumbnails[d.id] = null
                    delete that.thumbnails[d.id]
                    $(this).one(Utils.transitionEndEvent, ->
                        d3.select(this).remove()
                    )
                )
                .classed("removed", true)
                    
            DataWrapper.trigger("layoutChange")
                
        
        renderContent: () =>
            if DataWrapper.sampleList.sampleClasses.isEmpty()
                return ""
            
            return ClassDisplayTemplate(
                samplesByClass: DataWrapper.sampleList.sampleClasses.getAll()
            )
           
            
    return SelectionListDisplay
)