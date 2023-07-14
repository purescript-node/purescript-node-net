export const addAddressImpl = (bl, addr, ty) => bl.addAddress(addr, ty);
export const addRangeImpl = (bl, start, end, ty) => bl.addRange(start, end, ty);
export const addSubnetImpl = (bl, net, prefix, ty) => bl.addSubnet(net, prefix, ty);
export const checkImpl = (bl, addr, ty) => bl.check(addr, ty);
export const rulesImpl = (bl) => bl.rules;
