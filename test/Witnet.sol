pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;

import "truffle/Assert.sol";
import "../contracts/Witnet.sol";


contract WitnetTest {
  using Witnet for Witnet.Result;

  // Test the `Witnet.stageNames` pure method, which gives strings with the names for the different Witnet request
  // stages
  function testStageNames() public {
    Assert.equal(Witnet.stageName(0), "retrieval", "Stage name for stage #1 should be \"retrieval\"");
    Assert.equal(Witnet.stageName(1), "aggregation", "Stage name for stage #1 should be \"aggregation\"");
    Assert.equal(Witnet.stageName(2), "tally", "Stage name for stage #1 should be \"tally\"");
  }

  // Check that all the RADON errors are supported
  function testErrorCodesSize() public {
    Assert.equal(uint(Witnet.ErrorCodes.Size), uint(67), "Not every RADON error is supported in `Witnet.ErrorCodes`");
  }

  // Test decoding of `RadonError` error codes
  function testErrorCodes() public {
    Witnet.ErrorCodes errorCode0x00 = Witnet.resultFromCborBytes(hex"D8278100").asErrorCode();
    Witnet.ErrorCodes errorCode0x01 = Witnet.resultFromCborBytes(hex"D8278101").asErrorCode();
    Witnet.ErrorCodes errorCode0x02 = Witnet.resultFromCborBytes(hex"D8278102").asErrorCode();
    Witnet.ErrorCodes errorCode0x03 = Witnet.resultFromCborBytes(hex"D8278103").asErrorCode();
    Witnet.ErrorCodes errorCode0x10 = Witnet.resultFromCborBytes(hex"D8278110").asErrorCode();
    Witnet.ErrorCodes errorCode0x11 = Witnet.resultFromCborBytes(hex"D8278111").asErrorCode();
    Witnet.ErrorCodes errorCode0x20 = Witnet.resultFromCborBytes(hex"D827811820").asErrorCode();
    Witnet.ErrorCodes errorCode0x30 = Witnet.resultFromCborBytes(hex"D827811830").asErrorCode();
    Witnet.ErrorCodes errorCode0x31 = Witnet.resultFromCborBytes(hex"D827811831").asErrorCode();
    Witnet.ErrorCodes errorCode0x40 = Witnet.resultFromCborBytes(hex"D827811840").asErrorCode();
    Witnet.ErrorCodes errorCode0x41 = Witnet.resultFromCborBytes(hex"D827811841").asErrorCode();
    Witnet.ErrorCodes errorCode0x42 = Witnet.resultFromCborBytes(hex"D827811842").asErrorCode();
    Assert.equal(
      uint(errorCode0x00),
      uint(Witnet.ErrorCodes.Unknown),
      "error code `0x00` should be `Witnet.ErrorCodes.Unknown`"
    );
    Assert.equal(
      uint(errorCode0x01),
      uint(Witnet.ErrorCodes.SourceScriptNotCBOR),
      "error code `0x01` should be `Witnet.ErrorCodes.SourceScriptNotCBOR`"
    );
    Assert.equal(
      uint(errorCode0x02),
      uint(Witnet.ErrorCodes.SourceScriptNotArray),
      "error code `0x02` should be `Witnet.ErrorCodes.SourceScriptNotArray`"
    );
    Assert.equal(
      uint(errorCode0x03),
      uint(Witnet.ErrorCodes.SourceScriptNotRADON),
      "error code `0x03` should be `Witnet.ErrorCodes.SourceScriptNotRADON`"
    );
    Assert.equal(
      uint(errorCode0x10),
      uint(Witnet.ErrorCodes.RequestTooManySources),
      "error code `0x10` should be `Witnet.ErrorCodes.RequestTooManySources`"
    );
    Assert.equal(
      uint(errorCode0x11),
      uint(Witnet.ErrorCodes.ScriptTooManyCalls),
      "error code `0x11` should be `Witnet.ErrorCodes.ScriptTooManyCalls`"
    );
    Assert.equal(
      uint(errorCode0x20),
      uint(Witnet.ErrorCodes.UnsupportedOperator),
      "error code `0x20` should be `Witnet.ErrorCodes.UnsupportedOperator`"
    );
    Assert.equal(
      uint(errorCode0x30),
      uint(Witnet.ErrorCodes.HTTP),
      "error code `0x30` should be `Witnet.ErrorCodes.HTTP`"
    );
    Assert.equal(
      uint(errorCode0x31),
      uint(Witnet.ErrorCodes.RetrievalTimeout),
      "Error code 0x31 should be `Witnet.ErrorCodes.RetrievalTimeout`"
    );
    Assert.equal(
      uint(errorCode0x40),
      uint(Witnet.ErrorCodes.Underflow),
      "error code `0x40` should be `Witnet.ErrorCodes.Underflow`"
    );
    Assert.equal(
      uint(errorCode0x41),
      uint(Witnet.ErrorCodes.Overflow),
      "error code `0x41` should be `Witnet.ErrorCodes.Overflow`"
    );
    Assert.equal(
      uint(errorCode0x42),
      uint(Witnet.ErrorCodes.DivisionByZero),
      "Error code #0x42 should be `Witnet.ErrorCodes.DivisionByZero`"
    );
  }

  // Test decoding of `RadonError` error messages
  function testErrorMessages() public {
    (, string memory errorMessage0x00) = Witnet.resultFromCborBytes(hex"D8278100").asErrorMessage();
    (, string memory errorMessage0x01) = Witnet.resultFromCborBytes(hex"D827820102").asErrorMessage();
    (, string memory errorMessage0x02) = Witnet.resultFromCborBytes(hex"D827820203").asErrorMessage();
    (, string memory errorMessage0x03) = Witnet.resultFromCborBytes(hex"D827820304").asErrorMessage();
    (, string memory errorMessage0x10) = Witnet.resultFromCborBytes(hex"D827821005").asErrorMessage();
    (, string memory errorMessage0x11) = Witnet.resultFromCborBytes(hex"D8278411000708").asErrorMessage();
    (, string memory errorMessage0x20) = Witnet.resultFromCborBytes(hex"D8278518200108090A").asErrorMessage();
    (, string memory errorMessage0x30) = Witnet.resultFromCborBytes(hex"D82783183008190141").asErrorMessage();
    (, string memory errorMessage0x31) = Witnet.resultFromCborBytes(hex"D82782183109").asErrorMessage();
    (, string memory errorMessage0x40) = Witnet.resultFromCborBytes(hex"D82785184002090A0B").asErrorMessage();
    (, string memory errorMessage0x41) = Witnet.resultFromCborBytes(hex"D827851841000A0B0C").asErrorMessage();
    (, string memory errorMessage0x42) = Witnet.resultFromCborBytes(hex"D827851842010B0C0D").asErrorMessage();
    (, string memory errorMessage0xFF) = Witnet.resultFromCborBytes(hex"D8278118FF").asErrorMessage();
    Assert.equal(
      errorMessage0x00,
      "Unknown error (0x00)",
      "Error message 0x00 should be properly formatted"
    );
    Assert.equal(
      errorMessage0x01,
      "Source script #2 was not a valid CBOR value",
      "Error message for error code `0x01` (`Witnet.ErrorCodes.SourceScriptNotCBOR`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x02,
      "The CBOR value in script #3 was not an Array of calls",
      "Error message for error code `0x02` (`Witnet.ErrorCodes.SourceScriptNotArray`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x03,
      "The CBOR value in script #4 was not a valid RADON script",
      "Error message for error code `0x03` (`Witnet.ErrorCodes.SourceScriptNotRADON`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x10,
      "The request contained too many sources (5)",
      "Error message for error code `0x10` (`Witnet.ErrorCodes.RequestTooManySources`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x11,
      "Script #7 from the retrieval stage contained too many calls (8)",
      "Error message for error code `0x11` (`Witnet.ErrorCodes.ScriptTooManyCalls`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x20,
      "Operator code 0x0A found at call #9 in script #8 from aggregation stage is not supported",
      "Error message for error code `0x20` (`Witnet.ErrorCodes.UnsupportedOperator`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x30,
      "Source #8 could not be retrieved. Failed with HTTP error code: 321",
      "Error message for error code `0x30` (`Witnet.ErrorCodes.HTTP`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x31,
      "Source #9 could not be retrieved because of a timeout.",
      "Error message for error code `0x31` (`Witnet.ErrorCodes.HTTP`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x40,
      "Underflow at operator code 0x0B found at call #10 in script #9 from tally stage",
      "Error message for error code `0x40` (`Witnet.ErrorCodes.Underflow`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x41,
      "Overflow at operator code 0x0C found at call #11 in script #10 from retrieval stage",
      "Error message for error code `0x41` (`Witnet.ErrorCodes.Overflow`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0x42,
      "Division by zero at operator code 0x0D found at call #12 in script #11 from aggregation stage",
      "Error message for error code `0x42` (`Witnet.ErrorCodes.DivisionByZero`) should be properly formatted"
    );
    Assert.equal(
      errorMessage0xFF,
      "Unknown error (0xFF)",
      "Error message for an unknown error should be properly formatted"
    );
  }
}
