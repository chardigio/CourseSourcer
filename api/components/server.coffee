rek = require 'rekuire'
User = rek 'models/user'

module.exports.sendError = (res, status, type, message, params) ->
  res.status(status).send error: type: type, message: message, params: params

module.exports.loadUser = (req, res, next) ->
	query = if req.query.userid is null then req.body.user else req.query.userid
	User.findById query, (err, user) ->
		if err then res.sendStatus 401
		else
			req.user = user
			next()