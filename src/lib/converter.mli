module type Protobuf_capable =
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
    val from_encoding : bytes -> t
    val to_encoding : t -> bytes
  end

module Make_serializable_from_protobuf_capable : functor
  (M:Protobuf_capable) -> Serializable with type t := M.t
    
module Make_serializable_from_yojson_capable(M:Json_capable) : functor
  (M:Json_capable) -> Serializable with type t := M.t

