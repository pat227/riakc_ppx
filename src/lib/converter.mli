module type Protobf_capable =
  sig
    type t
    val from_protobuf : Protobuf.Decoder.t -> t
    val to_protobuf : t -> Protobuf.Encoder.t -> unit
  end

module type Json_capable =
  sig
    type t 
    val to_yojson : t -> Yojson.Safe.json
    val of_yojson : Yojson.Safe.json -> [ `Error of string | `Ok of t ]
  end

module type Serializable =
  sig
    type t
    val from_encoding : string -> t
    val to_encoding : t -> string
  end

module Make_serializable_from_protobuf_capable :
functor
  (M:Protobf_capable) -> Serializable
							
module Make_serializable_from_yojson_capable :
functor
  (M:Json_capable) -> Serializable 

