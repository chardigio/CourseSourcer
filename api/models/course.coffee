_ = require 'lodash'
mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
idValidator = require 'mongoose-id-validator'

schema = mongoose.Schema
  name: String
  term: String
  school: String
  domain: String
  admin: Boolean #only populated and sent to user to indicate they are a course admin, not stored in db

schema.set 'toJSON', transform: (doc, ret, options) ->
  _.pick doc, 'id', 'created_at', 'name', 'term', 'school', 'domain', 'admin'

#plugins
schema.plugin idValidator, message : 'Invalid {PATH}.'
schema.plugin timestamps, createdAt: 'created_at', updatedAt: 'updated_at'

#validations
(schema.path 'name').required yes, 'Name is required.'

(schema.path 'name').validate (val) ->
  val?.length >= 1
,'Name is too short.'

(schema.path 'name').validate (val) ->
  val?.length <= 100
, 'Name is too long.'

(schema.path 'term').required yes, 'Term is required.'

(schema.path 'term').validate (val) ->
  val?.length >= 1
,'Term is too short.'

(schema.path 'term').validate (val) ->
  val?.length <= 50
, 'Term is too long.'

(schema.path 'school').required yes, 'School is required.'

(schema.path 'school').validate (val) ->
  val?.length >= 1
,'School is too short.'

(schema.path 'school').validate (val) ->
  val?.length <= 100
, 'School is too long.'

(schema.path 'domain').required yes, 'Internal Error: No domain.'

#export Model
module.exports = Course = mongoose.model 'course', schema
