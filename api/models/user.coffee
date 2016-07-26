_ = require 'lodash'
mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
idValidator = require 'mongoose-id-validator'
bcrypt = require 'bcrypt'

schema = mongoose.Schema
  name: String
  email: String
  password: String
  #token: String
  confirmed: Boolean
  bio: String
  admin_of: [{type: mongoose.Schema.Types.ObjectId, ref: 'course'}]
  courses: [{type: mongoose.Schema.Types.ObjectId, ref: 'course'}]

schema.set 'toJSON', transform: (doc, ret, options) ->
  _.pick doc, 'id', 'name', 'email', 'confirmed', 'bio', 'admin_of', 'courses'

schema.pre 'save', (next) ->
  #hash password
  if @isModified 'password' then @password = bcrypt.hashSync @password, bcrypt.genSaltSync 10
  next()

#plugins
schema.plugin idValidator, message : 'Invalid {PATH}.'
schema.plugin timestamps, createdAt: 'created_at', updatedAt: 'updated_at'
###
#validation
schema.path('name').required(true, 'First name is required.')

schema.path('name').validate(function(val) {
  return (val != null ? val.length : void 0) > 1
}, 'Name is too short.')

schema.path('name').validate(function(val) {
  return (val != null ? val.length : void 0) <= 100
}, 'Name is too long.')

schema.path('email').required(true, 'Email name is required.')

schema.path('email').unique(true)

schema.path('email').validate(function(val) {
  return /\S+@\S+\.\S+/.test(val)
}, 'Invalid email address.')

schema.path('email').validate(function(val) {
  return (val != null ? val.length : void 0) <= 100
}, 'Email is too long.')

schema.path('password').required(true, 'Password is required.')

schema.path('password').validate(function(val) {
  return (val != null ? val.length : void 0) > 5
}, 'Passwords must have at least 6 characters.')

schema.path('password').validate(function(val) {
  return (val != null ? val.length : void 0) <= 100
}, 'Password is too long.')

#sanitization
schema.path('name').set(function(val) {
  return val.trim()
})
schema.path('email').set(function(val) {
  return val.trim().toLowerCase()
})
###
#export Model
module.exports = User = mongoose.model 'user', schema

# validate email unique
(schema.path 'email').validate (val, respond) ->
  if not @isNew then respond yes
  else User.findOne email: val, (err, user) ->
    if err or user then respond no
    else respond yes
, 'This email address is already registered.'
