# BitBoard Design
## Overview
The Bit Board implements a 2D gameboard of bits. It provides get and set methods for individual bits, as well as methods for  clearing the board. 

## Methods
### public `void InitBoard(uint16 baseAddr, uint8 width, uint8 height)`
Constructor for the BitBoard. Initializes the board to all zeros.
### public `void SetBit(uint16 baseAddr, uint8 x, uint8 y, uint8 bit)`
Sets the bit at the given x and y coordinates to the given value. X argument is in X register, Y argument in Y register, bit value in the accumulator, baseAddr is pushed onto the stack before the call.
### public `uint8 GetBit(uint16 baseAddr, uint8 x, uint8 y)`
Returns the value of the bit at the given x and y coordinates. Returns the bit value in the Accumulator register. Expects X value and Y value in X and Y registers respectively.
### private `uint16 GetBitAddress(uint16 baseAddr, uint8 x, uint8 y)`
Returns the address of the bit at the given x and y coordinates. Returns the address in allocated space on the stack. Expects caller to PHA baseHigh PHA baseLow then call, then PLA bitAddressLow PLA bitAddressHigh to get return value
