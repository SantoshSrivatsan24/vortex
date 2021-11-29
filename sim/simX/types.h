#pragma once

#include <stdint.h>
#include <bitset>
#include <VX_config.h>

namespace vortex {

typedef uint8_t  Byte;
typedef uint32_t Word32;
typedef uint64_t  Word64;

typedef int32_t  WordI;

// simx64
typedef uint32_t HalfWord;
typedef int32_t HalfWordI;

// simx64
typedef uint64_t Addr64;
typedef uint32_t Size;

typedef std::bitset<64> RegMask;

typedef std::bitset<32> ThreadMask;

typedef std::bitset<32> WarpMask;

}