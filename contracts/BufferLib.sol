pragma solidity >=0.5.3 <0.7.0;


/**
 * @title A convenient wrapper around the `bytes memory` type that exposes a buffer-like interface.
 * @notice The buffer has an inner cursor that tracks the final offset of every read, i.e. any subsequent read will
 * start with the byte that goes right after the last one in the previous read.
 */
library BufferLib {
  struct Buffer {
    bytes data;
    uint64 cursor;
  }

  /**
  * @notice Read and consume a certain amount of bytes from the buffer.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @param _length How many bytes to read and consume from the buffer.
  * @return A `bytes memory` containing the first `_length` bytes from the buffer, counting from the cursor position.
  */
  function read(Buffer memory _buffer, uint64 _length) internal pure returns (bytes memory) {
    // Make sure not to read out of the bounds of the original bytes
    require(_buffer.cursor + _length <= _buffer.data.length, "Not enough bytes in buffer when reading");
    // Create a new `bytes memory` value and copy the desired bytes into it
    bytes memory value = new bytes(_length);
    for (uint64 index = 0; index < _length; index++) {
      value[index] = next(_buffer);
    }

    return value;
  }

  /**
  * @notice Read and consume the next byte from the buffer.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @return The next byte in the buffer counting from the cursor position.
  */
  function next(Buffer memory _buffer) internal pure returns (byte) {
    // Return the byte at the position marked by the cursor and advance the cursor all at once
    return _buffer.data[_buffer.cursor++];
  }

  /**
  * @notice Move the inner cursor of the buffer to a relative or absolute position.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @param _offset How many bytes to move the cursor forward.
  * @param _relative Whether to count `_offset` from the last position of the cursor (`true`) or the beginning of the
  * buffer (`true`).
  * @return The final position of the cursor (will equal `_offset` if `_relative` is `false`).
  */
  function seek(Buffer memory _buffer, uint64 _offset, bool _relative) internal pure returns (uint64) {
    uint64 newCursor = _offset;
    // Deal with relative offsets
    if (_relative == true) {
      newCursor += _buffer.cursor;
    }
    // Make sure not to read out of the bounds of the original bytes
    require(newCursor < _buffer.data.length, "Not enough bytes in buffer when seeking");
    _buffer.cursor = newCursor;
    return _buffer.cursor;
  }

  /**
  * @notice Move the inner cursor a number of bytes forward.
  * @dev This is a simple wrapper around the relative offset case of `seek()`.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @param _relativeOffset How many bytes to move the cursor forward.
  * @return The final position of the cursor.
  */
  function seek(Buffer memory _buffer, uint64 _relativeOffset) internal pure returns (uint64) {
    return seek(_buffer, _relativeOffset, true);
  }

  /**
  * @notice Move the inner cursor back to the first byte in the buffer.
  * @param _buffer An instance of `BufferLib.Buffer`.
  */
  function rewind(Buffer memory _buffer) internal pure {
    _buffer.cursor = 0;
  }

  /**
  * @notice Read and consume the next byte from the buffer as an `uint8`.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @return The `uint8` value of the next byte in the buffer counting from the cursor position.
  */
  function readUint8(Buffer memory _buffer) internal pure returns (uint8) {
    bytes memory bytesValue = _buffer.data;
    uint64 offset = _buffer.cursor;
    uint8 value;
    assembly {
      value := mload(add(add(bytesValue, 1), offset))
    }
    _buffer.cursor++;

    return value;
  }

  /**
  * @notice Read and consume the next 2 bytes from the buffer as an `uint16`.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @return The `uint16` value of the next 2 bytes in the buffer counting from the cursor position.
  */
  function readUint16(Buffer memory _buffer) internal pure returns (uint16) {
    bytes memory bytesValue = _buffer.data;
    uint64 offset = _buffer.cursor;
    uint16 value;
    assembly {
      value := mload(add(add(bytesValue, 2), offset))
    }
    _buffer.cursor += 2;

    return value;
  }

  /**
  * @notice Read and consume the next 4 bytes from the buffer as an `uint32`.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @return The `uint32` value of the next 4 bytes in the buffer counting from the cursor position.
  */
  function readUint32(Buffer memory _buffer) internal pure returns (uint32) {
    bytes memory bytesValue = _buffer.data;
    uint64 offset = _buffer.cursor;
    uint32 value;
    assembly {
      value := mload(add(add(bytesValue, 4), offset))
    }
    _buffer.cursor += 4;

    return value;
  }

  /**
  * @notice Read and consume the next 8 bytes from the buffer as an `uint64`.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @return The `uint64` value of the next 8 bytes in the buffer counting from the cursor position.
  */
  function readUint64(Buffer memory _buffer) internal pure returns (uint64) {
    bytes memory bytesValue = _buffer.data;
    uint64 offset = _buffer.cursor;
    uint64 value;
    assembly {
      value := mload(add(add(bytesValue, 8), offset))
    }
    _buffer.cursor += 8;

    return value;
  }

  /**
  * @notice Read and consume the next 16 bytes from the buffer as an `uint128`.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @return The `uint128` value of the next 16 bytes in the buffer counting from the cursor position.
  */
  function readUint128(Buffer memory _buffer) internal pure returns (uint128) {
    bytes memory bytesValue = _buffer.data;
    uint64 offset = _buffer.cursor;
    uint128 value;
    assembly {
      value := mload(add(add(bytesValue, 16), offset))
    }
    _buffer.cursor += 16;

    return value;
  }

  /**
  * @notice Read and consume the next 32 bytes from the buffer as an `uint256`.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @return The `uint256` value of the next 32 bytes in the buffer counting from the cursor position.
  */
  function readUint256(Buffer memory _buffer) internal pure returns (uint256) {
    bytes memory bytesValue = _buffer.data;
    uint64 offset = _buffer.cursor;
    uint256 value;
    assembly {
      value := mload(add(add(bytesValue, 32), offset))
    }
    _buffer.cursor += 32;

    return value;
  }

  /**
  * @notice Read and consume the next 2 bytes from the buffer as an IEEE 754-2008 floating point number enclosed in an
  * `int32`.
  * @dev Due to the lack of support for floating or fixed point arithmetic in the EVM, this method offsets all values
  * by 5 decimal orders so as to get a fixed precision of 5 decimal positions, which should be OK for most `float16`
  * use cases. In other words, the integer output of this method is 10,000 times the actual value. The input bytes are
  * expected to follow the 16-bit base-2 format (a.k.a. `binary16`) in the IEEE 754-2008 standard.
  * @param _buffer An instance of `BufferLib.Buffer`.
  * @return The `uint32` value of the next 4 bytes in the buffer counting from the cursor position.
  */
  function readFloat16(Buffer memory _buffer) internal pure returns (int32) {
    uint32 bytesValue = readUint16(_buffer);
    // Get bit at position 0
    uint32 sign = bytesValue & 0x8000;
    // Get bits 1 to 5, then normalize to the [-14, 15] range so as to counterweight the IEEE 754 exponent bias
    int32 exponent = (int32(bytesValue & 0x7c00) >> 10) - 15;
    // Get bits 6 to 15
    int32 significand = int32(bytesValue & 0x03ff);

    // Add 1024 to the fraction if the exponent is 0
    if (exponent == 15) {
      significand |= 0x400;
    }

    // Compute `2 ^ exponent · (1 + fraction / 1024)`
    int32 result = 0;
    if (exponent >= 0) {
      result = int32(((1 << uint256(exponent)) * 10000 * (uint256(significand) | 0x400)) >> 10);
    } else {
      result = int32((((uint256(significand) | 0x400) * 10000) / (1 << uint256(- exponent))) >> 10);
    }

    // Make the result negative if the sign bit is not 0
    if (sign != 0) {
      result *= - 1;
    }
    return result;
  }
}
