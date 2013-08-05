"use strict"
fs    = require "fs"

Main =
  register: (server) ->
    server.get "/", (request, response, next) ->
      html = fs.readFileSync "./package/index.html", "utf8"
      response.writeHead 200,
        "Content-Type"    : "text/html"
        "Content-Length"  : html.length
      response.write html
      do response.end
      next()

module.exports = Main
