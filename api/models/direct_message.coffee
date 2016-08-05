_ = require 'lodash'
mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
idValidator = require 'mongoose-id-validator'
#rek = require 'rekuire'

schema = mongoose.Schema
  text: String
  to: {type: mongoose.Schema.Types.ObjectId, ref: 'user'}
  from: {type: mongoose.Schema.Types.ObjectId, ref: 'user'}
  course: {type: mongoose.Schema.Types.ObjectId, ref: 'course'}
  from_me: Boolean #only populated and sent to user to indicate message is from them, not stored in db

schema.set 'toJSON', transform: (doc, ret, options) ->
  _.pick doc, 'id', 'created_at', 'text', 'from_me', 'course'

#plugins
schema.plugin idValidator, message : 'Invalid {PATH}.'
schema.plugin timestamps, createdAt: 'created_at', updatedAt: 'updated_at'

#validations
(schema.path 'text').validate (val) ->
  val?.length >= 1
, 'Text is too short.'

(schema.path 'text').validate (val) ->
  val?.length <= 1000
, 'Text is too long.'

#export Model
module.exports = DirectMessage = mongoose.model 'direct_message', schema
