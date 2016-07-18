_ = require 'lodash'
router = (require 'express').Router()
mongoose = require 'mongoose'
rek = require 'rekuire'
User = rek 'models/user'
Course = rek 'models/course'
server = rek 'components/server'

#post user
router.post '/', (req, res, next) ->
  user = new User _.pick req.body, 'name', 'email', 'password', 'bio', 'admin_of', 'courses'
  user.confirmed = false
  user.save (err, user) ->
    if err then next err
    else res.status(201).send user: user

#add course to user
router.put '/addCourse', (req, res, next) ->
  User.findByIdAndUpdate req.body.user_id, $addToSet: courses: req.body.course_id, (err, user) ->
    if err then next err
    else res.status(200).send user: user

#update name of user
router.put '/:userid', (req, res, next) -> # also needs pic handling
  User.findByIdAndUpdate req.params.userid, {$set: {name: req.body.name, bio: req.body.bio}}, (err, user) ->
    if err then next err
    else res.status(200).send user: user

#get user
router.get '/:userid', (req, res, next) ->
  User.findById(req.params.userid).populate('courses').exec (err, user) ->
    if err then next err
    else res.status(200).send user: user

#get classmates
router.get '/of_course/:courseId', (req, res, next) -> #should have server.loadUser
  User.find courses: $elemMatch: $eq: req.params.courseId, (err, users) ->
    if err then next err
    else
      index_of_me = -1
      for user, index in users
        if not user then break # this shouldnt have to exist

        index_of_me = index if user.id is req.query.userid
        users.splice(index_of_me, 1) if index_of_me isnt -1
        #what is splice doing, removing me?
        #i hope it's removing me and not splitting@index

        user.id = null
        user.created_at = null
        user.admin_of = null
        user.courses = null
        user.confirmed = null

      res.send users: users

module.exports = router
