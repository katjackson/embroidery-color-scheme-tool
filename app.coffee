express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
session = require 'client-sessions'
monk = require 'monk'
db = monk 'localhost:27017/colors'

index = require './routes/index'
api = require './routes/api'

app = express()

# view engine setup
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')

#  uncomment after placing your favicon in /public
# app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')))
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: false })
app.use cookieParser()
app.use express.static(path.join(__dirname, 'public'))

app.use( (request, response, next) =>
	request.db = db
	next();
)

app.use(session(
  cookieName: 'session'
  secret: 'jp0Y6uMYk8RRUv74uiuFi6jisPdhJ9mE'
  duration: 60 * 60 * 1000
  activeDuration: 30 * 60 * 1000
))

app.use('/', index)
app.use('/api', api)

#  catch 404 and forward to error handler
app.use (request, response, next) ->
	error = new Error 'Not Found'
	error.status = 404
	next(error)

# error handler
app.use (error, request, response, next) ->
	console.error(error.stack)

	# set locals, only providing error in development
	response.locals.message = error.message
	response.locals.error = response.app.get('env') == 'development' ? error : {}

	# render the error page
	response.status(error.status || 500)
	response.render('error')

module.exports = app
