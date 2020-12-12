module Test.Main (main) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (errorShow, infoShow, logShow)
import Node.Buffer (toString)
import Node.Encoding (Encoding(..))
import Node.Net.Server as Node.Net.Server
import Node.Net.Socket as Node.Net.Socket

main :: Effect Unit
main = do
  server <- Node.Net.Server.createServer mempty \socket -> do
    infoShow { _message: "Server received connection" }
    void $ Node.Net.Socket.writeString socket "Hello socket\n" UTF8 mempty
    Node.Net.Socket.endString socket "Server is ending connection\n" UTF8 mempty

  Node.Net.Server.onClose server do
    infoShow { _message: "Server closed" }
  Node.Net.Server.onConnection server \socket -> do
    addr <- Node.Net.Socket.localAddress socket
    port <- Node.Net.Socket.localPort socket
    infoShow { _message: "Connection successfully made", addr, port }
  Node.Net.Server.onError server \err -> do
    infoShow { _message: "Server had an error", err }
  Node.Net.Server.onListening server do
    infoShow { _message: "Server is listening" }

  Node.Net.Server.listenTCP server 0 "localhost" 511 do
    addr <- Node.Net.Server.address server
    infoShow { _message: "Opened server", addr }
    case addr of
      Just (Left { port }) -> do
        socket <- Node.Net.Socket.createConnectionTCP port "localhost" do
          infoShow { _message: "Connected to server" }

        Node.Net.Socket.onClose socket case _ of
          false -> infoShow { _message: "Socket closed without an error" }
          true -> errorShow { _message: "Socket closed with an error" }
        Node.Net.Socket.onConnect socket do
          infoShow {_message: "Socket connected"}
        Node.Net.Socket.onData socket case _ of
          Left buffer -> do
            bufferString <- toString UTF8 buffer
            logShow { _message: "Received some data", bufferString }
          Right string -> logShow { _message: "Received some data", string }
        Node.Net.Socket.onDrain socket do
          infoShow { _message: "Socket drained" }
        Node.Net.Socket.onEnd socket do
          infoShow { _message: "Socket ended, closing server" }
          Node.Net.Server.close server mempty
        Node.Net.Socket.onError socket \err ->
          errorShow { _message: "Socket had an error", err }
        Node.Net.Socket.onLookup socket case _ of
          Left err ->
            infoShow { _message: "Socket had an error resolving DNS", err }
          Right lookup ->
            infoShow { _message: "Socket successfully resolved DNS", lookup }
        Node.Net.Socket.onReady socket do
          infoShow { _message: "Socket is ready" }
          void $ Node.Net.Socket.writeString socket "Hello server" UTF8 mempty
        Node.Net.Socket.onTimeout socket do
          infoShow { _message: "Socket timed out" }
          Node.Net.Socket.endString socket "Closing connection" UTF8 mempty

      Just (Right endpoint) -> do
        errorShow { _message: "Server unexpectedly connected over ICP" }
        Node.Net.Server.close server mempty

      _ -> Node.Net.Server.close server mempty
