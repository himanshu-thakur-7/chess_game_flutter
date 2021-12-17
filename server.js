let roomsInfo = {};
var server = require('http').createServer((req, res) => {
  res.end('I am connected');
});
var io = require('socket.io')(server);

io.on('connection', function (socket) {
  console.log(socket.id, 'joined');


  socket.on('playerReady', (roomID) => {
    if (roomID !== undefined) {
      try {

        io.to(roomID).emit('Roger', `Got your affirmation! ${socket.id}`);

        console.log("Room ID:", roomID);

        if (roomsInfo[roomID] == undefined) {
          console.log("room array not found");
          roomsInfo[roomID] = new Array(0);
          console.log(roomsInfo[roomID]);
        }

        // roomsInfo[roomID].push(socket.id);

        if (roomsInfo[roomID].length == 2) {
          console.log("Intruder ID", socket.id);
          io.to(socket.id).emit('roomFull', roomID);
        }
        else {
          console.log("Number of players:", roomsInfo[roomID].length);
          if (roomsInfo[roomID].length < 2 && roomsInfo[roomID].includes(socket.id) === false) {

            roomsInfo[roomID].push(socket.id);
            console.log('Player Count:', roomsInfo[roomID].length);
            socket.join(roomID);
          }

          if (roomsInfo[roomID].length === 2) {

            console.log('Player Count:', roomsInfo[roomID].length);
            // socket.join(roomID);
            io.to(roomID).emit('startGame', socket.id);
          }
        }
        socket.on("loadUser", (userID) => {
          console.log("User ID:", userID);
          socket.to(roomID).emit('displayUser', userID);
        })
      }
      catch (e) {
        io.to(socket.id).emit('Error', e);
      }
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

      // socket.on('game abandoned', (reason) => {

      //     roomsInfo[roomID]--;
      //     socket.leave(roomID);
      //     // socket.disconnect(true);
      //     socket.close();

      // });
      socket.on('exit room', (reason) => {
        console.log('exiting room');
        // roomsInfo[roomID]--;
        roomsInfo[roomID] = roomsInfo[roomID].filter(item => item !== socket.id);

        if (roomsInfo[roomID].length === 0) {
          delete roomsInfo[roomID];
          console.log("Room deleted");

        }
        socket.leave(roomID);
        // socket.disconnect(true);
        socket.disconnect(true);

      })
    }

  });

});

var port = process.env.PORT || 8080;
console.log(port);
server.listen(port);
