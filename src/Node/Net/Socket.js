import net from "net";

export function bufferSizeImpl(socket) {
  return socket.bufferSize;
}

export function bytesReadImpl(socket) {
  return socket.bytesRead;
}

export function bytesWrittenImpl(socket) {
  return socket.bytesWritten;
}

export function connectImpl(socket, options, callback) {
  socket.connect(options, callback);
}

export function connectingImpl(socket) {
  return socket.connecting;
}

export const createConnectionImpl = net.createConnection;

export function destroyImpl(socket, err) {
  socket.destroy(err);
}

export function destroyedImpl(socket) {
  return socket.destroyed;
}

export function endImpl(socket, buffer, callback) {
  socket.end(buffer, null, callback);
}

export function endStringImpl(socket, str, encoding, callback) {
  socket.end(str, encoding, callback);
}

export function localAddressImpl(socket) {
  return socket.localAddress;
}

export function localPortImpl(socket) {
  return socket.localPort;
}

export function onDataImpl(socket, callbackBuffer, callbackString) {
  socket.on("data", function (data) {
    if (typeof data === "string") {
      callbackString(data);
    } else {
      callbackBuffer(data);
    }
  });
}

export function onImpl(event, socket, callback) {
  socket.on(event, callback);
}

export function pauseImpl(socket) {
  socket.pause();
}

export function pendingImpl(socket) {
  return socket.pending;
}

export function remoteAddressImpl(socket) {
  return socket.remoteAddress;
}

export function remoteFamilyImpl(socket) {
  return socket.remoteFamily;
}

export function remotePortImpl(socket) {
  return socket.remotePort;
}

export function resumeImpl(socket) {
  socket.resume();
}

export function setEncodingImpl(socket, encoding) {
  socket.setEncoding(encoding);
}

export function setKeepAliveImpl(socket, enable, initialDelay) {
  socket.setKeepAlive(enable, initialDelay);
}

export function setNoDelayImpl(socket, noDelay) {
  socket.setNoDelay(noDelay);
}

export function setTimeoutImpl(socket, timeout, callback) {
  socket.setTimeout(timeout, callback);
}

export function writeImpl(socket, buffer, callback) {
  return socket.write(buffer, null, callback);
}

export function writeStringImpl(socket, str, encoding, callback) {
  return socket.write(str, encoding, callback);
}
