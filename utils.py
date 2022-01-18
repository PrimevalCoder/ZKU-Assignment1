import sys, os, subprocess
import json
from web3 import Web3

def print_start_menu():
    print("Welcome to Dark Forest slim edition. Choose an option:")
    print('1 - Set up ZK')
    print('2 - Play')

def set_up_zk():
    """"
    Sets up the zk part of the game: compiles the circuit,
    generates a trusted setup, and exports the Solidity verifier.
    """
    cwd = os.getcwd()
    os.chdir('zk')
    retcode = subprocess.call('./precompute.sh')
    #print(retcode)
    os.chdir(cwd)

def print_game_menu(accounts):
    print('Select account:')
    print( '\n'.join(f'Acc. ({i}): {a}' for i, a in enumerate(accounts)) )

def print_action_menu():
    print('Action: ')
    print('1 - Spawn')
    print('2 - Change account')
    print('0 - Exit')

# snarkjs generatecall output isn't readily compatible with web3py 
def web3py_compat(P):
    if isinstance(P, list):
        return [web3py_compat(x) for x in P]
    else:   # is hex string
        return Web3.toInt(hexstr=P)

def get_zk_calldata():
    with open('zk/snark.txt') as f:
        s_snark = '[' + f.read() + ']'
        js_snark = json.loads(s_snark)
    return web3py_compat(js_snark)

def try_spawn(w3i, contract):
    print('Choose position: ')
    x = int( input('x = ') )
    y = int( input('y = ') )
    d = {'x': x, 'y': y}
    cwd = os.getcwd()
    os.chdir('zk')
    with open('input.json', 'w') as f:
        json.dump(d, f)
    retcode = subprocess.call('./compute_proof.sh')
    os.chdir(cwd)
    if retcode != 0:
        print('Failed generating proof. Please try different coordinates.')
        print('Conditions: gcd(x,y) > 1 and 32 < r <= 64')
        try_spawn(w3i, contract)
    else:
        # proof generated successfully, we need to send it to the contract; snarkjs generatecall goes into 'snark.txt'
        snark = get_zk_calldata()
        a, b, c, _inp = snark
        try:
            tx_hash = contract.functions.spawn(a, b, c, _inp).transact()
            tx_receipt = w3i.eth.waitForTransactionReceipt(tx_hash)
            logs = contract.events.Spawn().processReceipt(tx_receipt)
            print('Transaction logs:')
            print(logs)
            print('Spawned successfully.')

        except Exception as e:
            print('Transaction failed, please read further:')
            print(e)


    


def start_game(w3i, contract):
    print_game_menu(w3i.eth.accounts[:5])   # display only the first 5 accounts

    acc_choice = int( input('Choice: ') )   # we assume the input is valid
    w3i.eth.defaultAccount = w3i.eth.accounts[acc_choice]

    print_action_menu()
    action = int( input('Choice: ') )
    if action == 0:
        sys.exit()
    elif action == 1:
        try_spawn(w3i, contract)
    
    start_game(w3i, contract)
    
