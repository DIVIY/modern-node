let app = require('express')();

app.get('/example', (req, res) => {
    res.render('example', {
        layout: 'default'
    });
  });

module.exports = app;