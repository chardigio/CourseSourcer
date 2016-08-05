_ = require 'lodash'
mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
idValidator = require 'mongoose-id-validator'

schema = mongoose.Schema
  title: String
  text: String
  score: Number
  course: {type: mongoose.Schema.Types.ObjectId, ref: 'course'}
  user: {type: mongoose.Schema.Types.ObjectId, ref: 'user'}
  user_handle: String

schema.set 'toJSON', transform: (doc, ret, options) ->
  _.pick doc, 'id', 'created_at', 'title', 'text', 'score', 'course', 'user_handle'

#plugins
schema.plugin idValidator, message : 'Invalid {PATH}.'
schema.plugin timestamps, createdAt: 'created_at', updatedAt: 'updated_at'

#validations
(schema.path 'title').required yes, 'Title is required.'

(schema.path 'title').validate (val) ->
  val?.length >= 1
, 'Title is too short.'

(schema.path 'title').validate (val) ->
  val?.length <= 100
, 'Title is too long.'

(schema.path 'text').validate (val) ->
  val?.length <= 20000
, 'Text is too long.'

(schema.path 'user_handle').required yes, 'Internal Error: No user handle.'

#export Model
module.exports = StaticNote = mongoose.model 'static_note', schema
