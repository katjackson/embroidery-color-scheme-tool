api = '/api'

getFlossColors = ({ input, field, flossColorId }, handleData) ->
	url = api + '/colors'
	if input? && input != ''
		url += "?#{field}=#{input}"
	else if flossColorId?
		url += '/' + flossColorId
	$.ajax(
		url: url
		type: 'GET'
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
		url: api + '/colors/' + flossColorId + '/cousins'
		type: 'GET'
		success: (flossColors) ->
			handleData(flossColors)
	)

restoreSearchInput = ({ input, field })->
	field ?= 'dmc'
	$('#search-text').val(input)
	$('#search-field').val(field)

showHideDetailsButton = ->
	$('.show-details').addClass('hidden')
	$('.hide-details').removeClass('hidden')

showShowDetailsButton = ->
	$('.show-details').removeClass('hidden')
	$('.hide-details').addClass('hidden')

switchShowHideDetailsButton = ->
	$('.show-hide-details').toggleClass('hidden')

switchAddRemoveButton = (flossColorId) ->
	$(".add-to-color-scheme#add-#{flossColorId}").toggleClass('hidden')
	$(".remove-from-color-scheme#remove-#{flossColorId}").toggleClass('hidden')

clearResultsBackground = ->
	$('.color-background#results').empty()

hideAllBackgrounds = ->
	$('.color-background').addClass('hidden')
	$(".empty-background").addClass('hidden')

showEmptyBackground = (type) ->
	hideAllBackgrounds()
	$(".empty-background##{type}").removeClass('hidden')

showResultsBackground = ->
	hideAllBackgrounds()
	$('.color-background#results').removeClass('hidden')

showAllColorsBackground = ->
	hideAllBackgrounds()
	$('.color-background#all-colors').removeClass('hidden')
	clearResultsBackground()

createColorSwatch = (id, flossColor, isFlossColorInColorScheme) ->
	addButtonHiddenClass = if isFlossColorInColorScheme then 'hidden' else ''
	removeButtonHiddenClass = if !isFlossColorInColorScheme then 'hidden' else ''
	colorSwatch = $("<div>", {
		'class': "color-swatch large"
		'data-color-id': flossColor._id
		'id': "color-swatch-#{flossColor._id}"
		'style': "background-color: ##{flossColor.hexValue};"
	})
	$details = $("<div class='details'>")
	$details.append(
		$("<div class='text'>").append(
			$("<p>").text(flossColor.description)
			$("<p>").text("DMC: #{flossColor.dmc}")
			$("<p>").text("Anchor: #{flossColor.anchor}")
		)
		$("<button>", {
			'class': "btn btn-default add-to-color-scheme #{addButtonHiddenClass}"
			'data-color-id': flossColor._id
			'id': "add-#{flossColor._id}"
			'title': "Add to color scheme"
		}).text("Add")
		$("<button>", {
			'class': "btn btn-default remove-from-color-scheme #{removeButtonHiddenClass}"
			'data-color-id': flossColor._id
			'id': "remove-#{flossColor._id}"
			'title': "Remove from color scheme"
		}).text("Remove")
		$("<button>", {
			'class': "btn btn-default see-cousin-colors"
			'data-color-id': flossColor._id
			'title': "Find closest embroidery floss colors"
		}).text("Closest Colors")
	)
	colorSwatch.append($details)
	colorSwatch

deleteColorSwatch = (flossColorId) ->
	if flossColorId?
		$(".color-swatch#color-swatch-#{flossColorId}").remove()
	else
		$(".color-swatch").remove()

showClearColorSchemeButton = ->
	$('.clear-color-scheme').removeClass('hidden')

hideClearColorSchemeButton = ->
	$('.clear-color-scheme').addClass('hidden')

fillResultsBackground = (flossColors) ->
	colorScheme = []
	getColorSchemeData( (colorSchemeData) =>
		for flossColor, i in flossColors
			isFlossColorInColorScheme = flossColor._id in _.pluck(colorSchemeData, '_id')
			$('.color-background#results').append(createColorSwatch(i, flossColor, isFlossColorInColorScheme))
	)

displayResults = (flossColors) ->
	clearResultsBackground()
	if flossColors.length
		fillResultsBackground(flossColors)
		showResultsBackground()
		showHideDetailsButton()
	else
		showAllColorsBackground()

getAndDisplaySearchResults = ({ input, field, flossColorId }) ->
	getFlossColors({ input, field, flossColorId }, (flossColors) ->
		if flossColors.length
			hideClearColorSchemeButton()
			displayResults(flossColors)
		else
			showEmptyBackground('search-results')
		restoreSearchInput({ input, field })
	)

getAndDisplayColorScheme = ->
	clearFormInput()
	getColorSchemeData((flossColors) ->
		if flossColors.length
			showClearColorSchemeButton()
			displayResults(flossColors)
		else
			showEmptyBackground('color-scheme')
	)

getAndDisplayCousinColors = (flossColorId) ->
	clearFormInput()
	hideClearColorSchemeButton()
	getCousinColors(flossColorId, displayResults)

$('.view-color-scheme').on('click', (event) ->
	getAndDisplayColorScheme()
	history.pushState({ page: 'color-scheme' }, null, "/color-scheme")
)

$('.show-hide-details').on('click', (event) ->
	switchShowHideDetailsButton()
	$('.details').toggleClass('hidden')
)

$(document.body).on('click', '.color-swatch.small, .color-swatch.large .details .text', (event) ->
	flossColorId = $(event.target.closest('.color-swatch')).data('colorId')
	getFlossColors({ flossColorId }, (flossColors) ->
		hideClearColorSchemeButton()
		displayResults(flossColors)
	)
	history.pushState({ flossColorId, page: "colors" }, null, "/colors/#{flossColorId}")
)

$(document.body).on('click', 'button.add-to-color-scheme', (event) ->
	event.stopPropagation()
	flossColorId = $(event.target).data('colorId')
	addColorToColorScheme(flossColorId)
	switchAddRemoveButton(flossColorId)
)

$(document.body).on('click', 'button.remove-from-color-scheme', (event) ->
	event.stopPropagation()
	flossColorId = $(event.target).data('colorId')
	if window.location.pathname == '/color-scheme'
		deleteColorSwatch(flossColorId)
	removeColorFromColorScheme(flossColorId)
	switchAddRemoveButton(flossColorId)
)

$(document.body).on('click', '.clear-color-scheme', (event) ->
	clearColorScheme()
	deleteColorSwatch()
	showEmptyBackground('color-scheme')
)

$(document.body).on('click', '.see-cousin-colors', (event) ->
	event.stopPropagation()
	flossColorId = $(event.target).data('colorId')
	getAndDisplayCousinColors(flossColorId)
	history.pushState({ flossColorId, page: "cousins" }, null, "/cousins/#{flossColorId}")
)

isValidSearchInput = ({ input, field }) ->
	return false unless input? && input != ''
	if field == 'dmc' or field == 'anchor'
		return false unless parseInt(input) >= 0
	currentQuery = window.location.search
	if currentQuery? && currentQuery != ''
		currentSearchValues = getSearchValuesFromQueryString(currentQuery)
		if currentSearchValues.input == input && currentSearchValues.field == field
			return false
	return true

showFormError = (field) ->
	errors =
		'dmc': "Please enter a number."
		'anchor': "Please enter a number."
		'description': "Please enter a search term."
	$('.error').text(errors[field])

hideFormError = ->
	$('.error').text('')

clearFormInput = ->
	$('form#search-form')[0].reset()

$('form#search-form').submit( (event, other) ->
	event.preventDefault()
	input = $('#search-text').val()
	field = $('#search-field').val()
	hideFormError()

	if isValidSearchInput({ input, field })
		getAndDisplaySearchResults({ input, field })
		history.pushState({ input, field, page: '' }, null, "/?#{field}=#{input}")
	else
		showFormError(field)
)

getSearchValuesFromQueryString = (search) ->
	regExpForField = /\?(.*)\=/
	regExpForInput = /\=(.*)$/
	field = regExpForField.exec(search)[1]
	input = regExpForInput.exec(search)[1]
	if input == ''
		return {}
	else if field == '_id'
		return { flossColorId: input }
	else
		return { input, field }


$(document).ready(() ->
	page = window.location.pathname
	if page == '/'
		search = window.location.search
		{ input, field } = getSearchValuesFromQueryString(search)
	else
		urlParts = page.split('/')
		page = urlParts[1]
		flossColorId = urlParts[2]
	history.replaceState({ input, field, flossColorId, page }, null, null)

	showClearColorSchemeButton() if page == 'color-scheme'
)

window.onpopstate = (event) ->
	{ input, field, page, flossColorId } = event.state
	if page == 'color-scheme'
		getAndDisplayColorScheme()
	else if page.endsWith('cousins')
		getAndDisplayCousinColors(flossColorId)
	else
		if input? || flossColorId?
			getAndDisplaySearchResults({ input, field, flossColorId })
		else
			window.location.href = '/'
