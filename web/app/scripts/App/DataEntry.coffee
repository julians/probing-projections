import Config from "../Config.coffee"
import Utils from "../Utils.coffee"
import DataEntryTemplate from "./templates/DataEntry.html?hbs"
import MicroEvent from "../components/MicroEvent.coffee"
import $ from "jquery"
import Papa from "papaparse"

class DataEntry extends MicroEvent
    constructor: (options) ->
        super()
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
        # the metric option only applies to SMACOF
        @$dataEntryForm.find('input[name="drtype"]').on("change", =>
            @$dataEntryForm.find("#metricCheckbox").prop("disabled", @getDrType() != "mds")
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
            drType: @getDrType()
            parsedCsv: csvData
        })
        
        
    getDrType: =>
        return @$dataEntryForm.find('input[name="drtype"]:checked').val()


    getData: =>
        return Papa.parse(@$dataEntryForm.find("textarea").val().trim(),
            dynamicTyping: true
            header: true
        )
        
        
    setExport: (exportString) =>
        @$dataEntryForm.find("textarea[name=export]").val(exportString)
        
        
export default DataEntry
