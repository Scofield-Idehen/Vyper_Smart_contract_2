dynamic_array: public(DynArray[uint256, 100])

fixed_sized_arrray: public(uint256[100])
index: uint256

@external
@view

def dyn_array_size() -> uint256:
    return len(self.dynamic_array)

@external
def add_to_array():
    self.dynamic_array.append(1)
    self.fixed_sized_arrray[self.index] = 1 #set the zero index to 1
    self.index += 1
