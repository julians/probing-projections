import $ from "jquery"
import App from "./App/App.coffee"
import "../styles/main.scss"

$ ->
    app = new App(
        container: "#vizzyviz"
    )
