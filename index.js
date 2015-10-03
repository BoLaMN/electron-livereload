'use strict';

var slice = [].slice;

require('coffee-script/register');

var server = require('./lib/server');
var client = require('./lib/client');

module.exports = {
  server: function() {
    var args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return new server(args);
  },
  client: function(browser, port) {
    new client(browser, port);
  }
};