"use strict";

var net = require("net");

exports.addressImpl = function (server) {
  return function () {
    return server.address();
  };
};

exports.bufferSizeImpl = function (socket) {
  return function () {
    return socket.bufferSize;
  };
};

exports.bytesRead = function (socket) {
  return function () {
    return socket.bytesRead;
  };
};

exports.bytesWritten = function (socket) {
  return function () {
    return socket.bytesWritten;
  };
};

exports.closeImpl = function (server) {
  return function (callback) {
    return function () {
      server.close(function (err) {
        callback(err)();
      });
    };
  };
};

exports.connectImpl = function (socket) {
  return function (options) {
    return function (callback) {
      return function () {
        socket.connect(options, function () {
          callback();
        });
      };
    };
  };
};

exports.connecting = function (socket) {
  return function () {
    return socket.connecting;
  };
};

exports.createConnectionImpl = function (x) {
  return function (callback) {
    return function () {
      return net.createConnection(x, function () {
        callback();
      });
    };
  };
};

exports.createServerImpl = function (x) {
  return function (listener) {
    return function () {
      return net.createServer(x, function (socket) {
        listener(socket)();
      });
    };
  };
};

exports.destroyImpl = function (socket) {
  return function (err) {
    return function () {
      socket.destroy(err);
    };
  };
};

exports.destroyed = function (socket) {
  return function () {
    return socket.destroyed;
  };
};

exports.end = function (socket) {
  return function (buffer) {
    return function (callback) {
      return function () {
        socket.end(buffer, null, function () {
          callback();
        });
      };
    };
  };
};

exports.endString = function (socket) {
  return function (str) {
    return function (encoding) {
      return function (callback) {
        return function () {
          socket.end(str, encoding, function () {
            callback();
          });
        };
      };
    };
  };
};

exports.getConnectionsImpl = function (server) {
  return function (callback) {
    return function () {
      server.getConnections(function (err, count) {
        callback(err)(count)();
      });
    };
  };
};

exports.isIP = function (x) {
  return net.isIP(x);
};

exports.isIPv4 = function (x) {
  return net.isIPv4(x);
};

exports.isIPv6 = function (x) {
  return net.isIPv6(x);
};

exports.listenImpl = function (server) {
  return function (options) {
    return function (callback) {
      return function () {
        server.listen(options, function () {
          callback();
        });
      };
    };
  };
};

exports.listening = function (socket) {
  return function () {
    return socket.listening;
  };
};

exports.localAddressImpl = function (socket) {
  return function () {
    return socket.localAddress;
  };
};

exports.localPortImpl = function (socket) {
  return function () {
    return socket.localPort;
  };
};

exports.onCloseServer = function (server) {
  return function (callback) {
    return function () {
      server.on("close", function () {
        callback();
      });
    };
  };
};

exports.onCloseSocket = function (socket) {
  return function (callback) {
    return function () {
      socket.on("close", function (hadError) {
        callback(hadError)();
      });
    };
  };
};

exports.onConnect = function (socket) {
  return function (callback) {
    return function () {
      socket.on("connect", function () {
        callback();
      });
    };
  };
};

exports.onConnection = function (server) {
  return function (callback) {
    return function () {
      server.on("connection", function (socket) {
        callback(socket)();
      });
    };
  };
};

exports.onDataImpl = function (server) {
  return function (callbackBuffer) {
    return function (callbackString) {
      return function () {
        server.on("data", function (data) {
          if (typeof data === "string") {
            callbackString(data)();
          } else {
            callbackBuffer(data)();
          }
        });
      };
    };
  };
};

exports.onDrain = function (server) {
  return function (callback) {
    return function () {
      server.on("drain", function () {
        callback();
      });
    };
  };
};

exports.onEnd = function (server) {
  return function (callback) {
    return function () {
      server.on("end", function () {
        callback();
      });
    };
  };
};

exports.onErrorServer = function (server) {
  return function (callback) {
    return function () {
      server.on("error", function (err) {
        callback(err)();
      });
    };
  };
};

exports.onErrorSocket = function (socket) {
  return function (callback) {
    return function () {
      socket.on("error", function (err) {
        callback(err)();
      });
    };
  };
};

exports.onListening = function (server) {
  return function (callback) {
    return function () {
      server.on("listening", function () {
        callback();
      });
    };
  };
};

exports.onLookupImpl = function (server) {
  return function (callback) {
    return function () {
      server.on("lookup", function (err, address, family, host) {
        callback(err, address, family, host)();
      });
    };
  };
};

exports.onReady = function (server) {
  return function (callback) {
    return function () {
      server.on("ready", function () {
        callback();
      });
    };
  };
};

exports.onTimeout = function (server) {
  return function (callback) {
    return function () {
      server.on("timeout", function () {
        callback();
      });
    };
  };
};

exports.pause = function (socket) {
  return function () {
    socket.pause();
  };
};

exports.pending = function (socket) {
  return function () {
    return socket.pending;
  };
};

exports.remoteAddressImpl = function (socket) {
  return function () {
    return socket.remoteAddress;
  };
};

exports.remoteFamilyImpl = function (socket) {
  return function () {
    return socket.remoteFamily;
  };
};

exports.remotePortImpl = function (socket) {
  return function () {
    return socket.remotePort;
  };
};

exports.resume = function (socket) {
  return function () {
    socket.resume();
  };
};

exports.setEncoding = function (socket) {
  return function (encoding) {
    return function () {
      socket.setEncoding(encoding);
    };
  };
};

exports.setKeepAlive = function (socket) {
  return function (enable) {
    return function (initialDelay) {
      return function () {
        socket.setKeepAlive(enable, initialDelay);
      };
    };
  };
};

exports.setNoDelay = function (socket) {
  return function (noDelay) {
    return function () {
      socket.setNoDelay(noDelay);
    };
  };
};

exports.setTimeout = function (socket) {
  return function (timeout) {
    return function (callback) {
      return function () {
        socket.setTimeout(timeout, function () {
          callback();
        });
      };
    };
  };
};

exports.write = function (socket) {
  return function (buffer) {
    return function (callback) {
      return function () {
        return socket.write(buffer, null, function () {
          callback();
        });
      };
    };
  };
};

exports.writeString = function (socket) {
  return function (str) {
    return function (encoding) {
      return function (callback) {
        return function () {
          return socket.write(str, encoding, function () {
            callback();
          });
        };
      };
    };
  };
};
