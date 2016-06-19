_ = require 'lodash'
router = (require 'express').Router()
mongoose = require 'mongoose'
rek = require 'rekuire'
User = 'models/user'
Course = 'models/course'
server = 'components/server'

#post user
router.post '/', (req, res, next) ->
  user = new User _.pick req.body, 'name', 'email', 'password', 'admin_of', 'courses'
  user.confirmed = false
  user.save (err, user) ->
    if err then next err
    else res.status(201).send user: user

#add course to user
router.put '/addCourse', (req, res, next) ->
	User.findByIdAndUpdate(req.body.user_id, $addToSet: courses: req.body.course_id, (err, user) ->
		if err then next err
		else res.status(200).send user: user

#update name of user
router.put '/:userid', (req, res, next) ->
	User.findByIdAndUpdate req.params.userid, name: req.body.name, (err, user) ->
		if err then next err
		else res.status(200).send user: user

#get user
router.get '/:userid', (req, res, next) ->
	User.findById(req.params.userid).populate('courses').exec (err, user) ->
		if err then next err
		else res.status(200).send user: user

#get classmates
router.get '/classmates/:courseId', server.loadUser, (req, res, next) ->
	User.find courses: $elemMatch: $eq: req.params.courseId, (err, users) ->
		if err then next err
		else
      index_of_me = -1
			for user, index in users #not deepcopy fix
				if user.id is req.query.userid then index_of_me = index
        user.id = null
        user.created_at = null
        user.admin_of = null
        user.courses = null
        user.confirmed = null

      if index_of_me isnt -1 then users.splice index_of_me, 1

      res.send users: users

module.exports = router
