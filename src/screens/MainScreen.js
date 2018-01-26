import React, { Component } from 'react'
import contract from './../contracts/config'

export default class MainScreen extends Component {
  constructor(props, context) {
    super(props, context)

    this.contract = new this.props.web3.eth.Contract(contract.abi, contract.address)

    this.playOnClick = this.playOnClick.bind(this)
  }

  render() {
    return (
      <div className="gameUI">
        <button
          className="playGame"
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
