# global define
# global Modernizr
# global Papa

define([
    "Config"
    "Utils"
    "hbs!./templates/DataEntry"
    "components/MicroEvent"
    "jquery"
    "underscore"
], (
    Config
    Utils
    DataEntryTemplate
    MicroEvent
    $
    _
) ->
    'use strict'
    class DataEntry extends MicroEvent
        constructor: (options) ->
            @$container = $(options.container)
            @$container.html(DataEntryTemplate(
                data: options?.data or ""
            ))
            
            @oldCsvString = ""
            
            @$dataEntryForm = @$container.find("form")
            @$dataEntryForm.find("#cancelEditProjection").click((event) =>
                event.stopPropagation()
                event.preventDefault()
                @trigger("cancel")
            )
            @$dataEntryForm.on("submit", (event) =>
                event.preventDefault()
                event.stopPropagation()
                @parseData(@$dataEntryForm.find("textarea[name=csv]").val().trim())
            )
        
        
        parseData: (csvString) =>
            csvData = false
            unless csvString == @oldCsvString
                csvData = Papa.parse(csvString,
                    dynamicTyping: true
                    header: true
                )
                @oldCsvString = csvString
            @trigger("change", {
                metric: $("#metricCheckbox").prop("checked")
                drType: @$dataEntryForm.find('input[name="drtype"]:checked').val()
                parsedCsv: csvData
            })
            
            
        getData: =>
            return Papa.parse(@$dataEntryForm.find("textarea").val().trim(),
                dynamicTyping: true
                header: true
            )
            
            
        setExport: (exportString) =>
            @$dataEntryForm.find("textarea[name=export]").val(exportString)
            
            
    return DataEntry
)