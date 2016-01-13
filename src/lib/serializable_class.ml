module E = Protobuf.Encoder
module D = Protobuf.Decoder
module Versioned = Versioned.Versioned

module Serializable_class = struct
  
  class ['a] serializable_class decode_a encode_a = object
    method from_encoding (b:string) : 'a =
      decode_a b
    method to_encoding (v:'a) : string =
      encode_a v
  end
  type 'a t = 'a serializable_class  

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

end
