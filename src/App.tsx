import { useEffect, useState } from "react";

import "./App.css";

const URL = "wss://xxxxxx.execute-api.ap-northeast-1.amazonaws.com/prod/";
const socket = new WebSocket(URL);

const App = () => {
  const [question, setQuestion] = useState<string>("");
  const [messages, setMessages] = useState<string[]>([]);
  const [newMessage, setNewMessage] = useState("");

  useEffect(() => {
    socket.addEventListener("message", (event) => {
      const message = event.data as string;
      setMessages((prevMessages) => [...prevMessages, message]);
    });
  }, []);

  const sendWebSocketMessage = () => {
    socket.send(newMessage);
    setQuestion(newMessage);
    setNewMessage("");
  };

  const sendLambdaStreamMessage = async () => {
    await fetch("https://xxxxxx.lambda-url.ap-northeast-1.on.aws/", {
      method: "POST",
      body: JSON.stringify({ data: { newMessage } }),
    }).then((response) => {
      const reader = response.body?.getReader();

      function read() {
        reader?.read().then(function (result) {
          if (!result.done) {
            const message = new TextDecoder("utf-8").decode(result.value);
            setMessages((prevMessages) => [...prevMessages, message]);

            read();
          }
        });
      }
      read();
    });
    setQuestion(newMessage);
    setNewMessage("");
  };

  const answer = messages.join("").replace(/"/g, "").replace(/\\n/g, "\n");

  return (
    <div className="app">
      <input
        className="query"
        type="text"
        value={newMessage}
        onChange={(e) => setNewMessage(e.target.value)}
      />
      <button onClick={sendWebSocketMessage}>WebSocket</button>
      <button onClick={sendLambdaStreamMessage}>LambdaStream</button>

      {question && <p>{`Q: ${question}`}</p>}
      {answer && <p className="text">{`A: ${answer}`}</p>}
    </div>
  );
};

export default App;
