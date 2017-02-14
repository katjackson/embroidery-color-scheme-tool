api = '/api'

getFlossColors = ({ input, field }, handleData) ->
	if input? && input != ''
		query = "#{field}=#{input}"
	$.ajax(
		url: api + '/colors' + '?' + query,
		type: 'GET',
		success: (flossColors) =>
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

getCousinColors = (flossColorId, handleData) ->
	$.ajax(
		url: api + '/cousins' + "?_id=#{flossColorId}"
		type: 'GET'
		success: (flossColors) ->
			handleData(flossColors)
	)

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
	$details.append(
		$("<button class='see-cousin-colors' data-color-id='#{flossColor._id}'>").text("See Cousins")
	)

	colorSwatch.append($details)
	colorSwatch

deleteColorSwatch = (flossColorId) ->
	if flossColorId?
		$(".color-swatch#color-swatch-#{flossColorId}").remove()
	else
		$(".color-swatch").remove()

showClearColorSchemeButton = ->
	$('.clear-color-scheme').show()

hideClearColorSchemeButton = ->
	$('.clear-color-scheme').hide()

fillResultsBackground = (flossColors) ->
	colorScheme = []
	getColorSchemeData( (colorSchemeData) =>
		for flossColor, i in flossColors
			isFlossColorInColorScheme = flossColor._id in _.pluck(colorSchemeData, '_id')
			$('.color-background#results').append(createColorSwatch(i, flossColor, isFlossColorInColorScheme))
	)

displayResults = (flossColors) ->
	clearResultsBackground()
	hideClearColorSchemeButton()
	if flossColors.length
		fillResultsBackground(flossColors)
		showResultsBackground()
	else
		showAllColorsBackground()

getAndDisplaySearchResults = ({ input, field }) ->
	getFlossColors({ input, field }, displayResults)

getAndDisplayColorScheme = ->
	getColorSchemeData(displayResults)

getAndDisplayCousinColors = (flossColorId) ->
	getCousinColors(flossColorId, displayResults)

$(document.body).on('click', 'button.add-to-color-scheme', (event) ->
	flossColorId = $(event.target).data('colorId')
	addColorToColorScheme(flossColorId)
	switchAddRemoveButton(flossColorId)
)

$(document.body).on('click', 'button.remove-from-color-scheme', (event) ->
	flossColorId = $(event.target).data('colorId')
	console.log window.location.pathname
	if window.location.pathname == '/color-scheme'
		deleteColorSwatch(flossColorId)
	console.log 'remove click'
	removeColorFromColorScheme(flossColorId)
	switchAddRemoveButton(flossColorId)
)

$('.view-color-scheme').on('click', (event) ->
	getAndDisplayColorScheme()
	showClearColorSchemeButton()
	history.pushState({ page: 'color-scheme' }, null, "/color-scheme")
)

$(document.body).on('.clear-color-scheme', 'click', (event) ->
	clearColorScheme()
	deleteColorSwatch()
)

$(document.body).on('click', '.see-cousin-colors', (event) ->
	flossColorId = $(event.target).data('colorId')
	getAndDisplayCousinColors(flossColorId)
	history.pushState({ flossColorId, page: 'cousins' }, null, "/cousins?_id=#{flossColorId}")
)

isValidSearchInput = ({ input, field }) ->
	return false unless input?
	if field == 'dmc' or field == 'anchor'
		return false unless parseInt(input) >= 0
	return true

$('form#search-form').submit( (event, other) ->
	event.preventDefault()
	input = $('#search-text').val()
	field = $('#search-field').val()

	return unless isValidSearchInput({ input, field })

	getAndDisplaySearchResults({ input, field })
	history.pushState({ input, field, page: 'results' }, null, "/?#{field}=#{input}")
)

$(document).ready(() ->
	input = $('#search-text').val()
	field = $('#search-field').val()
	history.replaceState({ input, field }, null, null)
)

window.onpopstate = (event) ->
	{ input, field, page, flossColorId } = event.state
	if page == 'color-scheme'
		getColorSchemeData((flossColors) ->
			displayResults(flossColors)
		)
	else if page == 'cousins'
		getCousinColors(flossColorId, (flossColors) ->
			displayResults(flossColors)
		)
	else
		getFlossColors({ input, field }, (flossColors) ->
			displayResults(flossColors)
		).then(
			$('#search-text').val(input)
			$('#search-field').val(field)
		)
