express = require 'express'
router = express.Router()
monk = require 'monk'
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
		sessionId: request.session.id
	}

	flossColors = request.db.get('flossColors')
	colorSchemes = request.db.get('colorSchemes')
	colorSchemes.findOne({ sessionId: request.session.id }).then((colorScheme) =>
		flossColors.find({}).then( (docs) =>
			if colorScheme?
				colorSchemeIds = colorScheme.flossColors.map( (colorId) -> colorId.toString() )
				data.flossColors = docs.map( (doc) ->
					doc.isInColorScheme = doc._id.toString() in colorSchemeIds
					return doc
				)
			else
				data.flossColors = docs
			response.render('index', data)
		)
	)


router.get '/color-scheme', (request, response, next) ->
	colorSchemes = request.db.get('colorSchemes')
	throw new Error("Cannot retrieve colorSchemes collection") unless colorSchemes?
	flossColors = request.db.get('flossColors')
	throw new Error("Cannot retrieve flossColors collection") unless flossColors?
	sessionId = request.session.id
	throw new Error("Cannot retrieve sessionId") unless sessionId?
	colorSchemes.findOne({ sessionId }).then((colorScheme) =>
		flossColors.find({ _id: { $in: colorScheme?.flossColors } }, (error, docs) ->
			docs ?= []
			response.render('color-scheme', { flossColors: docs })
		)
	)

# router.get '/:anyString', (request, response, next) ->
# 	data = {
# 		title: request.params.anyString
# 	}
# 	response.render('index', data)

module.exports = router
