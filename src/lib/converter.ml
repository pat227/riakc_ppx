module Versioned = Versioned.Versioned
module Serializable_class = Serializable_class.Serializable_class
open Serializable_class
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

module Make_serializable_from_protobuf_capable
	 (M:Protobf_capable) = struct
  type t = M.t
  let from_encoding (b:string) =
    let d = Protobuf.Decoder.of_string b in
    M.from_protobuf d;;
  let to_encoding t =
    let e = Protobuf.Encoder.create () in 
    M.to_protobuf t e;
    Protobuf.Encoder.to_string e;;
end

module Make_serializable_from_yojson_capable
	 (M:Json_capable) = struct
  type t = M.t
  let from_encoding (b:string)  =
    let open Yojson in
    let j = Yojson.Safe.from_string b in
    let result = M.of_yojson j in
    match result with
    | `Error msg -> failwith (msg)
    | `Ok t -> t
		 
  let to_encoding t  =
    let open Yojson in 
    let j = M.to_yojson t in
    Yojson.Safe.to_string j
end

module Make_serializable_from_protobuf_capable_version_wrapped
	 (M:Protobf_capable) = struct
  
end

(*Syntactically heavier use of functor*)
module Make_serializable_from_protobuf_capable_version_wrapped2
	 (M:Protobf_capable) = struct

  let serialize_version version to_protobuf (v:'a) =
    let e = Protobuf.Encoder.create () in
    match version with
    | 0 -> let _ = to_protobuf v e in Protobuf.Encoder.to_string e
    | n -> failwith("Unknown serializer protocol version: " ^ (string_of_int n))
		   
  let serialize_proto (a_to_protobuf : 'a -> Protobuf.Encoder.t -> unit) (v:'a) : string =
    let e = Protobuf.Encoder.create () in 
    let versioned =
      {Versioned.version = Versioned.proto_version; 
       data = serialize_version Versioned.proto_version a_to_protobuf v} in
    (Versioned.to_protobuf versioned e;
     Protobuf.Encoder.to_string e)

  let deserialize_version version a_from_protobuf b =
    match version with 
    | 0 -> let d = Protobuf.Decoder.of_string b in a_from_protobuf d
    | n -> failwith("Unknown deserializer protocol version: " ^ (string_of_int n) ^ "\n")
		   
  let deserialize_proto (a_from_protobuf : Protobuf.Decoder.t -> 'a) (b:string) : 'a =
    let open Versioned in
    let d = Protobuf.Decoder.of_string b in 
    let versioned = Versioned.from_protobuf d in
    deserialize_version versioned.version a_from_protobuf versioned.data
			
  let from_encoding (b:string) : 'a =
    deserialize_proto M.from_protobuf b
  let to_encoding (v:'a) : string =
    serialize_proto M.to_protobuf v
end
