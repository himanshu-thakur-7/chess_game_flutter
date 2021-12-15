let roomsInfo = {};
var server = require('http').createServer((req, res) => {
    res.end('I am connected');
});
var io = require('socket.io')(server);

io.on('connection', function (socket) {
    // console.log(socket.id, 'joined');


    socket.on('playerReady', (roomID) => {



        console.log("Room ID:", roomID);
        if (roomsInfo[roomID] == undefined) {
            roomsInfo[roomID] = 0;
        }
        roomsInfo[roomID]++;
        if (roomsInfo[roomID] > 2) {
            console.log("Intruder ID", socket.id);
            io.to(socket.id).emit('roomFull', 'No entry');
        }
        console.log("Number of players:", roomsInfo[roomID]);
        if (roomsInfo[roomID] < 2) {
            console.log('Player Count:', roomsInfo[roomID]);
            socket.join(roomID);
        }

        else if (roomsInfo[roomID] == 2) {

            console.log('Player Count:', roomsInfo[roomID]);
            socket.join(roomID);
            io.to(roomID).emit('startGame', socket.id);
        }
        socket.on("loadUser", (userID) => {
            console.log("User ID:", userID);
            socket.to(roomID).emit('displayUser', userID);
        })

        socket.on('moved', (data) => {
            console.log(data);
            socket.to(roomID).emit('updateBoard', data);
        });
        socket.on("checkmate", (data) => {
            console.log(data);
            socket.to(roomID).emit("Checkmate", "Checkmated bro!!");

        });

        socket.on("draw", (data) => {
            console.log(data);
            io.to(roomID).emit("Draw", data);

        });
        socket.on("stalemate", (data) => {
            console.log(data);
            io.to(roomID).emit("Stalemate", "Stalemate bro!!");

        });

        socket.on('game abandoned', (reason) => {

            roomsInfo[roomID]--;
            socket.leave(roomID);
            socket.disconnect(true);

        });
        socket.on('exit room', (reason) => {
            console.log(reason);
            roomsInfo[roomID]--;
            socket.leave(roomID);
            socket.disconnect(true);

        })

    });

});

var port = process.env.PORT || 8080;
console.log(port);
server.listen(port);
