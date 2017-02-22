express = require 'express'
router = express.Router()
monk = require 'monk'
randomstring = require 'randomstring'
{ getFlossColorMongoQuery  } = require '../private/floss-colors'

createAndStoreSessionVariable = (db) ->
	sessions = db.get('sessions')
	sessionId = randomstring.generate()
	console.log "Using session id #{sessionId}"
	sessions.insert({ sessionId, timestamp: new Date() })
	sessionId

addInColorSchemePropertyToFlossColors = (flossColorDocuments, colorScheme) =>
	colorSchemeIds = colorScheme.flossColors.map( (colorId) -> colorId.toString() )
	flossColorDocuments = flossColorDocuments.map( (doc) ->
		doc.isInColorScheme = doc._id.toString() in colorSchemeIds
		return doc
	)
	flossColorDocuments

router.get '/', (request, response, next) ->
	unless request.session.id?
		request.session.id = createAndStoreSessionVariable(request.db)

	flossColors = request.db.get('flossColors')
	colorSchemes = request.db.get('colorSchemes')
	data = {
		flossColors: []
		flossColorsResults: []
	}
	query = getFlossColorMongoQuery(request.query)

	flossColors.find(query).then((flossColorSearchResults) =>
		colorSchemes.findOne({ sessionId: request.session.id }).then((colorScheme) =>
			if colorScheme?
				addInColorSchemePropertyToFlossColors(flossColorSearchResults, colorScheme)
			else
				return flossColorSearchResults
		).then((flossColorDocuments) =>
			if flossColorDocuments.length == 454
				data.flossColors = flossColorDocuments
			else if flossColorDocuments.length == 0
				data.noResults = true
			else
				data.flossColorsResults = flossColorDocuments
			response.render('index', data)
		)
	).catch((error) => console.error error)

router.get '/colors/:_id', (request, response, next) ->
	flossColors = request.db.get('flossColors')
	colorSchemes = request.db.get('colorSchemes')
	sessionId = request.session.id
	_id = request.params._id
	data = {
		flossColors: []
		flossColorsResults: []
	}

	flossColors.find({_id}).then((flossColorSearchResults) =>
		colorSchemes.findOne({ sessionId }).then((colorScheme) =>
			if colorScheme?
				addInColorSchemePropertyToFlossColors(flossColorSearchResults, colorScheme)
			else
				return flossColorSearchResults
		).then((flossColorDocuments) =>
			if flossColorDocuments.length == 0
				data.noResults = true
			else
				data.flossColorsResults = flossColorDocuments
			response.render('index', data)
		)
	).catch((error) => console.error error)


router.get '/cousins/:_id', (request, response, next) ->
	flossColors = request.db.get('flossColors')
	colorSchemes = request.db.get('colorSchemes')
	sessionId = request.session.id
	_id = request.params._id
	data = {
		flossColors: []
		flossColorsResults: []
	}

	flossColors.findOne({_id}).then((flossColor) =>
		if !flossColor?
			return []
		else if flossColor.cousins?.length
			return [flossColor].concat(flossColor.cousins)
		else
			return findCousinColors(flossColors, flossColor)
	).then((flossColorDocuments) =>
		colorSchemes.findOne({ sessionId }).then((colorScheme) =>
			if colorScheme?
				addInColorSchemePropertyToFlossColors(flossColorDocuments, colorScheme)
			else
				return flossColorDocuments
		).then((flossColorsToDisplay) =>
			data.flossColorsResults = flossColorsToDisplay
			response.render('index', data)
		)
	).catch((error) => console.error error)

router.get '/color-scheme', (request, response, next) ->
	colorSchemes = request.db.get('colorSchemes')
	flossColors = request.db.get('flossColors')
	sessionId = request.session.id
	data = {
		flossColors: []
		flossColorsResults: []
	}
	if !sessionId?
		data.colorSchemeIsEmpty = true
		response.render('index', data)
	else
		colorSchemes.findOne({ sessionId }).then((colorScheme) =>
			if colorScheme?
				return flossColors.find({ _id: { $in: colorScheme?.flossColors } })
			else
				return []
		).then((docs) ->
			if docs.length == 0
				data.colorSchemeIsEmpty = true
			else
				data.flossColorsResults = docs.map((doc) ->
					doc.isInColorScheme = true
					return doc
				)
			response.render('index', data)
		).catch((error) => console.error error)

module.exports = router
