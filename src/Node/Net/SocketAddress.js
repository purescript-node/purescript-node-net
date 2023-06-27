import net from "node:net";

const new_ = (options) => new net.SocketAddress(options);
export { new_ as newImpl };

export const address = (sa) => sa.address;
export const familyImpl = (sa) => sa.family;
export const flowLabelImpl = (sa) => sa.flowLabel;
export const port = (sa) => sa.port;
