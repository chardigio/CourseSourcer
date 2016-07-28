_ = require 'lodash'
router = (require 'express').Router()
rek = require 'rekuire'
GroupMessage = rek 'models/group_message'
server = rek 'server'

#post group_message
router.post '/', server.loadUser, (req, res, next) -> #load user and check for by_admin
  msg = new GroupMessage _.pick req.body, 'text', 'course', 'user'
  msg.score = 0
  msg.user_email = req.user.email

  msg.save (err, groupMessage) ->
    if err then next err
    else res.status(201).send message: groupMessage

#like group_message
router.put '/like', (req, res,next) ->
  GroupMessage.findById req.body.group_message_id, (err, msg) ->
    if err then next err
    else
      msg.score++
      msg.save (err, groupMessage) ->
        if err then next err
        else res.status(200).send group_message: groupMessage

#dislike group_message
router.put '/dislike', (req, res,next) ->
  GroupMessage.findById req.body.group_message_id, (err, msg) ->
    if err then next err
    else
      msg.score--
      msg.save (err, groupMessage) ->
        if err then next err
        else res.status(200).send group_message: groupMessage

#get group_messages for a course
router.get '/of_course/:courseId', server.loadUser, (req, res, next) ->
  nullQuery = (query) -> query is '' or isNaN(+query) or Math.round(+query <= 0)

  limit = req.query.limit
  offset = req.query.offset
  lastId = req.query.lastId

  if nullQuery limit then limit = 25 #if limit isnt specified, return 25
  else if +limit > 50 then limit = 50 #max is 50
  else limit = Math.ceil +limit #otherwise just return however many are asked for

  if nullQuery offset then offset = 0

  #admin = (req.user.admin_of.indexOf req.params.courseId > -1)
  admin = no

  if lastId and lastId isnt null and lastId isnt ''
    GroupMessage.find(_id: $gt: lastId, course: req.params.courseId).sort('-created_at').limit(limit).populate('user').exec (err, nextGroupMessages) ->
      if err then next err
      else
        if not admin
          for group_message in nextGroupMessages
            if req.user and group_message.user.id isnt req.user.id
              group_message.user = null
            else
              group_message.user = req.user.id
        res.send group_messages: nextGroupMessages #.reverse()
  else
    GroupMessage.find(course: req.params.courseId).sort('-created_at').skip(offset).limit(limit).populate('user').exec (err, groupMessages) ->
      if err then next err
      else
        if not admin
          for group_message in groupMessages
            if req.user and group_message.user.id isnt req.user.id
              group_message.user = null
            else
              group_message.user = req.user.id
        res.send group_messages: groupMessages #.reverse()

module.exports = router
