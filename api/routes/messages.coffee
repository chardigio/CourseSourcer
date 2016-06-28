_ = require 'lodash'
router = (require 'express').Router()
rek = require 'rekuire'
Message = rek 'models/message'
server = rek 'server'

#post message
router.post '/', server.loadUser, (req, res, next) -> #load user and check for by_admin
  msg = new Message _.pick req.body, 'text', 'course', 'user'
  msg.score = 0
  msg.by_admin = (req.user.admin_of.indexOf msg.course > -1)

  msg.save (err, message) ->
    if err then next err
    else res.status(201).send mesesage: message

#like message
router.put '/like', (req, res,next) ->
  Message.findById req.body.message_id, (err, msg) ->
    if err then next err
    else
      msg.score++
      msg.save (err, message) ->
        if err then next err
        else res.status(200).send message: message

#dislike message
router.put '/dislike', (req, res,next) ->
  Message.findById req.body.message_id, (err, msg) ->
    if err then next err
    else
      msg.score--
      msg.save (err, message) ->
        if err then next err
        else res.status(200).send message: message

#get messages for a course
router.get '/of_course/:courseId', server.loadUser, (req, res, next) ->
  nullQuery = (query) -> query is '' or isNaN(+query) or Math.round(+query <= 0)

  limit = req.query.limit
  offset = req.query.offset
  lastId = req.query.lastId

  if nullQuery limit then limit = 25 #if limit isnt specified, return 25
  else if +limit > 50 then limit = 50 #max is 50
  else limit = Math.ceil +limit #otherwise just return however many are asked for

  if nullQuery offset then offset = 0

  admin = (req.user.admin_of.indexOf req.params.courseId > -1)

  if lastId isnt null and lastId isnt ''
    Message.find(_id: $gt: lastId, course: req.params.courseId).sort('-created_at').limit(limit).populate('user').exec (err, nextMessages) ->
      if err then next err
      else
        if not admin
          for message in nextMessages #not deepcopy, fix
            if message.user.id isnt req.user.id then message.user = null
        res.send messages: nextMessages.reverse()
  else
    Message.find(course: req.params.courseId).sort('-created_at').skip(offset).limit(limit).populate('user').exec (err, messages) ->
      if err then next err
      else
        if not admin
          for message in messages #not deepcopy, fix
            if message.user.id isnt req.user.id then message.user = null
        res.send messages: messages.reverse()

module.exports = router
