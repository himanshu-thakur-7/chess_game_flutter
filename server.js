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
    io.emit("startGame", socket.id);
    socket.on('moved', (data) => {
        console.log(data);
        socket.broadcast.emit('updateBoard', data);
    });
    socket.on("checkmate", (data) => {
        console.log(data);
        io.emit("Checkmate", "Checkmated bro!!");
    });

    socket.on("draw", (data) => {
        console.log(data);
        io.emit("Draw", "Draw bro!!");
    });
    socket.on("stalemate", (data) => {
        console.log(data);
        io.emit("Stalemate", "Stalemate bro!!");
    });

    socket.on("Roger", (affirmation) => {
        console.log(affirmation);
    })
});

var port = process.env.PORT || 8080;
console.log(port);
server.listen(port);
