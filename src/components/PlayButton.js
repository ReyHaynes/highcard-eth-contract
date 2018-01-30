import React, { Component } from 'react'

export default class MainScreen extends Component {
  constructor(props, context) {
    super(props, context)

    this.state = {
      transactionInProgress: false,
      styles: {
        playButton: {
          background: 'black',
          cursor: 'pointer'
        }
      }
    }

    this.playOnClick = this.playOnClick.bind(this)
  }

  render() {
    return (
      <button
        className="playButton"
        style={{...styles.playButton, ...this.state.styles.playButton}}
        onMouseEnter={() => {
            let style = this.state.styles
            style.playButton.background = 'gray'
            style.playButton.cursor = (this.state.transactionInProgress) ? 'wait' : 'pointer'
            this.setState({ style })
        }}
        onMouseLeave={() => {
          let style = this.state.styles
          style.playButton.background = 'black'
          this.setState({ style })
        }}
        onClick={this.playOnClick}>
          Play
      </button>
    )
  }

  async playOnClick() {
    let { web3, contract } = this.props
    let accounts = await web3.eth.getAccounts()
    let account = accounts[0]
    let play = contract.methods.play().encodeABI()

    this.setState({ transactionInProgress: true })

    let transaction = await web3.eth.sendTransaction({
      from: account,
      to: contract.address,
      value: web3.utils.toWei('0.01'),
      gasPrice: web3.utils.toWei('2', 'gwei'),
      gas: 150000,
      data: play
    }, (err, txHash) => {
      this.setState({ transactionInProgress: false })
      if (err) {
        console.log('Failed!')
        return false;
      }
      console.log('Good!')
      return txHash;
    })

    console.log(transaction)
  }
}

const styles = {
  playButton: {
    color: 'white',
    padding: '15px 30px',
    font: '1.15em arial, sans-serif',
    WebkitFontSmoothing: 'antialiased',
    fontSmoothing: 'antialiased',
    textRendering: 'optimizeLegibility',
    textTransform: 'uppercase',
    border: 0
  }
}
