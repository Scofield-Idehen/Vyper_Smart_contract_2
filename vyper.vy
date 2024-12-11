# pragma version ^ 0.4.0

# @author: Scofield Idehen


interface AggregatorV3Interface:
    def decimals() -> uint8: view
    def description() -> String[1000]: view
    def version() -> uint256: view
    def latestAnswer() -> int256: view

mim_USD: uint256 #state variable 
priceFeed: public(AggregatorV3Interface)
owner: address
funders: public(DynArray[address, 1000])
#map address to amount in uint256
funder_to_funders: public(HashMap[address, uint256])

@deploy
def __init__(price_feed: address): #we can pass the address we want sapolia or any other 
    self.priceFeed = AggregatorV3Interface(price_feed) #here we pass Sapolia 
    self.owner = msg.sender
    

@external
@payable
def fund():
    usd_value_of_eth: uint256 = self.ETH_USD(msg.value)
    assert usd_value_of_eth >= self.mim_USD  #1000000000000000000
    self.funders.append(msg.sender)

@external 
def withdraw():
    assert msg.sender == self.owner, "not contract owner "
    send(self.owner, self.balance)
    self.funders = [] #reset the array to zero
    for funder: address in self.funders:
        self.funder_to_funders[funder] = 0
    self.funders = []

@internal
@view
def ETH_USD(eth_amount: uint256) -> uint256: #takes a paremeneter for the price 
    price: int256 = staticcall self.priceFeed.latestAnswer() # checks the current ETh price
    eth_price: uint256 = convert (price, uint256) * (10 ** 10) #convert to uint as it is in int
    eth_amount_in_USD: uint256 = (eth_amount * eth_price) // (1 * (10 ** 10)) #reomve the extra decimal places 
    return eth_amount_in_USD


@external 
@view
def get_eth_to_usd_rate(eth_amount: uint256) -> uint256:
    return self.ETH_USD(eth_amount)

@external
@view
def get_price() -> int256:
    priceFeed: AggregatorV3Interface = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
    return staticcall priceFeed.latestAnswer()




#0x694AA1769357215DE4FAC081bf1f309aDC325306
