import Web3 from 'web3'
import React, { Component } from 'react'
import NoWeb3Screen from './screens/ErrorScreen-NoWeb3'
import MainScreen from './screens/MainScreen'

class App extends Component {
  constructor(props, context) {
    super(props, context)

    this.state = {
      web3: this.setWeb3Provider()
    }
  }

  setWeb3Provider() {
    this.web3 = new Web3(Web3.givenProvider)
    return (this.web3.givenProvider) ? true : false
  }

  render() {
    return (
      <div className="app" style={styles.container}>
        { (this.state.web3) ? <MainScreen web3={this.web3}/> : <NoWeb3Screen/> }
      </div>
    )
  }
}

const styles = {
  container: {
    height: '100vh',
    padding: 0,
    margin: 0,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  }
}

export default App
