const express = require('express');
const path = require('path');
const request = require('request');

const app = express();
const port = 3333;

let cache;

const getRandomElementFromArray = (xs) => {
  const randomIndex = Math.floor(Math.random() * xs.length);
  return xs[randomIndex];
};

app.use(express.static(path.join(__dirname, '/dist/')));

app.use('/getword', (req, res) => {
  if (!cache) {
    request('http://linkedin-reach.hagbpyjegb.us-west-2.elasticbeanstalk.com/words', (err, response, words) => {
      const wordsArray = words.split('\n');
      cache = wordsArray;
      res.send(getRandomElementFromArray(cache));
    });
  } else {
    res.send(getRandomElementFromArray(cache));
  }
});

app.listen(port, () => console.log(`Listening on port: ${ port }`));
