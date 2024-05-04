# BitBoard Design
## Overview
The Bit Board implements a 2D gameboard of bits. It provides get and set methods for individual bits, as well as methods for  clearing the board. 
## See Also
These methods accept arguments as specified in inc/PageZero.inc . This spells out the page 0 locations used. Note callers
are expected to preserve registers and values as needed, functions overwrite values and registeres and do not preserve
prior values.
## Methods
### public `void InitBoard(uint16 baseAddr, uint8 width, uint8 height, uint8 initval)`
Constructor for the BitBoard. Initializes the board to all initval.
### public `void SetBit(uint16 baseAddr, uint8 x, uint8 y, uint8 bit)`
Sets the bit at the given x and y coordinates to the given value.
### public `uint8 GetBit(uint16 baseAddr, uint8 x, uint8 y)`
Returns the value of the bit at the given x and y coordinates. 
### public `uint8 GetLiveNeighborCount(uint16 baseAddr, uint8 x, uint8 y, uint8 width)`
Returns the number of live neighbors for the given x and y coordinates. 
### private `uint16 GetBitAddress(uint16 baseAddr, uint8 x, uint8 y)`
Returns the address of the bit at the given x and y coordinates. 
