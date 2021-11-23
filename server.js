// const http = require('http');

// const server = http.createServer((req, res) => {
//     res.end('I am connected');
// });

// PORT = process.env.PORT || 8000;

// const io = require('socket.io')(server, {
//     cors: {
//         origin: '*',
//     }
// });


// io.on('connection', (socket) => {
//     console.log('New client connected');
// })

// server.listen(PORT, () => {
//     console.log(`Server is running on port ${PORT}`);

// })
var express = require('express');
var app = require('express')();
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
    });
});

var port = 8080;
console.log(port);
server.listen(port);
