#!/usr/bin/env node

# Module dependencies
app = require './app'
debug = require('debug')('nodetest1:server')
http = require 'http'
importData = require './private/import-data'

# Normalize a port into a number, string, or false.
normalizePort = (val) ->
	port = parseInt(val, 10)
	return val if isNaN(port)
	return port if port >= 0
	return false;

# Get port from environment and store in Express.
port = normalizePort(process.env.PORT || '3000')
app.set('port', port)

# Create HTTP server.
server = http.createServer(app)

# Event listener for HTTP server "error" event.
onError = (error) ->
	throw error unless error.syscall == 'listen'

	bind = typeof port == 'string' ? "Pipe #{port}" : "Port #{port}"

	#  handle specific listen errors with friendly messages
	switch error.code
		when 'EACCES' then () ->
			console.error "#{bind} requires elevated privileges"
			process.exit(1)
		when 'EADDRINUSE' then () ->
			console.error "#{bind} is already in use"
			process.exit(1)
		else throw error

# Event listener for HTTP server "listening" event.
onListening = ->
	addr = server.address()
	bind = typeof addr == 'string' ? "pipe #{addr}" : "port #{addr.port}"
	debug "Listening on #{bind}"

# Listen on provided port, on all network interfaces.
server.listen(port)
server.on('error', onError)
server.on('listening', onListening)

# Run data migration
importData()

module.export = server
