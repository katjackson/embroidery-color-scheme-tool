api = '/api'

clearResultsBackground = ->
	$('.color-background#results').replaceWith($("<div class='color-background' id='results'>"))

showResultsBackground = ->
	$('.color-background#results').css('display', 'flex')
	$('.color-background#all-colors').hide()

showAllColorsBackground = ->
	$('.color-background#all-colors').css('display', 'flex')
	$('.color-background#results').hide()
	clearResultsBackground()

createColorSwatch = (id, flossColor) ->
	colorSwatch = $("<div class='color-swatch' id='color-swatch-#{id}' style='background-color: ##{flossColor.hexValue};'>")
	colorSwatch.append(
		$("<div class='details'>").append(
			$("<p>").text(flossColor.description)
			$("<p>").text("DMC: #{flossColor.dmc}")
			$("<p>").text("Anchor: #{flossColor.anchor}")
			$("<button id='add-#{flossColor._id}'>").text("Add")
		)
	)
	colorSwatch

getFlossColors = ({input, field}) ->
	if input?
		query = "#{field}=#{input}"
	$.ajax(
		url: api + '/colors' + '?' + query,
		type: 'GET',
		success: (flossColors) ->
			console.log flossColors

			clearResultsBackground()
			if flossColors.length
				for flossColor, i in flossColors
					$('.color-background#results').append(createColorSwatch(i, flossColor))
				showResultsBackground()
			else
				showAllColorsBackground()
)

postColorSchemeData = (flossColorId) ->
	$.ajax(
		url: api + '/scheme'
		type: 'POST'
		data: {flossColorId}
		success: (result) ->
			console.log 'success'
			console.log result
	)

$('button.add-to-color-scheme').on('click', (event) ->
	postColorSchemeData(event.target.id)
)

$('#color-swatch-2').on('click', getFlossColors)

$('form#search-form').submit( (event, other) ->
	event.preventDefault()
	input = $('#search-text')[0].value
	field = $('#search-field')[0].value
	getFlossColors({ input, field })
)
