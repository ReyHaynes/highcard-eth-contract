import React, { Component } from 'react'
import contract from './../contracts/config'
import PlayButton from './../components/PlayButton'

export default class MainScreen extends Component {
  constructor(props, context) {
    super(props, context)

    this.contract = new this.props.web3.eth.Contract(contract.abi, contract.address)
  }

  render() {
    return (
      <div className="gameUI">
        <PlayButton web3={this.props.web3} contract={this.contract}/>
      </div>
    )
  }
}
