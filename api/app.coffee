express = require 'express'
app = express()
mongoose = require 'mongoose'
bodyParser = require 'body-parser'
rek = require 'rekuire'
usersRouter = rek 'routes/users'
groupMessagesRouter = rek 'routes/group_messages'
coursesRouter = rek 'routes/courses'
staticNotesRouter = rek 'routes/static_notes'
directMessagesRouter = rek 'routes/direct_messages'
assignmentsRouter = rek 'routes/assignments'
configs = rek 'config'
server = rek 'components/server'

#connect to mongo
mongoose.connect configs.MONGO_URI

#configure server
app.disable 'x-powered-by'
app.use bodyParser.urlencoded extended: yes
app.use bodyParser.json()

#configure routes
app.use '/users', usersRouter
app.use '/group_messages', groupMessagesRouter
app.use '/courses', coursesRouter
app.use '/static_notes', staticNotesRouter
app.use '/direct_messages', directMessagesRouter
app.use '/assignments', assignmentsRouter

# configure error handling
app.use (err, req, res, next) ->
  if err.name is 'ValidationError'
    params = (param: param, message: info.message for param, info of err.errors)
    server.sendError res, 400, 'invalid_params', 'Invalid request.', params
  else
    console.error err
    res.sendStatus 500

# start server
PORT = 3005
app.listen PORT, () -> console.log "Listening on #{PORT}"
