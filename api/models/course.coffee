_ = require 'lodash'
mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
idValidator = require 'mongoose-id-validator'

schema = mongoose.Schema
  name: String
  term: String
  school: String
  domain: String

schema.set 'toJSON', transform: (doc, ret, options) ->
  _.pick doc, 'id', 'created_at', 'name', 'term', 'school', 'domain', 'admin'

#plugins
schema.plugin idValidator, message : 'Invalid {PATH}.'
schema.plugin timestamps, createdAt: 'created_at', updatedAt: 'updated_at'

###
#validation
schema.path('name').required(true, 'Course name is required.')

schema.path('name').validate(function(val) {
  return (val != null ? val.length : void 0) <= 100
}, 'Course name is too many characters.')

schema.path('term').required(true, 'Term is required.')

schema.path('term').validate(function(val) {
  return (val != null ? val.length : void 0) <= 100
}, 'Term is too many characters.')

#this should eventually be a regular expression (regex) that checks that there is a '.'
schema.path('domain').validate(function(val) {
  return /\S+@\S+\.\S+/.test(val)
}, 'Invalid domain.')

schema.path('domain').required(true, 'Domain is required.')

schema.path('domain').validate(function(val) {
  return (val != null ? val.length : void 0) <= 100
}, 'Domain is too many characters.')
###

#export Model
module.exports = Course = mongoose.model 'course', schema
