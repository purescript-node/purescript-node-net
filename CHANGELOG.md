# Changelog

Notable changes to this project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Breaking changes:

New features:

Bugfixes:

Other improvements:

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

