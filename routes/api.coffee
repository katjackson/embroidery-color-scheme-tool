express = require 'express'
monk = require 'monk'
router = express.Router()

router.get '/colors', (request, response, next) ->
	flossColors = request.db.get('flossColors')
	console.log request.query
	if request.query.description? && request.query.description != ''
		request.query.description =
			$regex: request.query.description
			$options: 'i'
		console.log request.query
	flossColors.find(request.query, (error, docs) ->
		response.json(docs)
		)

router.post '/scheme', (request, response, next) ->
	colorSchemes = request.db.get('colorSchemes')
	console.error new Error("Cannot retrieve colorSchemes collection") unless colorSchemes?
	flossColors = request.db.get('flossColors')
	console.error new Error("Cannot retrieve flossColors collection") unless flossColors?
	sessionId = request.session.id
	console.error new Error("Cannot retrieve sessionId") unless sessionId?
	{ flossColorId } = request.body
	console.error new Error("Cannot retrieve flossColorId collection") unless flossColorId?

	flossColors.findOne({_id: monk.id(flossColorId)}).then((flossColor) =>
		colorSchemes.update({ sessionId }, { $addToSet: { flossColors: flossColor._id } }, { upsert: true })
	)

module.exports = router
