module Test.Main (main) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (errorShow, infoShow, logShow)
import Node.Buffer (toString)
import Node.Encoding (Encoding(..))
import Node.Net as Node.Net

main :: Effect Unit
main = do
  server <- Node.Net.createServer mempty \socket -> do
    infoShow { _message: "Server received connection" }
    void $ Node.Net.writeString socket "Hello socket\n" UTF8 mempty
    Node.Net.endString socket "Server is ending connection\n" UTF8 mempty

  Node.Net.onCloseServer server do
    infoShow { _message: "Server closed" }
  Node.Net.onConnection server \socket -> do
    addr <- Node.Net.localAddress socket
    port <- Node.Net.localPort socket
    infoShow { _message: "Connection successfully made", addr, port }
  Node.Net.onErrorServer server \err -> do
    infoShow { _message: "Server had an error", err }
  Node.Net.onListening server do
    infoShow { _message: "Server is listening" }

  Node.Net.listenTCP server 0 "localhost" 511 do
    addr <- Node.Net.address server
    infoShow { _message: "Opened server", addr }
    case addr of
      Just (Left { port }) -> do
        socket <- Node.Net.createConnectionTCP port "localhost" do
          infoShow { _message: "Connected to server" }

        Node.Net.onCloseSocket socket case _ of
          false -> infoShow { _message: "Socket closed without an error" }
          true -> errorShow { _message: "Socket closed with an error" }
        Node.Net.onConnect socket do
          infoShow {_message: "Socket connected"}
        Node.Net.onData socket case _ of
          Left buffer -> do
            logShow { _message: "Received some data", buffer }
            bufferString <- toString UTF8 buffer
            logShow { _message: "Converted to a `String`", buffer, bufferString }
          Right string -> logShow { _message: "Received some data", string }
        void $ Node.Net.onDrain socket do
          infoShow { _message: "Socket drained" }
        Node.Net.onEnd socket do
          infoShow { _message: "Socket ended, closing server" }
          Node.Net.close server mempty
        Node.Net.onErrorSocket socket \err ->
          errorShow { _message: "Socket had an error", err }
        Node.Net.onLookup socket case _ of
          Left err ->
            infoShow { _message: "Socket had an error resolving DNS", err }
          Right lookup ->
            infoShow { _message: "Socket successfully resolved DNS", lookup }
        Node.Net.onReady socket do
          infoShow { _message: "Socket is ready" }
          void $ Node.Net.writeString socket "Hello server" UTF8 mempty
        Node.Net.onTimeout socket do
          infoShow { _message: "Socket timed out" }
          Node.Net.endString socket "Closing connection" UTF8 mempty

      Just (Right endpoint) -> do
        errorShow { _message: "Server unexpectedly connected over ICP" }
        Node.Net.close server mempty

      _ -> Node.Net.close server mempty
