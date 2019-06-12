# encoding: utf-8
from web3 import Web3, IPCProvider, WebsocketProvider, HTTPProvider
import sys
# w3 = Web3(Web3.WebsocketProvider('ws://0.0.0.0:31000')) # websocket
#w3 = Web3(IPCProvider("/home/cc/istanbultest/qdata/dd1/geth.ipc"))#ipc
w3 = Web3(HTTPProvider('http://10.50.0.5:22000'))#http rpc

# init
# with open('/Users/Radish/chain2/keystore/UTC--2018-05-08T11-52-01.776592127Z--f95dfc6771d82aae281dc6c7f5dae7190861fb10') as keyfile:
# 	encrypted_key = keyfile.read()
# 	private_key = w3.eth.account.decrypt(encrypted_key, 'correcthorsebatterystaple')

keyfile = open('/root/UTC--2019-01-23T05-00-44.084069100Z--701ea9db659487c87205ecd981c96e98b3b78ade')
encrypted_key = keyfile.read()
private_key = w3.eth.account.decrypt(encrypted_key, '123')

# 提交100000次交易 看看多久
# 看看cpu运行情况
import timeit
import time

   
base = w3.eth.getTransactionCount(Web3.toChecksumAddress("0x701ea9db659487c87205ecd981c96e98b3b78ade"))

start_ = timeit.default_timer()
#for i in range(10000):
while True:
	start = timeit.default_timer()

	a = w3.eth.account.signTransaction({
		# "from":w3.eth.accounts[0],
		"to":Web3.toChecksumAddress("0xb32cc4a82e7e2da62678a1bd14fad622333b87d6"),
		"value":0,
		# "gasLimit":25000,
		"gas":22000,
		"nonce": base,# + i, 
		"gasPrice":0, #w3.eth.gasPrice,
		# "chainId":1,
		"data":b''
		},private_key
	)
	base+=1
	q = w3.eth.sendRawTransaction(a.rawTransaction)
	stop = timeit.default_timer()
	time.sleep(0.003)
	# print(q)
	# sys.stdout.flush()
	# print("这是第%d次，耗时%s"%(i+1, stop - start))
stop_ = timeit.default_timer()
print("总耗时%s"%( stop_ - start_, ))

	# g(str(q.hex()))
