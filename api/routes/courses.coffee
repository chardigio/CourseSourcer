_ = require 'lodash'
router = (require 'express').Router()
mongoose = require 'mongoose'
rek = require 'rekuire'
Course = rek 'models/course'
User = rek 'models/user'

#post course
router.post '/', (req, res, next) ->
  course = new Course _.pick req.body, 'name', 'term', 'school', 'domain'
  course.save (err, course) ->
    if err then next err
    else res.status(201).send course: course

#search for courses
router.post '/search', (req, res, next) -> #IDEALLY THIS IS A GET AND SWIFT REPLACES SPACES WITH %20
  search = {$or:
    [
      {'school': {"$regex": req.body.term, "$options": "i"}}, #AND THIS WOULD BE REQ.QUERY.TERM
      {'term': {"$regex": req.body.term, "$options": "i"}},
      {'name': {"$regex": req.body.term, "$options": "i"}},
      {'domain': {"$regex": req.body.term, "$options": "i"}}
    ]
  }

  Course.find(search).limit(15).sort('-created_at').exec (err, courses) ->
    if err then next err
    else res.send courses: courses

#get all courses for user
router.get '/:userid', (req, res, next) ->
  User.findById(req.params.userid).populate('courses').exec (err, user) ->
    if err then next err
    else res.status(200).send courses: user.courses

#add user to course's blocked list
router.put '/block', (req, res, next) ->
  Course.findByIdAndUpdate {_id: req.body.courseid}, {$addToSet: {blocked: req.body.userid}}, (err, course) ->
    if err then next err
    else res.status(200).send course: course

module.exports = router
