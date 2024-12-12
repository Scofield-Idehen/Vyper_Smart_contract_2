# pragma version ^ 0.4.0

"""
@ license MIT
@ title Buy me a coffee
@ author: Scofield Idehen
@ notice: this contract is about building a contract 
"""

interface AggregatorV3Interface:
    def decimals() -> uint8: view
    def description() -> String[1000]: view
    def version() -> uint256: view
    def latestAnswer() -> int256: view


#storage veriable 

#mim_USD: public(constant(uint256)) = as_wei_value(5, "ether") #constant are not storage vairable 
min_USD: immutable(uint256)
priceFeed: public(immutable(AggregatorV3Interface))
owner: address
funders: public(DynArray[address, 1000])
magicNumber: constant(uint256) = 1 * (10 ** 18)
#map address to amount in uint256
funder_to_funders: public(HashMap[address, uint256])

@deploy
def __init__(price_feed: address, _min_usd: uint256): #we can pass the address we want sapolia or any other 
    priceFeed = AggregatorV3Interface(price_feed) #here we pass Sapolia 
    self.owner = msg.sender
    min_USD = _min_usd

@external
@payable 
def fund():
    self._fund() 

@internal
@payable
def _fund():
    usd_value_of_eth: uint256 = self.ETH_USD(msg.value)
    assert usd_value_of_eth >= min_USD  #1000000000000000000 #why dont we pass the min to init?
    self.funders.append(msg.sender)

@external 
def withdraw():
    assert msg.sender == self.owner, "not contract owner "
    #send(self.owner, self.balance)
    raw_call(owner, b"", value= self.balance)
    self.funders = [] #reset the array to zero
    for funder: address in self.funders:
        self.funder_to_funders[funder] = 0
    self.funders = []

@internal
@view
def ETH_USD(eth_amount: uint256) -> uint256: #takes a paremeneter for the price 
    price: int256 = staticcall priceFeed.latestAnswer() # checks the current ETh price
    eth_price: uint256 = convert(price, uint256) * (10 ** 10) #convert to uint as it is in int
    eth_amount_in_USD: uint256 = (eth_amount * eth_price) // magicNumber #reomve the extra decimal places 

    return eth_amount_in_USD



@external 
@view
def get_eth_to_usd_rate(eth_amount: uint256) -> uint256:
    return self.ETH_USD(eth_amount)

@external
@view
def get_price() -> int256:
    s_priceFeed: AggregatorV3Interface = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
    return staticcall s_priceFeed.latestAnswer()




@external 
@payable
def __default__():
    self._fund() 
