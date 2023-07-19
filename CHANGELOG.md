# Changelog

Notable changes to this project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Breaking changes:
- Bumped `node-buffer` and `node-fs` to `v9.0.0` (#12, #17 by @JordanMartinez)
- Update event handling API to use EventHandle-style API (#16 by @JordanMartinez)

  Before:
  ```purs
  foo = do
    Socket.onClose socket \b -> doSomething
  ```

  After:
  ```purs
  foo = do
    socket # on_ Socket.closeH \b -> doSomething
  ```
- Renamed `isIP` to `isIP'` so that `isIP` returns an ADT

  Previously, `Node.Net.isIP` returned an integer that could be one of two values,
  4 or 6. This function was renamed to `isIP'`, so that `isIP` could return
  an algebraic data type value representing that 4 or 6.
- Distinguish between an IPC and TCP socket/server via phantom type (#16 by @JordanMartinez)

  Some functions (e.g. `Node.Net.Server.address`) return different values depending on whether
  the provided server is an IPC or TCP server. Similarly, some functions
  only work on IPC sockets/server rather than TCP ones.
  
  Rather than forcing the end-user to handle a case that's not possible,
  a phantom type was added to `Socket` and `Server` to indicate which 
  kind of socket/server it is.

  If a function was named `foo` before and it worked differently depending on
  whether the socket/server was IPC or TCP, it is now suffixed with `Ipc` or `Tcp`
  to distinguish which it works on.

New features:
- Added bindings for the `BlockList` class (#16 by @JordanMartinez)
- Added bindings for the `SocketAddress` class (#16 by @JordanMartinez)

Bugfixes:

Other improvements:
- Bump CI node to v18 (#12 by @JordanMartinez)
- Enforce formatting in CI via `purs-tidy` (#12 by @JordanMartinez)
- Updated all FFI to use uncurried functions (#16 by @JordanMartinez)

## [v4.0.0](https://github.com/purescript-node/purescript-node-net/releases/tag/v4.0.0) - 2022-04-29

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#11 by @JordanMartinez, @thomashoneyman, @sigma-andex)

## [v3.0.0](https://github.com/purescript-node/purescript-node-net/releases/tag/v3.0.0) - 2022-04-27

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#11 by @JordanMartinez, @thomashoneyman, @sigma-andex)

New features:

Bugfixes:

Other improvements:

## [v2.0.1](https://github.com/purescript-node/purescript-node-net/releases/tag/v2.0.1) - 2021-04-01

Bugfixes:
  - Fixed the encoding used throughout the project to use the string expected by Node instead of the PureScript representation (#9 by @i-am-the-slime).

## [v2.0.0](https://github.com/purescript-node/purescript-node-net/releases/tag/v2.0.0) - 2021-02-26

Breaking changes:
  - Added support for PureScript 0.14 and dropped support for all previous versions (#4)

Other improvements:
  - Migrated CI to GitHub Actions, updated installation instructions to use Spago, and switched from `jshint` to `eslint` (#3)
  - Added a changelog and pull request template (#6)
  - Remove `bufferBinary` tests (#5)

## [v1.0.0](https://github.com/purescript-node/purescript-node-net/releases/tag/v1.0.0) - 2019-05-27

The initial release of the `net` bindings.

* Creates a `Node.Net` module with the following exports:
    * `isIP`
    * `isIPv4`
    * `isIPv6`
* Creates a `Node.Net.Server` module with the following exports:
    * `Address`
    * `ListenOptions`
    * `Server`
    * `ServerOptions`
    * `address`
    * `close`
    * `createServer`
    * `getConnections`
    * `listen`
    * `listenBacklog`
    * `listenExclusive`
    * `listenHost`
    * `listenICP`
    * `listenIpv6Only`
    * `listenPath`
    * `listenPort`
    * `listenReadableAll`
    * `listenTCP`
    * `listenWritableAll`
    * `listening`
    * `onClose`
    * `onConnection`
    * `onError`
    * `onListening`
    * `serverAllowHalfOpen`
    * `serverPauseOnConnect`
* Creates a `Node.Net.Socket` module with the following exports:
    * `ConnectOptions`
    * `Lookup`
    * `Socket`
    * `SocketOptions`
    * `bufferSize`
    * `bytesRead`
    * `bytesWritten`
    * `connect`
    * `connectFamily`
    * `connectHints`
    * `connectHost`
    * `connectICP`
    * `connectLocalAddress`
    * `connectLocalPort`
    * `connectPath`
    * `connectPort`
    * `connectTCP`
    * `connecting`
    * `createConnection`
    * `createConnectionICP`
    * `createConnectionTCP`
    * `destroy`
    * `destroyed`
    * `end`
    * `endString`
    * `localAddress`
    * `localPort`
    * `onClose`
    * `onConnect`
    * `onData`
    * `onDrain`
    * `onEnd`
    * `onError`
    * `onLookup`
    * `onReady`
    * `onTimeout`
    * `pause`
    * `pending`
    * `remoteAddress`
    * `remoteFamily`
    * `remotePort`
    * `resume`
    * `setEncoding`
    * `setKeepAlive`
    * `setNoDelay`
    * `setTimeout`
    * `socketAllowHalfOpen`
    * `socketFd`
    * `socketHost`
    * `socketPath`
    * `socketPort`
    * `socketReadable`
    * `socketTimeout`
    * `socketWritable`
    * `write`
    * `writeString`

