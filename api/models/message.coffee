_ = require 'lodash'
mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
idValidator = require 'mongoose-id-validator'

schema = mongoose.Schema
  text: String
  score: Number
  by_admin: Boolean
  course: {type: mongoose.Schema.Types.ObjectId, ref: 'course'}
  user: {type: mongoose.Schema.Types.ObjectId, ref: 'user'}

schema.set 'toJSON', transform: (doc, ret, options) ->
  _.pick doc, 'id', 'created_at', 'text', 'score', 'by_admin', 'course', 'user'

#plugins
schema.plugin idValidator, message : 'Invalid {PATH}.'
schema.plugin timestamps, createdAt: 'created_at', updatedAt: 'updated_at'

#validations
schema.path('text').validate(function(val) {
  return (val != null ? val.length : void 0) <= 10000
}, 'Text cannot exceed 10000 characters.')

#export Model
module.exports = Message = mongoose.model 'message', schema
