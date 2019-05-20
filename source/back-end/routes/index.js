const path = require('path');
const fs = require('fs');
let app = require('express')();

fs.readdirSync(__dirname)
  .filter(file => file !== 'index.js')
  .filter(file => file.substr(file.lastIndexOf('.') + 1) === 'js')
  .forEach(file => {
    app.use('/', require(path.join(__dirname, file)));
});

module.exports = app;