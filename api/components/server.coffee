rek = require 'rekuire'
User = rek 'models/user'

module.exports.sendError = (res, status, type, message, params) ->
  res.status(status).send error: type: type, message: message, params: params

module.exports.loadUser = (req, res, next) ->
  User.findById req.query.user, (err, user) ->
    if err or not user
      console.log "ERROR LOADING USER:", err
      res.sendStatus 403
    else if not req.query.device in user.devices
      console.log "BAD DEVICE IN QUERY:", req.query
      res.sendStatus 403
    else
      req.user = user
      next()