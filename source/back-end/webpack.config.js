const path = require('path');
const ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {
  mode: process.env.ENVIRONMENT_FULL_NAME,
  // when I want to use more than one entry / output:
  // https://stackoverflow.com/questions/48429680/bundle-js-files-with-webpack-scripts
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'public'),
    filename: 'js/bundle.js'
  },
  module: {
    rules: [
      {
      test: /\.scss$/,
      use: ExtractTextPlugin.extract({
        fallback: 'style-loader',
        use: [
          'css-loader',
          'sass-loader'
        ]
      })
    },
    // Webpack for handlebars in order to create static site pages.
    // {    
    //   test: /\.handlebars$/,
    //   loader: "handlebars-loader" ,
    //   query: {
    //     partialDirs: [
    //       path.join(__dirname, 'views', 'partials')
    //     ],
    //     helperDirs: [
    //       path.join(__dirname, 'views', 'helpers')
		// 		]
    //   }
    // }
  ]
  },
  plugins: [
    new ExtractTextPlugin('css/mystyles.css'),
  ]
};