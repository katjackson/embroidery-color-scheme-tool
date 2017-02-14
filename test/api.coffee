chai = require 'chai'
chaiHttp = require 'chai-http'
server = require '../server'
app = require '../app'
should = chai.should()
expect = chai.expect
monk = require 'monk'
db = monk 'localhost:27017/colors'

chai.use(chaiHttp)

describe('/GET floss colors', () =>
	it('should GET all the floss colors', (done) =>
		chai.request(app)
			.get('/api/colors', (err, response, body) =>
				response.should.have.status 200
				response.body.should.be.a 'array'
				response.body.length.should.be.eql 454
			).then(done())
	)
)

describe('/GET floss color by DMC', () =>
	it('should GET floss color matching DMC', (done) =>
		chai.request(app)
			.get('/api/colors?dmc=967', (err, response) =>
				response.should.have.status 200
				response.body.should.be.a 'array'
				response.body.length.should.be.eql 1
				obj = response.body[0]
				expect(obj).to.have.property('dmc')
					.that.deep.equals('967')
				expect(obj).to.contain.all.keys([_id, dmc, anchor, description, hexValue])
			).then(done())
	)
)

describe('/GET color cousins from new calculation', () =>
	it('should GET closest colors from new calculation', (done) =>
		chai.request(app)
			.get('/api/cousins?_id=589e049c40dad83122a9f6d5', (err, response) =>
				response.should.have.status 200
				response.body.should.be.a 'array'
				response.body.length.should.be.eql 5
			).then(done())
	)
	it('should add closest colors to the database', (done) =>
		flossColorId = '589e049c40dad83122a9f6d5'
		chai.request(app)
			.get("/api/cousins?_id=#{flossColorId}")
			.then(
				flossColors = db.get('flossColors')
				flossColors.findOne({ _id: flossColorId }).then( (flossColor) ->
					flossColor.should.have.property('cousins')
				).then(done())
			)
	)
)
