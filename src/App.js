import { useState, useEffect } from 'react';
import logo from './logo.svg';
import './App.css';

function App() {
  const [ipAddress, setIpAddress] = useState('Loading...');

  useEffect(() => {
    // Using ipify API to get the public IP address
    fetch('https://api.ipify.org?format=json')
      .then(response => response.json())
      .then(data => setIpAddress(data.ip))
      .catch(error => {
        console.error('Error fetching IP:', error);
        setIpAddress('Failed to load IP');
      });
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <p className="text-xl">
          Server IP Address: <code>{ipAddress}</code>
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Testing source file change from github
        </a>
      </header>
    </div>
  );
}

export default App;