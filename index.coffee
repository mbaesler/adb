app            = (require 'express')()
bodyParser     = require 'body-parser'
moment         = require 'moment'


globalUtcOffset = moment().utcOffset()
timeObject      = (utcOffset = globalUtcOffset) -> {time:moment().utcOffset(utcOffset).format(), timezone:utcOffset}


app.use bodyParser.json
  type  : 'application/json'
  limit : '42mb'

app.get '/time', (req, res) ->
  try
    throw '' if isNaN offset = Number req.query.timezone
    res.json          timeObject offset
  catch then res.json timeObject() 

app.post '/timezone', (req, res) ->
  try
    if Number is req.body.timezone.constructor
      globalUtcOffset = req.body.timezone
      res.status(204).end()
  catch then res.status(400).end()

app.listen 8080


io = require('socket.io') 8081

io.on 'connection', (socket) ->
  socketsUtcOffset = undefined

  socket.on 'setTimezone', (utcOffset) ->
    return if Number isnt utcOffset.constructor
    socketsUtcOffset = utcOffset

  socket.on 'disconnect', () -> clearTimeout timeout

  sendTime = () ->
    socket.emit 'time', timeObject socketsUtcOffset
    delay   = new Date().getTime() - t_start
    delay   = if delay > 10000 then 10000 - (delay - 10000) else 10000
    t_start = new Date().getTime()
    timeout = setTimeout sendTime, delay
  
  t_start = new Date().getTime()
  timeout = setTimeout sendTime, 10 * 1000
