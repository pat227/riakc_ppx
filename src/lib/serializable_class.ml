module E = Protobuf.Encoder
module D = Protobuf.Decoder
module Versioned = Versioned.Versioned

module Serializable_class = struct
  (*So long as decode_a and endode_a can do a roundtrip in any encoding scheme
    this class should work for protobuf, json, or any encoding scheme.*)
							      
  class ['a] serializable_class decode_a encode_a = object
    method from_encoding (b:string) : 'a =
      decode_a b
    method to_encoding (v:'a) : string =
      encode_a v
  end

  type 'a t = 'a serializable_class
  (*Ditto as above, but everything is wrapped in a Versioned.Versioned.t struct and then
    the Versioned.Versioned.t struct is encoded using protobuf.*)
  class ['a] protobuf_capable_class_version_wrapped decode_a encode_a = object(self)
    inherit ['a] serializable_class decode_a encode_a
    method private serialize_version version to_protobuf (v:'a) =
      match version with
      | 0 -> to_protobuf v
      | n -> failwith("Unknown serializer protocol version: " ^ (string_of_int n))

    method private serialize_proto (a_to_protobuf : 'a -> string) (v:'a) : string =
      let e = Protobuf.Encoder.create () in 
      let versioned =
	{Versioned.version = Versioned.proto_version; 
	 data = self#serialize_version Versioned.proto_version a_to_protobuf v} in
      (Versioned.to_protobuf versioned e;
       Protobuf.Encoder.to_string e)

    method private deserialize_version version a_from_protobuf b =
      match version with 
      | 0 -> a_from_protobuf b
      | n -> failwith("Unknown deserializer protocol version: " ^ (string_of_int n) ^ "\n")

    method private deserialize_proto (a_from_protobuf : string -> 'a) (b:string) : 'a =
      let open Versioned in
      let d = Protobuf.Decoder.of_string b in 
      let versioned = Versioned.from_protobuf d in
      self#deserialize_version versioned.version a_from_protobuf versioned.data

    method from_encoding (b:string) : 'a =
      self#deserialize_proto decode_a b
    method to_encoding (v:'a) : string =
      self#serialize_proto encode_a v
  end

  class ['a] json_capable_class_version_wrapped decode_a encode_a = object(self)
    inherit ['a] serializable_class decode_a encode_a
    method private deserialize_version version a_from_json b =
      match version with 
      | 0 -> a_from_json b
      | n -> failwith("Unknown deserializer protocol version: " ^ (string_of_int n) ^ "\n")

    method private deserialize_proto (a_from_json : string -> 'a) (b:string) : 'a =
      let versioned = Versioned.of_yojson (Yojson.Safe.from_string b) in
      match versioned with
      | `Ok vd -> self#deserialize_version vd.Versioned.version a_from_json vd.Versioned.data
      | `Error msg -> failwith(msg) 

    method private serialize_version version to_json (v:'a) =
      match version with
      | 0 -> to_json v
      | n -> failwith("Unknown serializer protocol version: " ^ (string_of_int n))

    method private serialize_proto (a_to_json : 'a -> string) (v:'a) : string =
      let versioned =
	{Versioned.version = Versioned.proto_version;
	 data = self#serialize_version Versioned.proto_version encode_a v} in
      let j = Versioned.to_yojson versioned in
      Yojson.Safe.to_string j
			       
    method from_encoding (b:string) : 'a =
      self#deserialize_proto decode_a b
    method to_encoding (v:'a) : string =
      self#serialize_proto encode_a v
  end
end

module Serializable_class2 = struct
  class ['a] serializable_from_pb_capable frompb topb = object
    method from_encoding (b:string) : 'a =
      let d = Protobuf.Decoder.of_string b in
      frompb d
	     
    method to_encoding (v:'a) : string =
      let e = Protobuf.Encoder.create () in 
      topb v e;
      Protobuf.Encoder.to_string e
  end
  type 'a t = 'a serializable_from_pb_capable
		 
(*  class ['a] serializable_of_json_capable fromjson tojson = object
    method from_encoding (b:string) : 'a =
      let open Yojson in
      let j = Yojson.Safe.from_string b in
      let result = fromjson j in
      match result with
      | `Error msg -> failwith (msg)
      | `Ok t -> t
		   
    method to_encoding (v:'a) : string =
      let open Yojson in 
      let j = tojson v in
      Yojson.Safe.to_string j
  end*)
  class ['a] protobuf_capable_class_version_wrapped from_protouf to_protobuf = object(self)
    inherit ['a] serializable_from_pb_capable from_protouf to_protobuf as super
    method private serialize_version version to_protobuf (v:'a) =
      match version with
      | 0 -> to_protobuf v
      | n -> failwith("Unknown serializer protocol version: " ^ (string_of_int n))

    method private serialize_proto (a_to_protobuf : 'a -> string) (v:'a) : string =
      let e = Protobuf.Encoder.create () in 
      let versioned =
	{Versioned.version = Versioned.proto_version; 
	 data = self#serialize_version Versioned.proto_version a_to_protobuf v} in
      (Versioned.to_protobuf versioned e;
       Protobuf.Encoder.to_string e)

    method private deserialize_version version a_from_protobuf b =
      match version with 
      | 0 -> a_from_protobuf b
      | n -> failwith("Unknown deserializer protocol version: " ^ (string_of_int n) ^ "\n")

    method private deserialize_proto (a_from_protobuf : string -> 'a) (b:string) : 'a =
      let open Versioned in
      let d = Protobuf.Decoder.of_string b in 
      let versioned = Versioned.from_protobuf d in
      self#deserialize_version versioned.version a_from_protobuf versioned.data

    method from_encoding (b:string) : 'a =
      self#deserialize_proto super#from_encoding b
    method to_encoding (v:'a) : string =
      self#serialize_proto super#to_encoding v
  end

end
