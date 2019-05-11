"use strict";

var net = require("net");

exports.bufferSizeImpl = function (socket) {
  return socket.bufferSize;
};

exports.bytesReadImpl = function (socket) {
  return socket.bytesRead;
};

exports.bytesWrittenImpl = function (socket) {
  return socket.bytesWritten;
};

exports.connectImpl = function (socket, options, callback) {
  socket.connect(options, callback);
};

exports.connectingImpl = function (socket) {
  return socket.connecting;
};

exports.createConnectionImpl = net.createConnection;

exports.destroyImpl = function (socket, err) {
  socket.destroy(err);
};

exports.destroyedImpl = function (socket) {
  return socket.destroyed;
};

exports.endImpl = function (socket, buffer, callback) {
  socket.end(buffer, null, callback);
};

exports.endStringImpl = function (socket, str, encoding, callback) {
  socket.end(str, encoding, callback);
};

exports.localAddressImpl = function (socket) {
  return socket.localAddress;
};

exports.localPortImpl = function (socket) {
  return socket.localPort;
};

exports.onDataImpl = function (socket, callbackBuffer, callbackString) {
  socket.on("data", function (data) {
    if (typeof data === "string") {
      callbackString(data);
    } else {
      callbackBuffer(data);
    }
  });
};

exports.onImpl = function (event, socket, callback) {
  socket.on(event, callback);
};

exports.pauseImpl = function (socket) {
  socket.pause();
};

exports.pendingImpl = function (socket) {
  return socket.pending;
};

exports.remoteAddressImpl = function (socket) {
  return socket.remoteAddress;
};

exports.remoteFamilyImpl = function (socket) {
  return socket.remoteFamily;
};

exports.remotePortImpl = function (socket) {
  return socket.remotePort;
};

exports.resumeImpl = function (socket) {
  socket.resume();
};

exports.setEncodingImpl = function (socket, encoding) {
  socket.setEncoding(encoding);
};

exports.setKeepAliveImpl = function (socket, enable, initialDelay) {
  socket.setKeepAlive(enable, initialDelay);
};

exports.setNoDelayImpl = function (socket, noDelay) {
  socket.setNoDelay(noDelay);
};

exports.setTimeoutImpl = function (socket, timeout, callback) {
  socket.setTimeout(timeout, callback);
};

exports.writeImpl = function (socket, buffer, callback) {
  return socket.write(buffer, null, callback);
};

exports.writeStringImpl = function (socket, str, encoding, callback) {
  return socket.write(str, encoding, callback);
};
