"use strict"

restify   = require "restify"
fs        = require "fs"

Public =
  register: (server) ->
    server.get "/\/javascripts|stylesheets\/.*/", restify.serveStatic
      directory  : "package"
      maxAge     : 3600

    server.get "/\/images\/.*/", restify.serveStatic
      directory  : "package"
      maxAge     : 86400

    server.get "/humans.txt", (request, response, next) ->
      _file "humans.txt", "text/plain", response, next

    server.get "/robots.txt", (request, response, next) ->
      _file "robots.txt", "text/plain", response, next

_file = (file, content_type, response, next) ->
  data = fs.readFileSync "package/#{file}", "utf8"
  response.writeHead 200,
    "Content-Type"    : content_type
    "Content-Length"  : data.length
    "Cache-Control"   : "max-age=86400"
  response.write data
  do response.end
  next()

module.exports = Public
