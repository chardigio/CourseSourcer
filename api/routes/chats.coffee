_ = require 'lodash'
router = (require 'express').Router()
rek = require 'rekuire'
Chat = rek 'models/chat'
User = rek 'models/user'
server = rek 'components/server'

#post chat
router.post '/', (req, res, next) -> #server.loadUser was here
  User.findOne email: req.body.to, (err, partner) ->
    console.log "partner:", partner
    if err then next err
    else
      chat = new Chat _.pick req.body, 'text', 'course'
      chat.from = req.body.user
      chat.to = partner.id

      chat.save (err, chat) ->
        console.log "chat:", chat
        if err then next err
        else res.status(201).send 'chat': chat

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
          {to: req.user.id}, {from: partner.id}
        ]},
        {$and: [
          {to: partner.id}, {from: req.user.id}
        ]}
      ]}

      if lastId and lastId isnt null and lastId isnt ''
        Chat.find({$and: [search, {_id: {$gt: lastId}}]}).sort('-created_at').limit(limit).exec (err, nextChats) ->
          if err then next err
          else
            for chat in nextChats #not deepcopy, fix
              chat.to = chat.to.email
              chat.from = chat.from.email
            res.send chats: nextChats #.reverse()
      else
        Chat.find(search).sort('-created_at').skip(offset).limit(limit).exec (err, chats) ->
          if err then next err
          else
            for chat in chats #not deepcopy, fix
              chat.to = chat.to.email
              chat.from = chat.from.email

            res.send chats: chats #.reverse()

module.exports = router
