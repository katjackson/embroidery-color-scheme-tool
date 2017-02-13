_ = require 'underscore'
express = require 'express'
monk = require 'monk'
router = express.Router()

calculateCloseness = (hexValue1, hexValue2) ->
	r1 = parseInt(hexValue1.substring(0, 2), 16)
	g1 = parseInt(hexValue1.substring(2, 4), 16)
	b1 = parseInt(hexValue1.substring(4, 6), 16)

	r2 = parseInt(hexValue2.substring(0, 2), 16)
	g2 = parseInt(hexValue2.substring(2, 4), 16)
	b2 = parseInt(hexValue2.substring(4, 6), 16)

	r = 255 - Math.abs(r1 - r2)
	g = 255 - Math.abs(g1 - g2)
	b = 255 - Math.abs(b1 - b2)

	r /= 255
	g /= 255
	b /= 255
	# 1.0 is a perfect match, 0 is complete opposite colors
	(r + g + b) / 3

findCousinColors = (flossColor, flossColors, callback) ->
	flossColors.find({}).then((docs) =>
		closenessCalculations = []
		flossColorsInHex = _.pluck(docs, 'hexValue')

		for color in flossColorsInHex
			closenessCalculations.push
				hexValue: "#{color}"
				closeness: calculateCloseness(flossColor.hexValue, color)

		sortedClosenessCalculations = _.sortBy(closenessCalculations, 'closeness').reverse()
		topFiveClosestHexValues = _.pluck(sortedClosenessCalculations.slice(1, 6), 'hexValue')
		cousinColors = docs.filter((doc) -> doc.hexValue in topFiveClosestHexValues)
		callback cousinColors

		flossColors.update(flossColor, { $set: { cousins: cousinColors } })
	)

router.get '/colors', (request, response, next) ->
	flossColors = request.db.get('flossColors')
	throw new Error("Cannot retrieve flossColors collection") unless flossColors?
	if request.query.description? && request.query.description != ''
		request.query.description =
			$regex: request.query.description
			$options: 'i'
	flossColors.find(request.query, (error, docs) ->
		response.json(docs)
		)

router.post '/scheme', (request, response, next) ->
	colorSchemes = request.db.get('colorSchemes')
	throw new Error("Cannot retrieve colorSchemes collection") unless colorSchemes?
	flossColors = request.db.get('flossColors')
	throw new Error("Cannot retrieve flossColors collection") unless flossColors?
	sessionId = request.session.id
	throw new Error("Cannot retrieve sessionId") unless sessionId?
	{ flossColorId } = request.body

	if request.query.action == 'add'
		flossColors.findOne({_id: flossColorId}).then((flossColor) =>
			colorSchemes.update({ sessionId }, { $addToSet: { flossColors: flossColor._id } }, { upsert: true })
		)

	else if request.query.action == 'remove'
		flossColors.findOne({_id: monk.id(flossColorId)}).then((flossColor) =>
			colorSchemes.update({ sessionId }, { $pull: { flossColors: flossColor._id } })
		)

	else if request.query.action == 'clear'
		colorSchemes.update({ sessionId }, { $set: { flossColors: [] } })

router.get '/scheme', (request, response, next) ->
	colorSchemes = request.db.get('colorSchemes')
	throw new Error("Cannot retrieve colorSchemes collection") unless colorSchemes?
	flossColors = request.db.get('flossColors')
	throw new Error("Cannot retrieve flossColors collection") unless flossColors?
	sessionId = request.session.id
	throw new Error("Cannot retrieve sessionId") unless sessionId?
	colorSchemes.findOne({ sessionId }).then((colorScheme) =>
		flossColors.find({ _id: { $in: colorScheme?.flossColors } }, (error, docs) ->
			docs ?= []
			response.json(docs)
		)
	)

router.get '/cousins', (request, response, next) ->
	flossColors = request.db.get('flossColors')
	throw new Error("Cannot retrieve flossColors collection") unless flossColors?
	flossColorId = request.query.id
	flossColors.findOne({ _id: flossColorId }).then( (flossColor) ->
		response.json([]) unless flossColor?

		if flossColor.cousins?.length
			response.json(flossColor.cousins)
		else
			findCousinColors(flossColor, flossColors, (data) =>
				response.json(data)
			)
	)

module.exports = router
