const path = require('path');
const fs = require('fs');
const express = require('express');
const app = express();
const hbs = require('express-handlebars');
const favicon = require('serve-favicon')
const logger = require('morgan');
const bodyParser = require('body-parser');

const applicationName = process.env.APPLICATION_NAME;
const port = process.env.APPLICATION_PORT;
const env =  process.env.ENVIRONMENT_FULL_NAME;

/* Templating Engine ~~~~~~ */ 
app.set('views', path.join(__dirname,'views'));
app.set('view engine', 'hbs');
app.engine( 'hbs', hbs( {
  extname: 'hbs',
  defaultView: 'default',
  layoutsDir: path.join(__dirname, '/views/layouts/'),
  partialsDir: path.join(__dirname, '/views/partials/'),
  helpers: fs.readdirSync(path.join(__dirname, '/views/helpers/'))
    .reduce((helperObject, file) => {
      let key = file.split('.')[0];
      helperObject[key] = require(path.join(__dirname, '/views/helpers/', file));
      return helperObject;}, {})
}));

/* Middleware ~~~~~~ */
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use('/', require(path.join(__dirname, 'middleware', 'passport.js')));
// also pull in the cool middleware i made for scry

/* Public Resources ~~~~~~ */
app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use('/', express.static(path.join(__dirname, 'public')));

/* Routes ~~~~~~ */// https://expressjs.com/en/guide/routing.html
app.use('/', require(path.join(__dirname, 'routes')));

// i am just recreating : 
// https://dansup.github.io/bulma-templates/
// https://github.com/dansup/bulma-templates/blob/master/templates/band.html
// https://dansup.github.io/bulma-templates/templates/band.html
// https://github.com/dansup/bulma-templates/blob/master/templates/cover.html
// https://dansup.github.io/bulma-templates/templates/cover.html

/* 404 and Error Handling ~~~~~~ */
app.use((req, res, next) => {
  next((new Error('Not Found')).status(404));
});

app.use((err, req, res, next) => {
  res.status(err.status || 500);
  res.render('error', {
    message: err.message,
    error: (env === 'production') ? {} : err
  });
});

app.listen(port, () => {console.log(
  `${applicationName} running in ${env} mode is now listening on port ${port} for incoming traffic!`
  )});