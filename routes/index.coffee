express = require 'express'
router = express.Router()
randomstring = require 'randomstring'

createAndStoreSessionVariable = (db) ->
	sessions = db.get('sessions')
	sessionId = randomstring.generate()
	console.log "using session id #{sessionId}"
	sessions.insert({sessionId, timestamp: new Date()})
	sessionId

router.get '/', (request, response, next) ->
	unless request.session.id?
		request.session.id = createAndStoreSessionVariable(request.db)
	console.log "session: ", request.session
	console.log "cookies: ", request.cookies
	data = {
		title: 'Stitch Color Scheme Tool'
	}

	flossColors = request.db.get('flossColors')
	flossColors.find({}).then( (docs) =>
		data.flossColors = docs
		response.render('index', data)
	)

# router.get '/:anyString', (request, response, next) ->
# 	data = {
# 		title: request.params.anyString
# 	}
# 	response.render('index', data)

module.exports = router
