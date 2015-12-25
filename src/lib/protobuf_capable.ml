module Log = Mylogging.Log
module E = Protobuf.Encoder
module D = Protobuf.Decoder

module type S =
  sig
    type t
    val from_protobuf : D.t -> t
    val to_protobuf : t -> E.t -> unit
  end
(*
module type Raw_S =
  sig
    type t
    val to_string : t -> string
    val of_string : string -> t
  end
 *)
(* The internal protocol version *)
let proto_version = 0

let encode_decode (b:string) =
  let tnow = Core.Std.Time.now () in
  let ts = Core.Std.Time.to_string_abs ~zone:(Core.Std.Time.Zone.of_utc_offset 0) tnow in
  let e = Protobuf.Encoder.create () in
  Protobuf.Encoder.bytes (Bytes.of_string b) e;
  print_string (ts ^ "protobuf_capable.ml::encode_decode input:" ^ (Log.hex_of_string b) ^ " output:" ^ (Log.hex_of_string  (Protobuf.Encoder.to_string e)) ^ "\n");
  Protobuf.Encoder.to_string e

type versioned = {version: int [@key 1]; data:string [@key 2]} [@@deriving protobuf]

let serialize_version version to_protobuf (v:'a) =
  let e = Protobuf.Encoder.create () in
  match version with
  | 0 -> to_protobuf v e;
	 Protobuf.Encoder.to_string e
  | n -> failwith("Unknown serializer protocol version: " ^ (string_of_int n))
		 
let serialize_proto (to_protobuf : 'a -> Protobuf.Encoder.t -> unit) (v:'a) : string =
  let tnow = Core.Std.Time.now () in
  let ts = Core.Std.Time.to_string_abs ~zone:(Core.Std.Time.Zone.of_utc_offset 0) tnow in
  let e = Protobuf.Encoder.create () in 
  let versioned = {version=proto_version; 
		   data=serialize_version proto_version to_protobuf v} in
  (versioned_to_protobuf versioned e;
   print_string (ts ^ "protobuf_capable.ml::serialize_proto() " ^ ((Log.hex_of_string (Protobuf.Encoder.to_string e))) ^ "\n");
   Protobuf.Encoder.to_string e);;

let deserialize_version version from_protobuf b =
  let tnow = Core.Std.Time.now () in
  let ts = Core.Std.Time.to_string_abs ~zone:(Core.Std.Time.Zone.of_utc_offset 0) tnow in
     match version with 
     | 0 -> let _ = print_string (ts ^ "protobuf_capable.ml::deserialize_version() " ^ (Log.hex_of_string b) ^ "\n") in
	    let d = Protobuf.Decoder.of_string b in from_protobuf d
     | n -> failwith(ts ^ "Unknown deserializer protocol version: " ^ (string_of_int n) ^ "\n")

let deserialize_proto (from_protobuf:Protobuf.Decoder.t -> 'a) (b:string) : 'a =
  let tnow = Core.Std.Time.now () in
  let ts = Core.Std.Time.to_string_abs ~zone:(Core.Std.Time.Zone.of_utc_offset 0) tnow in 
  let _ = print_string (ts ^ "protobuf_capable.ml::deserialize_proto() " ^ (Log.hex_of_string  b) ^ "\n") in 
  let d = Protobuf.Decoder.of_string b in 
  let versioned = versioned_from_protobuf d in
  deserialize_version versioned.version from_protobuf versioned.data
(*
module Conversion =
  struct
    module Make(S:S) =
      struct
        type t = S.t
        let to_string t = serialize_proto S.to_protobuf t
        let of_string (s:string) =
	  let tnow = Core.Std.Time.now () in
	  let ts = Core.Std.Time.to_string_abs ~zone:(Core.Std.Time.Zone.of_utc_offset 0) tnow in
	  let _ = print_string (ts ^ "failing with nyi; s:" ^ Log.hex_of_string s ^ "\n")
	  in failwith("nyi")
      end
  end
 *)
