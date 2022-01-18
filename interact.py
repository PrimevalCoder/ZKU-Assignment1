from web3 import Web3, HTTPProvider
import json
from utils import *

# Ganache URL
blockchain_url = 'http://127.0.0.1:7545'

# simpler way to deploy: use Web3 Provider (Ganache + Metamask) with Remix and get the address
contract_address = '0xc8Acfe9c44113b2108482F364692D24254E82aFb'

w3 = Web3(HTTPProvider(blockchain_url, request_kwargs={'timeout': 60}))
w3.eth.defaultAccount = w3.eth.accounts[0]

contract_abi = open('contracts/DarkForest.abi').read()
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

print_start_menu()

option = int( input('Enter your option: ') )
if option == 1:
    set_up_zk()

else:
    start_game(w3, contract)
