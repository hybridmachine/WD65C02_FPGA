# Multi Target I2C
Support multiple I2C target addresses, segmenting the 2k buffer up so that each target has its own streaming
buffer
## Updates to TestI2CLogger.asm
1. Setup a data I2C address and assign it the first 1024 bytes of buffer
1. Setup a debug I2C address and assign it the next 128 bytes of buffer
1. Write application and debug stream data
1. Stream the debug
1. Stream the application data
1. Write more debug data and stream that
## Create debug library that will track assigned debug buffer and prevent over filling
