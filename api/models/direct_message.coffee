_ = require 'lodash'
mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
idValidator = require 'mongoose-id-validator'

schema = mongoose.Schema
  text: String,
  to: {type: mongoose.Schema.Types.ObjectId, ref: 'user'},
  from: {type: mongoose.Schema.Types.ObjectId, ref: 'user'},
  course: {type: mongoose.Schema.Types.ObjectId, ref: 'course'}

schema.set 'toJSON', transform: (doc, ret, options) ->
  _.pick doc, 'id', 'created_at', 'text', 'to', 'course', 'from'

#plugins
schema.plugin idValidator, message : 'Invalid {PATH}.'
schema.plugin timestamps, createdAt: 'created_at', updatedAt: 'updated_at'

#export Model
module.exports = DirectMessage = mongoose.model 'direct_message', schema
