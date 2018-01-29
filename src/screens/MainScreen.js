import React, { Component } from 'react'
import contract from './../contracts/config'

export default class MainScreen extends Component {
  constructor(props, context) {
    super(props, context)

    this.state = {
      styles: {
        playButton: {
          background: 'black'
        }
      }
    }

    this.contract = new this.props.web3.eth.Contract(contract.abi, contract.address)

    this.playOnClick = this.playOnClick.bind(this)
  }

  render() {
    return (
      <div className="gameUI">
        <button
          className="playButton"
          style={{...styles.playButton, ...this.state.styles.playButton}}
          onMouseEnter={() => {
              let style = this.state.styles
              style.playButton.background = 'gray'
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
      </div>
    )
  }

  async playOnClick() {
    let { web3 } = this.props
    let accounts = await web3.eth.getAccounts()
    let account = accounts[0]
    let play = this.contract.methods.play().encodeABI()

    let transaction = await web3.eth.sendTransaction({
      from: account,
      to: contract.address,
      value: web3.utils.toWei('0.01'),
      gasPrice: web3.utils.toWei('2', 'gwei'),
      gas: 150000,
      data: play
    }, (err, txHash) => {
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
    border: 0,
    cursor: 'pointer'
  }
}
