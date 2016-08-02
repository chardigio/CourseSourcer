module.exports.MONGO_URI = process.env.MONGO_URI or 'mongodb://localhost/coursesourcer'
module.exports.DEFAULT_USER_PIC = process.env.DEFAULT_USER_PIC or './images/defaults/user.png'

###------------------------
NOTE:
- req.query is only allowed in server.coffee or if using req.query.device
------------------------###
