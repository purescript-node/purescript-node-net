"use strict";

var net = require("net");

exports.addressImpl = function (server) {
  return server.address();
};

exports.closeImpl = function (server, callback) {
  server.close(callback);
};

exports.createServerImpl = net.createServer;

exports.getConnectionsImpl = function (server, callback) {
  server.getConnections(callback);
};

exports.isIP = net.isIP;

exports.isIPv4 = net.isIPv4;

exports.isIPv6 = net.isIPv6;

exports.listenImpl = function (server, options, callback) {
  server.listen(options, callback);
};

exports.listeningImpl = function (socket) {
  return socket.listening;
};

exports.onServerImpl = function (event, server, callback) {
  server.on(event, callback);
};
