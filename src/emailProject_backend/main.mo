import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Cycles "mo:base/ExperimentalCycles";
import MgtCanisterTypes "mgt_canister.types";

actor {

  let ic : MgtCanisterTypes.IC = actor ("aaaaa-aa");

  func generateUUID() : Text {
    "UUID-123456789";
  };

  public func sendEmailNotification(receiver : Text, email : Text) : async Text {

    let url = "https://ic-netlify-functions.netlify.app/.netlify/functions/icpEmailApp";

    let idempotency_key : Text = generateUUID();
    let request_headers = [
      { name = "Content-Type"; value = "application/json" },
      { name = "Idempotency-Key"; value = idempotency_key }

    ];

    let requestBodyJson : Text = "{ \"idempotencyKey\": \"" # idempotency_key # "\", \"recipientEmail\": \"" # email # "\", \"toName\": \"" # receiver # "\"}";
    let requestBodyAsBlob : Blob = Text.encodeUtf8(requestBodyJson);
    let requestBodyAsNat8 : [Nat8] = Blob.toArray(requestBodyAsBlob);

    let http_request : MgtCanisterTypes.HttpRequestArgs = {
      url = url;
      max_response_bytes = null; //optional for request
      headers = request_headers;
      body = ?requestBodyAsNat8;
      method = #post;
      transform = null; //optional for request
    };

    Cycles.add(220_131_200_000); //minimum cycles needed to pass the CI tests. Cycles needed will vary on many things size of http response, subnetc, etc...).
    let http_response : MgtCanisterTypes.HttpResponsePayload = await ic.http_request(http_request);

    let response_body : Blob = Blob.fromArray(http_response.body);
    let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };
    return decoded_text;
  };

};
