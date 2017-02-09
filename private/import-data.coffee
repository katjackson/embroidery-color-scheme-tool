fs = require 'fs'
csv = require 'csvtojson'
monk = require 'monk'

flossDataFilePath = './private/dmcColorChart.csv'

importCsvData = (filePath, callback) ->
	documents = []
	csv()
		.fromFile(filePath)
		.on('json', (jsonObject) ->
			documents.push(jsonObject)
		).on('end', (error) ->
			console.error if error?
			console.log "Read #{documents.length} documents from file."
			callback(documents)
		)

importDataIntoMongo = ->
	db = monk 'localhost:27017/colors'
	FlossColors = db.get('flossColors')

	FlossColors.count({}, (error, count) ->
		console.error if error?
		if count > 0
			db.close()
		else
			importCsvData(flossDataFilePath, (flossColorDocuments) ->
				FlossColors.insert(flossColorDocuments, (error, result) ->
					console.error if error?
					console.log "Inserted #{result.length} floss colors."
					db.close()
				)
			)
	)

module.exports = importDataIntoMongo
