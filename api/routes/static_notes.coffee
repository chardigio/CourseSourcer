_ = require 'lodash'
router = (require 'express').Router()
mongoose = require 'mongoose'
rek = require 'rekuire'
Note = rek 'models/static_note'
Course = rek 'models/course'
server = rek 'components/server'
aux = rek 'aux'

#post note
router.post '/', server.loadUser, (req, res, next) ->
  note = new Note _.pick req.body, 'title', 'text', 'course', 'user'
  note.score = 0
  note.user_handle = aux.handleOfEmail req.user.email

  note.save (err, note) ->
    if err then next err
    else res.status(201).send static_note: note

#get all notes for a course
router.get '/of_course/:courseId', server.loadUser, (req, res, next) ->
  Note.find(course: req.params.courseId).sort('-created_at').exec (err, notes) ->
    if err then next err
    else
      if notes.length > 0 and not notes[0].course in req.user.admin_of
        for note in notes
          note.user_handle = null
      res.send static_notes: notes


router.get '/:noteId', (req, res, next) ->
  Note.findById req.params.noteId, (err, note) ->
    if err then next err
    else
      console.log note
      console.log "^^ this should just be an id"
      res.send static_note: note

#like note
router.put '/like', (req, res,next) ->
  Note.findById req.body.note_id, (err, note) ->
    if err then next err
    else
      note.score++
      note.save (err, note) ->
        if err then next err
        else res.status(200).send static_note: note

#dislike note
router.put '/dislike', (req, res,next) ->
  Note.findById req.body.note_id, (err, note) ->
    if err then next err
    else
      note.score--
      note.save (err, note) ->
        if err then next err
        else res.status(200).send static_note: note

module.exports = router
