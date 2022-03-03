import './App.css';

import React, { useEffect } from 'react';
import Web3 from 'web3';

function App() {
  const providerUrl = 'http://localhost:8545';

  useEffect(() =>{
    const web3 = new Web3(providerUrl);

    let provider = window.ethereum;

    if (typeof provider !== 'undefined'){
      // Metamask is installed!

      provider
        .request({method:'eth_requestAccounts'})
        .then((accounts)=>{
          console.log(accounts);
        })
        .catch((err) => {
          console.log(err);
        });

    } else{
      //prompt user to install metamask first
      console.log("install metamask first")
    }
  }, []);

  return (
    <div className="App"></div>
  );
}

export default App;
