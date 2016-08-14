_ = require 'lodash'
mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
idValidator = require 'mongoose-id-validator'
bcrypt = require 'bcrypt'

schema = mongoose.Schema
  name: String
  email: String
  password: String
  confirmed: Boolean
  bio: String
  admin_of: [{type: mongoose.Schema.Types.ObjectId, ref: 'course'}]
  blocked_from: [{type: mongoose.Schema.Types.ObjectId, ref: 'course'}]
  courses: [{type: mongoose.Schema.Types.ObjectId, ref: 'course'}]
  devices: [String]

schema.set 'toJSON', transform: (doc, ret, options) ->
  _.pick doc, 'id', 'name', 'email', 'confirmed', 'bio', 'admin_of', 'courses'

schema.pre 'save', (next) ->
  #hash password
  if @isModified 'password' then @password = bcrypt.hashSync @password, bcrypt.genSaltSync 10
  next()

#plugins
schema.plugin idValidator, message : 'Invalid {PATH}.'
schema.plugin timestamps, createdAt: 'created_at', updatedAt: 'updated_at'

#validations
(schema.path 'name').required yes, 'Name is required.'

(schema.path 'name').validate (val) ->
  val?.length >= 3
,'Name is too short.'

(schema.path 'name').validate (val) ->
  val?.length <= 100
, 'Name is too long.'

(schema.path 'name').validate (val) ->
  /\S+\s[\w\W]+/.test(val)
, 'Invalid name.'

(schema.path 'email').required yes, 'Email is required.'

(schema.path 'email').unique yes

(schema.path 'email').validate (val) ->
  /\S+@\S+(.edu)$/.test(val)
, 'Invalid email address.'

(schema.path 'password').required yes, 'Password is required.'

(schema.path 'password').validate (val) ->
  val?.length >= 6
, 'Passwords must have at least 6 characters.'

(schema.path 'password').validate (val) ->
  val?.length <= 25
, 'Password is too long.'

(schema.path 'bio').validate (val) ->
  val?.length <= 100
, 'Bio is too long.'

Array((schema.path 'devices')).every (val) ->
  val?.length <= 500
, 'Device string is too long.'

#export Model
module.exports = User = mongoose.model 'user', schema

# validate email unique
(schema.path 'email').validate (val, respond) ->
  if not @isNew then respond yes
  else User.findOne email: val, (err, user) ->
    if err or user then respond no
    else respond yes
, 'This email address is already registered.'
