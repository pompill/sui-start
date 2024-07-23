const { ethers } = require("ethers");

// 配置
const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const wallet = new ethers.Wallet(privateKey, provider);
const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const abi = [
    "event Bridge(address indexed user, uint256 amount, address to)",
    "event Mint(address indexed to, uint256 amount)",
    "event WithDrawl(address indexed user, uint256 amount)",
    "function bridge(address to) public payable",
    "function withDrawl() public",
    "function mint(uint256 amount, address to) external payable",
];

// 创建合约实例
const contract = new ethers.Contract(contractAddress, abi, wallet);

// 监听 Bridge 事件
contract.on("Bridge", (user, amount, to, event) => {
    console.log(`Bridge event: user=${user}, amount=${amount.toString()}, to=${to}`);
});

// 调用 mint 函数
async function mintTokens(to, amount) {
    const tx = await contract.mint(amount, to, {
        gasLimit: 3000000, // 设置适当的gas限制
    });
    console.log("Mint transaction sent:", tx.hash);
    const receipt = await tx.wait();
    console.log("Mint transaction mined:", receipt.transactionHash);
}

// 示例调用 mint 函数
const recipient = "0xRecipientAddress"; // 替换为实际的接收地址
const amountToMint = ethers.utils.parseEther("1.0"); // 需要铸造的金额
mintTokens(recipient, amountToMint);
