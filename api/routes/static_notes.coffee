_ = require 'lodash'
router = (require 'express').Router()
mongoose = require 'mongoose'
rek = require 'rekuire'
Note = rek 'models/static_note'
Course = rek 'models/course'
server = rek 'components/server'

#post note
router.post '/', (req, res, next) ->
  note = new Note _.pick req.body, 'subject', 'text', 'course', 'user'
  note.score = 0
  note.save (err, note) ->
    if err then next err
    else res.status(201).send static_note: note

#get all notes for a course
router.get '/of_course/:courseId', (req, res, next) -> #should be server.loadUser
  Note.find(course: req.params.courseId).sort('-created_at').exec (err, notes) ->
    if err then next err
    else
      for note in notes #not deepcopy, fix
        note.text = null
        note.couse = null
        note.score = null
        note.user = null #if admin dont null it
      res.send static_notes: notes

router.get '/:noteId', (req, res, next) ->
  Note.findById req.params.noteId, (err, note) ->
    if err then next err
    else
      note.user = null
      res.send static_note: note

#like note
router.put '/like', (req, res,next) ->
  Note.findById req.body.note_id, (err, ogNote) ->
    if err then next err
    else
      ogNote.score++
      ogNote.save (err, note) ->
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
