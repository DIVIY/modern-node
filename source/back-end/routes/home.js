let app = require('express')();

app.get('/', (req, res) => {
    res.render('index', {
        layout: 'default'
    });
  });

module.exports = app;