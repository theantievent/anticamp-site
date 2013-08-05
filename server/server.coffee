###
REST
@description  Node Server Instance
@version      0.8001
@author       Javi Jimenez Villar <javi@nextflip.org> || @soyjavi
###
"use strict"

restify     = require "restify"
yaml        = require "js-yaml"
fs          = require "fs"
# Configuration
app         = require "./app.yml"
cors        = require "./cors.yml"

Server =

  run: (callback)->
    @srv = restify.createServer()
    do @middleware
    do @files
    do @start
    do @events
    do @close

  files: ->
    require("./#{file}").register @srv for file in app.files

  middleware: ->
    @srv.use restify.queryParser()
    @srv.use restify.bodyParser()
    @srv.use (req, res, next) ->
      _setCORS res
      do next
    @srv.use (req, res, next) -> next()

  start: ->
    @srv.listen process.env.VCAP_APP_PORT or app.server.port, =>
      console.log " [SERVER] Listening at #{@srv.url} (CTRL + C to stop it)"
      callback @srv if callback?

      if app.cron?
        console.log "  - [CRON] Starting..."
        for cron in app.cron
          console.log "     - '#{cron.name}' at #{cron.schedule}"
          require("../cron/#{cron.file}").start cron.schedule

  events: ->
    @srv.on "error", (error) -> console.log error
    @srv.on "MethodNotAllowed", unknownMethodHandler
    @srv.on "NotFound", notFoundHandler

    process.on "SIGTERM", => @srv.close()
    process.on "SIGINT", => @srv.close()
    process.on "exit", -> console.log "\n [SERVER] Closed"
    process.on "uncaughtException", (err) -> console.error "Caught exception: #{err}"

  close: ->
    @srv.on "close", ->
      console.log "\n\n [SERVER] Closing..."
      if env.mongo? then mongo.close()
      if env.redis? then redis.close()
      if app.cron?
        console.log "  - [CRON] Stopping..."
        for cron in app.cron
          console.log "     - '#{cron.name}' stopped"
          require("../cron/#{cron.file}").stop()

module.exports = Server

unknownMethodHandler = (req, res) ->
  _setCORS res
  if req.method.toLowerCase() is "options"
    res.methods.push 'OPTIONS' if res.methods.indexOf('OPTIONS') is -1
    return res.send 204
  else
    res.send new restify.MethodNotAllowedError()

notFoundHandler = (request, response) ->
  fs.readFile "pages/404.html", (error, html) ->
    if error? then html = "Not found"
    response.writeHead 404,
      "Content-Type"    : "text/html"
      "Content-Length"  : html.length
    response.write html
    do response.end

_setCORS = (res) ->
  res.header "Access-Control-Allow-Credentials", true
  res.header "Access-Control-Allow-Headers", cors.ALLOWED_HEADERS.join(", ")
  res.header "Access-Control-Allow-Methods", cors.ALLOWED_METHODS.join(", ")
  res.header "Access-Control-Expose-Headers", cors.EXPOSE_HEADERS.join(", ")
  res.header "Access-Control-Allow-Origin", cors.ALLOW_ORIGIN
