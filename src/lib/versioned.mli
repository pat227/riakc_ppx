module Versioned : sig
  type t = {version: int; data:string}
  val from_protobuf : Protobuf.Decoder.t -> t
  val to_protobuf   : t -> Protobuf.Encoder.t -> unit
  val proto_version : int
  val to_yojson : t -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> [ `Error of string | `Ok of t ]
end 
