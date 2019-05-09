module Test.Main (main) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (errorShow, infoShow, logShow)
import Node.Buffer (toString)
import Node.Encoding (Encoding(..))
import Node.Net (address, close, createConnectionTCP, createServer, endString, listenTCP, localAddress, localPort, onCloseServer, onCloseSocket, onConnect, onConnection, onData, onDrain, onEnd, onErrorServer, onErrorSocket, onListening, onLookup, onReady, onTimeout, writeString)

main :: Effect Unit
main = do
  server <- createServer mempty \socket -> do
    infoShow { _message: "Server received connection" }
    void $ writeString socket "Hello socket\n" UTF8 mempty
    endString socket "Server is ending connection\n" UTF8 mempty

  onCloseServer server do
    infoShow { _message: "Server closed" }
  onConnection server \socket -> do
    addr <- localAddress socket
    port <- localPort socket
    infoShow { _message: "Connection successfully made", addr, port }
  onErrorServer server \err -> do
    infoShow { _message: "Server had an error", err }
  onListening server do
    infoShow { _message: "Server is listening" }

  listenTCP server 0 "localhost" 511 do
    addr <- address server
    infoShow { _message: "Opened server", addr }
    case addr of
      Just (Left { port }) -> do
        socket <- createConnectionTCP port "localhost" do
          infoShow { _message: "Connected to server" }

        onCloseSocket socket case _ of
          false -> infoShow { _message: "Socket closed without an error" }
          true -> errorShow { _message: "Socket closed with an error" }
        onConnect socket do
          infoShow {_message: "Socket connected"}
        onData socket case _ of
          Left buffer -> do
            logShow { _message: "Received some data", buffer }
            bufferString <- toString UTF8 buffer
            logShow { _message: "Converted to a `String`", buffer, bufferString }
          Right string -> logShow { _message: "Received some data", string }
        void $ onDrain socket do
          infoShow { _message: "Socket drained" }
        onEnd socket do
          infoShow { _message: "Socket ended, closing server" }
          close server mempty
        onErrorSocket socket \err ->
          errorShow { _message: "Socket had an error", err }
        onLookup socket case _ of
          Left err ->
            infoShow { _message: "Socket had an error resolving DNS", err }
          Right lookup ->
            infoShow { _message: "Socket successfully resolved DNS", lookup }
        onReady socket do
          infoShow { _message: "Socket is ready" }
          void $ writeString socket "Hello server" UTF8 mempty
        onTimeout socket do
          infoShow { _message: "Socket timed out" }
          endString socket "Closing connection" UTF8 mempty

      Just (Right endpoint) -> do
        errorShow { _message: "Server unexpectedly connected over ICP" }
        close server mempty

      _ -> close server mempty
