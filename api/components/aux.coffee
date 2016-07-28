module.exports.handleOfEmail = (email) ->
  String(email).split('@')[0]

module.exports.domainOfEmail = (email) ->
  String(email).split('.edu')[0].split('@')[1]
