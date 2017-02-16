_ = require 'underscore'

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

findCousinColors = (flossColors, flossColor) ->
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

		flossColors.update(flossColor, { $set: { cousins: cousinColors } })

		[flossColor].concat(cousinColors)
	)

module.exports = {
	findCousinColors
}
