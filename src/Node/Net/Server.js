import net from "node:net";

export const newServerImpl = () => new net.Server();
export const newServerOptionsImpl = (o) => new net.Server(o);

export const addressTcpImpl = (s) => s.address();
export const addressIpcImpl = (s) => s.address();
export const closeImpl = (s) => s.close();
export const getConnectionsImpl = (s, cb) => s.getConnections(cb);
export const listenImpl = (s, o) => s.listen(o);
export const listeningImpl = (s) => s.listening;
export const maxConnectionsImpl = (s) => s.maxConnections;
export const refImpl = (s) => s.ref();
export const unrefImpl = (s) => s.unref();
