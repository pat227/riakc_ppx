module Versioned : sig
  type t = {version: int; data:bytes}
  val from_protobuf : Protobuf.Decoder.t -> t
  val to_protobuf   : t -> Protobuf.Encoder.t -> unit
  val proto_version : int
end 
