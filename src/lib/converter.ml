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
