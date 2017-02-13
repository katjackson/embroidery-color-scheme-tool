api = '/api'

switchAddRemoveButton = (flossColorId) ->
	$(".add-to-color-scheme#add-#{flossColorId}").toggleClass('hidden')
	$(".remove-from-color-scheme#remove-#{flossColorId}").toggleClass('hidden')

clearResultsBackground = ->
	$('.color-background#results').empty()

showResultsBackground = ->
	$('.color-background#results').css('display', 'flex')
	$('.color-background#all-colors').hide()

showAllColorsBackground = ->
	$('.color-background#all-colors').css('display', 'flex')
	$('.color-background#results').hide()
	clearResultsBackground()

createColorSwatch = (id, flossColor, isFlossColorInColorScheme) ->
	colorSwatch = $("<div class='color-swatch' id='color-swatch-#{flossColor._id}' style='background-color: ##{flossColor.hexValue};'>")
	$details = $("<div class='details'>")
	$details.append(
		$("<p>").text(flossColor.description)
		$("<p>").text("DMC: #{flossColor.dmc}")
		$("<p>").text("Anchor: #{flossColor.anchor}")
	)
	if isFlossColorInColorScheme
		$details.append(
			$("<button class='add-to-color-scheme hidden' data-color-id='#{flossColor._id}' id='add-#{flossColor._id}'>").text("Add")
			$("<button class='remove-from-color-scheme' data-color-id='#{flossColor._id}' id='remove-#{flossColor._id}'>").text("Remove")
		)
	else
		$details.append(
			$("<button class='add-to-color-scheme' data-color-id='#{flossColor._id}' id='add-#{flossColor._id}'>").text("Add")
			$("<button class='remove-from-color-scheme hidden' data-color-id='#{flossColor._id}' id='remove-#{flossColor._id}'>").text("Remove")
		)

	colorSwatch.append($details)
	colorSwatch

deleteColorSwatch = (flossColorId) ->
	if flossColorId?
		$(".color-swatch#color-swatch-#{flossColorId}").remove()
	else
		$(".color-swatch").remove()

fillResultsBackground = (flossColors) ->
	colorScheme = []
	getColorSchemeData( (colorSchemeData) =>
		for flossColor, i in flossColors
			isFlossColorInColorScheme = flossColor._id in _.pluck(colorSchemeData, '_id')
			$('.color-background#results').append(createColorSwatch(i, flossColor, isFlossColorInColorScheme))
	)

getFlossColors = ({ input, field }, handleData) ->
	if input?
		query = "#{field}=#{input}"
	$.ajax(
		url: api + '/colors' + '?' + query,
		type: 'GET',
		success: (flossColors) ->
			handleData(flossColors)
	)

getColorSchemeData = (handleData) ->
	$.ajax(
		url: api + '/scheme'
		type: 'GET'
		success: (flossColors) ->
			handleData(flossColors)
	)

addColorToColorScheme = (flossColorId) ->
	console.log 'post action add', flossColorId
	$.ajax(
		url: api + '/scheme' + '?action=add'
		type: 'POST'
		data: { flossColorId }
	)

removeColorFromColorScheme = (flossColorId) ->
	$.ajax(
		url: api + '/scheme' + '?action=remove'
		type: 'POST'
		data: { flossColorId }
	)

clearColorScheme = ->
	$.ajax(
		url: api + '/scheme' + '?action=clear'
		type: 'POST'
	)

getCousinColors = (flossColorId)->
	$.ajax(
		url: api + '/cousins' + "?id=#{flossColorId}"
		type: 'GET'
		success: (flossColors) ->
			console.log flossColors
			# handleData(flossColors)
	)

$(document.body).on('click', 'button.add-to-color-scheme', (event) ->
	flossColorId = $(event.target).data('colorId')
	addColorToColorScheme(flossColorId)
	switchAddRemoveButton(flossColorId)
)

$(document.body).on('click', 'button.remove-from-color-scheme', (event) ->
	flossColorId = $(event.target).data('colorId')
	parentColorBackground = $(event.target).parents('.color-background')
	if parentColorBackground.attr('id') == 'color-scheme'
		console.log 'color-scheme page!'
		deleteColorSwatch(flossColorId)
	console.log 'remove click'
	removeColorFromColorScheme(flossColorId)
	switchAddRemoveButton(flossColorId)
)

$('.clear-color-scheme').on('click', (event) ->
	clearColorScheme()
	deleteColorSwatch()
)

$('.get-cousin-colors').on('click', (event) ->
	flossColorId = $(event.target).data('colorId')
	getCousinColors(flossColorId)
)

$('form#search-form').submit( (event, other) ->
	event.preventDefault()
	input = $('#search-text')[0].value
	field = $('#search-field')[0].value
	getFlossColors({ input, field }, (flossColors) ->
		clearResultsBackground()
		if flossColors.length
			fillResultsBackground(flossColors)
			showResultsBackground()
		else
			showAllColorsBackground()
	)
)
