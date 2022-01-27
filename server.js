
let roomsInfo = {};
var server = require('http').createServer((req, res) => {
  res.end('I am connected');
});
var io = require('socket.io')(server);


// on connecting with socket.io server
io.on('connection', function (socket) {
  console.log(socket.id, 'joined');

  // when the client sends "playerReady" event
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

        // if there are already 2 people in a room emit the room full event
        if (roomsInfo[roomID].length == 2) {
          console.log("Intruder ID", socket.id);
          io.to(socket.id).emit('roomFull', roomID);
        }
        else {
          console.log("Number of players:", roomsInfo[roomID].length);
          // if the number of people in room are less than 2
          if (roomsInfo[roomID].length < 2 && roomsInfo[roomID].includes(socket.id) === false) {

            roomsInfo[roomID].push(socket.id);
            console.log('Player Count:', roomsInfo[roomID].length);

            // make the client socket to join the room
            socket.join(roomID);

            console.log("Room status:", io.sockets.adapter.rooms);
          }

          // when the number of socket clients in room are 2 
          if (roomsInfo[roomID].length === 2) {

            console.log('Player Count:', roomsInfo[roomID].length);
            console.log(socket.id);

            // emit the event to start the game
            io.to(roomID).emit('startGame', socket.id);
          }
        }
        // on the load user event .. inform the clients to load the user info
        socket.on("loadUser", (userID) => {
          socket.to(roomID).emit('displayUser', userID);
        })
      }
      catch (e) {
        io.to(socket.id).emit('Error', e);
      }

      // when the client emit a moved event
      socket.on('moved', (data) => {
        console.log(data);
        socket.to(roomID).emit('updateBoard', data);
      });

      // when the client emits a checkmate event
      socket.on("checkmate", (data) => {
        console.log(data);
        socket.to(roomID).emit("Checkmate", "Checkmated bro!!");

      });
      // when the client emits a resign event
      socket.on("resign game", (data) => {
        console.log(data);
        socket.to(roomID).emit("Resigned", 'You win by resignation');
      })

      // on draw event
      socket.on("draw", (data) => {
        console.log(data);
        io.to(roomID).emit("Draw", data);

      });
      // on stalemate event
      socket.on("stalemate", (data) => {
        console.log(data);
        io.to(roomID).emit("Stalemate", "Stalemate bro!!");

      });

      // when a client exists a room
      socket.on('exit room', (reason) => {
        console.log('exiting room');
        // roomsInfo[roomID]--;
        roomsInfo[roomID] = roomsInfo[roomID].filter(item => item !== socket.id);
        console.log(roomsInfo[roomID]);
        if (roomsInfo[roomID].length === 0) {
          delete roomsInfo[roomID];
          console.log("Room deleted");

        }
        socket.leave(roomID);
        console.log("After removal", io.sockets.adapter.rooms);
        socket.disconnect(true);

      })
      // when a client disconnects from server
      socket.on("disconnect", () => {
        console.log(socket.id, "disconnected");
      })
    }

  });

});

var port = process.env.PORT || 8080;
console.log(port);
server.listen(port);
