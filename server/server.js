var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.set('port', (process.env.PORT || 3000));


// app.get('/', function(req, res){
//   res.sendFile(__dirname + '/index.html');
// });

io.on('connection', function(socket){
  console.log('connection established');
  socket.on('message', function(data) {
    console.log('message', data);
    io.sockets.emit('message', data);
  });
});

http.listen(app.get('port'), function(){
  console.log('listening on *:' + app.get('port'));
});
