_ = require 'lodash'
router = (require 'express').Router()
mongoose = require 'mongoose'
rek = require 'rekuire'
Assignment = rek 'models/assignment'
User = rek 'models/user'
server = rek 'components/server'
aux = rek 'aux'

#post assignment
router.post '/', server.loadUser, (req, res, next) ->
  assignment = new Assignment _.pick req.body, 'title', 'time_begin', 'time_end', 'assignments', 'course', 'user'
  assignment.score = 0
  assignment.user_handle = aux.handleOfEmail req.user.email

  assignment.save (err, assignment) ->
    if err then next err
    else res.status(201).send assignment: assignment

#get course assignments
router.get '/of_course/:courseId', server.loadUser, (req, res, next) ->
  Assignment.find(course: req.params.courseId).sort('-time_begin').exec (err, assignments) ->
    if err then next err
    else
      if assignments.length > 0 and not assignments[0].course in req.user.admin_of
        for assignment in assignments
          assignment.user_handle = null
      res.send assignments: assignments

#get user's assignments
router.get '/of_user', server.loadUser, (req, res, next) ->
  or_query = $or: (course: course_id for course_id in req.user.courses)

  Assignment.find(or_query).sort('-time_begin').exec (err, assignments) ->
    if err then next err
    else
      for assignment in assignments
        if assignment.course in req.user.admin_of
          assignment.user_handle = null
      res.send assignments: assignments

module.exports = router
