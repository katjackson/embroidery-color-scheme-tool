api = '/api'

getFlossColors = ({ input, field }, handleData) ->
	query = ''
	if input? && input != ''
		query = "?#{field}=#{input}"
	$.ajax(
		url: api + '/colors' + query,
		type: 'GET',
		success: (flossColors) =>
			handleData(flossColors)
	)

getColorSchemeData = (handleData) ->
	console.log 'get scheme data'
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
	console.log 'post clear'
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

restoreSearchInput = ({ input, field })->
	$('#search-text').val(input)
	$('#search-field').val(field)

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
	colorSwatch = $("<div class='color-swatch' id='color-swatch-#{flossColor._id}' style='background-color: ##{flossColor.hexValue};'>")
	$details = $("<div class='details'>")
	$details.append(
		$("<p>").text(flossColor.description)
		$("<p>").text("DMC: #{flossColor.dmc}")
		$("<p>").text("Anchor: #{flossColor.anchor}")
	)
	addButtonHiddenClass = if isFlossColorInColorScheme then 'hidden' else ''
	removeButtonHiddenClass = if !isFlossColorInColorScheme then 'hidden' else ''
	$details.append(
		$("<button>", {
			'class': "btn btn-default add-to-color-scheme #{addButtonHiddenClass}"
			'data-color-id': "#{flossColor._id}"
			'id': "add-#{flossColor._id}"
			'title': "Add to color scheme"
		}).text("Add")
		$("<button>", {
			'class': "btn btn-default remove-from-color-scheme #{removeButtonHiddenClass}"
			'data-color-id': "#{flossColor._id}"
			'id': "remove-#{flossColor._id}"
			'title': "Remove from color scheme"
		}).text("Remove")
		$("<button>", {
			'class': "btn btn-default see-cousin-colors"
			'data-color-id': "#{flossColor._id}"
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
	else
		showAllColorsBackground()

getAndDisplaySearchResults = ({ input, field }) ->
	getFlossColors({ input, field }, (flossColors) ->
		if flossColors.length
			hideClearColorSchemeButton()
			displayResults(flossColors)
		else
			showEmptyBackground('search-results')
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

$(document.body).on('click', 'button.add-to-color-scheme', (event) ->
	flossColorId = $(event.target).data('colorId')
	addColorToColorScheme(flossColorId)
	switchAddRemoveButton(flossColorId)
)

$(document.body).on('click', 'button.remove-from-color-scheme', (event) ->
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
	flossColorId = $(event.target).data('colorId')
	getAndDisplayCousinColors(flossColorId)
	history.pushState({ flossColorId, page: 'cousins' }, null, "/cousins?_id=#{flossColorId}")
)

isValidSearchInput = ({ input, field }) ->
	return false unless input?
	if field == 'dmc' or field == 'anchor'
		return false unless parseInt(input) >= 0
	return true

showFormError = ->
	$('.error').text('Please enter a number').removeClass('hidden')

hideFormError = ->
	$('.error').text('').addClass('hidden')

clearFormInput = ->
	$('form#search-form')[0].reset()

$('form#search-form').submit( (event, other) ->
	event.preventDefault()
	input = $('#search-text').val()
	field = $('#search-field').val()
	hideFormError()

	if isValidSearchInput({ input, field })
		getAndDisplaySearchResults({ input, field })
		history.pushState({ input, field, page: 'results' }, null, "/?#{field}=#{input}")
	else
		showFormError()
)

getSearchQuery = (search) ->
	regExpForField = /\?(.*)\=/
	regExpForInput = /\=(.*)$/
	field = regExpForField.exec(search)[1]
	input = regExpForInput.exec(search)[1]
	if field == '_id'
		return { flossColorId: input }
	else
		return { input, field }


$(document).ready(() ->
	input = $('#search-text').val()
	field = $('#search-field').val()
	page = window.location.pathname.replace('/', '')
	search = window.location.search
	if search? && search != ''
		{ input, field, flossColorId } = getSearchQuery(search)
	history.replaceState({ input, field, flossColorId, page }, null, null)

	showClearColorSchemeButton() if page == 'color-scheme'
)

window.onpopstate = (event) ->
	{ input, field, page, flossColorId } = event.state
	if page == 'color-scheme'
		showClearColorSchemeButton()
		getColorSchemeData((flossColors) ->
			displayResults(flossColors)
		)
	else if page == 'cousins'
		getCousinColors(flossColorId, (flossColors) ->
			displayResults(flossColors)
		)
	else
		if input? && input != ''
			getFlossColors({ input, field }, (flossColors) ->
				displayResults(flossColors)
			).then(
				restoreSearchInput({ input, field })
			)
		else
			window.location.href = '/'
