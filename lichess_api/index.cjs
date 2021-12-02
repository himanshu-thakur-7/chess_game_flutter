require('dotenv').config();
const fetch = require('node-fetch');

const headers = {
    Authorization: 'Bearer ' + process.env.lichessToken,
}

fetch('https://api.chess.com/pub/puzzle')
    .then(res => res.json())
    .then(json => {
        console.log(json);

        // console.log(pgn);

        // var string = pgn.split(' ');
        // // console.log(string);
        // var formattedPGN = '1. ';
        // var num = 2;
        // var count = 0;
        // for (var i = 0; i < string.length; i++) {
        //     formattedPGN += string[i] + ' ';
        //     count++;
        //     if (count === 2) {
        //         formattedPGN += `${num}. `;
        //         count = 0;
        //         num++;
        //     }
        // }
        // console.log(formattedPGN);
        // console.log('Solution:', json.puzzle.solution);
    }

    );
