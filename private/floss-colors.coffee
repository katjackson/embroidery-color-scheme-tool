getFlossColorMongoQuery = (query) ->
	if query?.description? && query?.description != ''
		query.description =
			$regex: query.description
			$options: 'i'
	query

module.exports = {
	getFlossColorMongoQuery
}
