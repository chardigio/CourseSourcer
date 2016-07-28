_ = require 'lodash'
router = (require 'express').Router()
rek = require 'rekuire'
GroupMessage = rek 'models/group_message'
server = rek 'server'
aux = rek 'aux'

#post group_message
router.post '/', server.loadUser, (req, res, next) -> #load user and check for by_admin
  msg = new GroupMessage _.pick req.body, 'text', 'course', 'user'
  msg.score = 0
  msg.user_handle = aux.handleOfEmail req.user.email

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

  if lastId and lastId isnt null and lastId isnt ''
    GroupMessage.find(_id: $gt: lastId, course: req.params.courseId).sort('-created_at').limit(limit).populate('user').exec (err, nextGroupMessages) ->
      if err then next err
      else ## NOT NOTES; this also has to be done for assignments
        if nextGroupMessages.length > 0 and not nextGroupMessages[0].course in req.user.admin_of
          for groupMessage in nextGroupMessages
            groupMessage.user_handle = null
        res.send group_messages: nextGroupMessages
  else
    GroupMessage.find(course: req.params.courseId).sort('-created_at').skip(offset).limit(limit).populate('user').exec (err, groupMessages) ->
      if err then next err
      else
        if groupMessages.length > 0 and not groupMessages[0].course in req.user.admin_of
          for groupMessage in groupMessages
            groupMessage.user_handle = null
        res.send group_messages: groupMessages

module.exports = router
