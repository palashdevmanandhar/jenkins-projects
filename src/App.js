import { useState, useEffect } from 'react';
import logo from './logo.svg';
import './App.css';

function App() {
  const [serverIP, setServerIP] = useState('Loading...');

  useEffect(() => {
    const fetchIP = async () => {
      try {
        const response = await fetch('/api/ip');
        const data = await response.json();
        setServerIP(data.ip);
      } catch (error) {
        setServerIP('Failed to load IP');
        console.error('Error fetching IP:', error);
      }
    };
    fetchIP();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <p className="text-xl">
          Server IP: {serverIP}
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          route 53 integrstion
        </a>
      </header>
    </div>
  );
}

export default App;
