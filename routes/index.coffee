express = require 'express'
router = express.Router()
monk = require 'monk'
randomstring = require 'randomstring'
{ getFlossColorMongoQuery  } = require '../private/floss-colors'

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

	data = {}
	flossColors = request.db.get('flossColors')
	colorSchemes = request.db.get('colorSchemes')
	query = getFlossColorMongoQuery(request.query)
	flossColors.find(query).then((flossColorDocuments) =>
		colorSchemes.findOne({ sessionId: request.session.id }).then((colorScheme) =>
			if colorScheme?
				colorSchemeIds = colorScheme.flossColors.map( (colorId) -> colorId.toString() )
				flossColorDocuments = flossColorDocuments.map( (doc) ->
					doc.isInColorScheme = doc._id.toString() in colorSchemeIds
					return doc
				)
			return flossColorDocuments
		).then((flossColorDocuments) =>
			data.flossColors = flossColorDocuments
			response.render('index', data)
		)
	)

router.get '/cousins', (request, response, next) ->
	flossColors = request.db.get('flossColors')
	flossColors.findOne(request.query).then((flossColor) =>
		if !flossColor?
			return []
		else if flossColor.cousins?.length
			return flossColor.cousins
		else
			return findCousinColors(flossColors, flossColor)
	).then((flossColorDocuments) =>
		response.render('index', { flossColors: flossColorDocuments })
	)

router.get '/color-scheme', (request, response, next) ->
	colorSchemes = request.db.get('colorSchemes')
	flossColors = request.db.get('flossColors')
	sessionId = request.session.id
	if !sessionId?
		response.render('color-scheme', { flossColors: [] })
	colorSchemes.findOne({ sessionId })
		.then((colorScheme) =>
			flossColors.find({ _id: { $in: colorScheme?.flossColors } })
		).then((docs) ->
			docs ?= []
			response.render('color-scheme', { flossColors: docs })
		)

module.exports = router
