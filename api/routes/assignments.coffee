_ = require 'lodash'
router = (require 'express').Router()
mongoose = require 'mongoose'
rek = require 'rekuire'
Assignment = rek 'models/static_note'
User = rek 'models/user'
server = rek 'components/server'

#post assignment
router.post '/', (req, res, next) ->
  assignment = new Assignment _.pick req.body, 'title', 'time_begin', 'time_end', 'course', 'user'
  assignment.score = 0
  assignment.save (err, assignment) ->
    if err then next err
    else res.status(201).send assignment: assignment

router.get '/of_course/:courseId', (req, res, next) ->
  Assignment.find(course: req.params.courseId).sort('-time_begin').exec (err, assignments) ->
    if err then next err
    else
      for assignment in assignments #not deepcopy, fix
        assignment.user = null #if admin dont null it
      res.send assignments: assignments

router.get '/of_user/:userId', (req, res, next) ->
  User.findById req.params.userid, (err, user) ->
    if err then next err
    else
      or_query = $or: (course: course_id for course_id in user.courses)

      Assignment.find(or_query).sort('-time_begin').exec (err, assignments) ->
        if err then next err
        else
          for assignment in assignments #not deepcopy, fix
            assignment.user = null #if admin dont null it
          res.send assignments: assignments

module.exports = router