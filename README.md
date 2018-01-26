# High Card Draw

---

## ( :construction: WARNING :construction: ) IN DEVELOPMENT

Ethereum contract backend for card game.

## Todo

- [x] Fix gas exceed error
- [x] Remove random draw to `_gameMatchPlay` to prevent "check storage cheat"
- [x] Improve random number generation
- [x] Possibly create and store game session archive (Potential array growth problem)
- [x] Create basic front-end to interact with contract (via MetaMask)
- [ ] Create events for Web3
- [ ] Get events in front-end UI to show game results
- [ ] Fix tie draw logic. (Sudden death or refund)
- [ ] Add prizePool & pastWinners storage
- [ ] Admin controls (endContract, gameCostChange, prizePool)
- [ ] Separate logic, data, and core contract
- [ ] Even out player gas cost
- [ ] Optimize for reduce gas cost
- [ ] Create UI for front-end
