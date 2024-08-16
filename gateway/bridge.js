const { ethers } = require("ethers");

// 初始化 Ether.js 和合约
const provider = new ethers.providers.JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/cV-tG7B1AKHF1z5d4NWBCXMmwFqprOEI");
const signer = new ethers.Wallet("f65ff5c316793187d88cec43915f9399ad45dd30cd967c87be456ae0983e231b", provider);  // 我的合约owner私钥
const bridgeContractAddress = "0xf786f7A223dE30e6ED38689090AB0624f81C54e2"; // 合约地址
const bridgeABI = [
    "event Bridge(address indexed user, uint64 orderId, uint256 amount, address to)"
];
const bridgeContract = new ethers.Contract(bridgeContractAddress, bridgeABI, provider);

// 监控 Bridge 事件,监听到了之后往sui发钱
function monitorBridgeEvent() {
    bridgeContract.on("Bridge", async (user, orderId, amount, to) => {
        console.log(`Detected Bridge Event: user=${user}, orderId=${orderId}, amount=${amount}, to=${to}`);

        // 将 Sui 发送到 Sui 合约
        // 假设发送Sui的函数 sendSuiToContract
        try {
            await sendSuiToContract(orderId, to, amount);
            console.log(`Sui successfully sent to ${to} for orderId: ${orderId}`);
        } catch (error) {
            console.error(`Error sending Sui: ${error}`);
        }
    });
}



async function sendSuiToContract(orderId, to, amount) {
    // 这个函数里发送Sui
}


const bridgeContractWithSigner = bridgeContract.connect(signer);

async function mintToUser(orderId, amount, to) {
    try {
        const tx = await bridgeContractWithSigner.mint(orderId, amount, to);
        await tx.wait();
        console.log(`Minted ${amount} ETH to ${to} with orderId: ${orderId}`);
    } catch (error) {
        console.error(`Error minting funds: ${error}`);
    }
}

// 当收到 Sui 的事件时调用，调用这个往我的合约里面打钱
async function onSuiEvent(orderId, amount, to) {
    // 收到一个来自 Sui 的跨链事件，并且你需要调用 mint
    await mintToUser(orderId, amount, to);
}

// 检查打钱这件事完成了没有。
async function checkFinishOrderEvent(orderId) {
    const finishOrderEvent = await bridgeContract.queryFilter(
        bridgeContract.filters.FinishOrderEvent(orderId),
        0, // 从区块高度 0 开始查询，或可以指定具体区块范围
        "latest" // 查询到最新的区块
    );

    if (finishOrderEvent.length > 0) {
        console.log(`Order ${orderId} is complete:`, finishOrderEvent);
        return true;
    } else {
        console.log(`Order ${orderId} is not yet complete.`);
        return false;
    }
}

async function checkOrderCompletion(orderId) {
    const isComplete = await checkFinishOrderEvent(orderId);
    if (isComplete) {
        // 执行一些操作，比如更新数据库或通知用户
    }
}
