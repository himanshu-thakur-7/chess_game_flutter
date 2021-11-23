const { Console } = require('console');

var server = require('http').createServer((req, res) => {
    res.end('I am connected');
});
var io = require('socket.io')(server);

io.on('connection', function (socket) {
    console.log(socket.id, 'joined');
    socket.on('/test', function (msg) {
        console.log(msg);
    });
    socket.on('moved', (data) => {
        console.log(data);
        socket.broadcast.emit('updateBoard', data);
    });
    socket.on("checkmate", (data) => {
        console.log(data);
        io.emit("gameOver", "Checkmated bro!!");
    });
    socket.on("Roger", (_) => {
        console.log("Roger");
    })
});

var port = process.env.PORT || 8080;
console.log(port);
server.listen(port);
