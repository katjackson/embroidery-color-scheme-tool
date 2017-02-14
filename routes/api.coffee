express = require 'express'
router = express.Router()
{ getFlossColorMongoQuery  } = require '../private/floss-colors'
{ findCousinColors } = require '../private/cousin-colors'

router.get '/colors', (request, response, next) ->
	flossColors = request.db.get('flossColors')
	query = getFlossColorMongoQuery(request.query)
	flossColors.find(query).then((data) =>
		response.json(data)
	)

router.post '/scheme', (request, response, next) ->
	colorSchemes = request.db.get('colorSchemes')
	flossColors = request.db.get('flossColors')
	sessionId = request.session.id
	{ flossColorId } = request.body

	if request.query.action == 'add'
		flossColors.findOne({ _id: flossColorId }).then((flossColor) =>
			colorSchemes.update({ sessionId }, { $addToSet: { flossColors: flossColor._id } }, { upsert: true })
		)

	else if request.query.action == 'remove'
		flossColors.findOne({ _id: flossColorId }).then((flossColor) =>
			colorSchemes.update({ sessionId }, { $pull: { flossColors: flossColor._id } })
		)

	else if request.query.action == 'clear'
		colorSchemes.update({ sessionId }, { $set: { flossColors: [] } })

router.get '/scheme', (request, response, next) ->
	colorSchemes = request.db.get('colorSchemes')
	flossColors = request.db.get('flossColors')
	sessionId = request.session.id
	if !sessionId?
		response.render('color-scheme', { flossColors: [] })

	colorSchemes.findOne({ sessionId })
		.then((colorScheme) =>
			if !colorScheme?.flossColors?.length
				return []
			else
				return flossColors.find({ _id: { $in: colorScheme?.flossColors } })
		).then((data) =>
			response.json(data)
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
	).then((data) =>
		response.json(data)
	)

module.exports = router
