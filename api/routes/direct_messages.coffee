_ = require 'lodash'
router = (require 'express').Router()
rek = require 'rekuire'
DirectMessage = rek 'models/direct_message'
User = rek 'models/user'
server = rek 'components/server'

#post dm
router.post '/', server.loadUser, (req, res, next) ->
  User.findOne email: req.body.to_email, (err, partner) ->
    if err then next err
    else
      direct_message = new DirectMessage _.pick req.body, 'text', 'course', 'to_email'
      direct_message.from = req.body.id
      direct_message.to = partner.id
      direct_message.from_email = req.user.email

      direct_message.save (err, directMessage) ->
        if err then next err
        else res.status(201).send direct_message: directMessage

router.get '/:partnerEmail', server.loadUser, (req, res, next) ->
  User.findOne email: req.params.partnerEmail, (err, partner) ->
    if err then next err
    else
      nullQuery = (query) -> query is '' or isNaN(+query) or Math.round(+query <= 0)

      limit = req.query.limit
      offset = req.query.offset
      lastId = req.query.lastId

      if nullQuery limit then limit = 25 #if limit isnt specified, return 25
      else if +limit > 50 then limit = 50 #max is 50
      else limit = Math.ceil +limit #otherwise just return however many are asked for

      if nullQuery offset then offset = 0

      search = {$or: [
        {$and: [
          {to_email: req.user.email}, {from_email: partner.email}
        ]},
        {$and: [
          {to_email: partner.email}, {from_email: req.user.email}
        ]}
      ]}

      console.log req.user
      console.log partner
      console.log search

      if lastId and lastId isnt null and lastId isnt ''
        DirectMessage.find({$and: [search, {_id: {$gt: lastId}}]}).sort('-created_at').limit(limit).populate('from').exec (err, nextDirectMessages) ->
          if err then next err
          else res.send direct_messages: nextDirectMessages
      else
        DirectMessage.find(search).sort('-created_at').skip(offset).limit(limit).populate('from').populate('to').exec (err, directMessages) ->
          if err then next err
          else
            console.log directMessages
            res.send direct_messages: directMessages

module.exports = router
