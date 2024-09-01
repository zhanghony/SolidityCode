// 本地以太坊区块浏览器
// npm install express web3@1.9.0
// node .\tools\eth-block-explorer.js

const express = require('express');
const Web3 = require('web3');
const app = express();
const web3 = new Web3('http://127.0.0.1:8545'); // Ganache 默认 RPC URL

app.get('/', async (req, res) => {
  const latestBlock = await web3.eth.getBlock('latest');
  res.send(`Latest Block: ${JSON.stringify(latestBlock, null, 2)}`);
});

app.get('/block/:number', async (req, res) => {
  const block = await web3.eth.getBlock(req.params.number);
  res.json(block);
});

app.get('/tx/:hash', async (req, res) => {
  const tx = await web3.eth.getTransaction(req.params.hash);
  res.json(tx);
});

app.get('/address/:addr', async (req, res) => {
  const balance = await web3.eth.getBalance(req.params.addr);
  res.json({ address: req.params.addr, balance: web3.utils.fromWei(balance, 'ether') });
});
/*
//监听事件
// 智能合约ABI和地址
const contractABI = [...]; // 合约ABI
const contractAddress = '0x...'; // 合约地址
const contract = new web3.eth.Contract(contractABI, contractAddress);
// 监听Transfer事件
contract.events.Transfer({
fromBlock: 'latest'
})
.on('data', (event) => {
console.log('新的Transfer事件:', event.returnValues);
})
.on('error', console.error);

*/
app.listen(3000, () => console.log('Explorer running on http://localhost:3000'));