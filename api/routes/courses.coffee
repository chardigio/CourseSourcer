_ = require 'lodash'
router = (require 'express').Router()
mongoose = require 'mongoose'
rek = require 'rekuire'
Course = rek 'models/course'
User = rek 'models/user'
server = rek 'server'

#post course
router.post '/', (req, res, next) ->
  course = new Course _.pick req.body, 'name', 'term', 'school', 'domain'
  course.save (err, course) ->
    if err then next err
    else res.status(201).send course: course

#search for courses
router.post '/search', (req, res, next) -> #IDEALLY THIS IS A GET AND SWIFT REPLACES SPACES WITH %20
  search = {$and:
    [
      {name: {'$regex': req.body.query, '$options': "i"}},
      {domain: req.body.domain}
    ]
  }

  Course.find(search).limit(15).sort('-created_at').exec (err, courses) ->
    if err then next err
    else res.send courses: courses

#get all courses for user
router.get '/', server.loadUser, (req, res, next) ->
  if req.user.courses.length == 0
    res.send courses: []
  else
    or_query = $or: (_id: course_id for course_id in req.user.courses)

    Course.find or_query, (err, courses) ->
      if err then next err
      else
        for course_id in req.user.admin_of
          for course in courses
            if course_id.toString() == course.id
              course.admin = true

        res.send courses: courses

#add user to course's blocked list
router.put '/block', (req, res, next) ->
  Course.findByIdAndUpdate req.body.courseid, {$addToSet: {blocked: req.body.userid}}, (err, course) ->
    if err then next err
    else res.status(200).send course: course

module.exports = router
