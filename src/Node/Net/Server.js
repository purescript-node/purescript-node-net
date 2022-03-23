import net from "net";

export function addressImpl(server) {
  return server.address();
}

export function closeImpl(server, callback) {
  server.close(callback);
}

export const createServerImpl = net.createServer;

export function getConnectionsImpl(server, callback) {
  server.getConnections(callback);
}

export function listenImpl(server, options, callback) {
  server.listen(options, callback);
}

export function listeningImpl(socket) {
  return socket.listening;
}

export function onImpl(event, server, callback) {
  server.on(event, callback);
}
