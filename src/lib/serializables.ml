module Serializable_class = Serializable_class.Serializable_class
open Serializable_class
(*Originally thought that given any protobuf capable type t -- in its own module -- run it 
 through Converter.Make_serializable_from_protobuf_capable functor 
 and then create either a versioned.t wrapped class or a non-version.t
 wrapped class. Also possible to do this for Yojson or any other 
 encoding scheme. But that doesnt work; forgot we lose all the functions
 of the type t that we might need. Must include the type, and provide 
 the added functions, namely from/to_protobuf and from/to_encoding
 which are built atop from/to_protobuf.*)

module String_pb_capable = 
  struct
    include String
    let to_protobuf t e = Protobuf.Encoder.of_bytes e (Bytes.of_string t)
    let from_protobuf d = Bytes.to_string (Protobuf.Decoder.to_bytes d ())
    let sc = new serializable_from_pb_capable from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module String_pb_capable_versioned = 
  struct
    include String
    let to_protobuf t e = Protobuf.Encoder.of_bytes e (Bytes.of_string t)
    let from_protobuf d = Bytes.to_string (Protobuf.Decoder.to_bytes d ())
    let sc = new protobuf_capable_class_version_wrapped from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Bytes_pb_capable =
  struct
    include Bytes
    let to_protobuf t e = Protobuf.Encoder.bytes t e
    let from_protobuf d = Protobuf.Decoder.bytes d
    let sc = new serializable_from_pb_capable from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Bytes_pb_capable_versioned =
  struct
    include Bytes
    let to_protobuf t e = Protobuf.Encoder.bytes t e
    let from_protobuf d = Protobuf.Decoder.bytes d
    let sc = new protobuf_capable_class_version_wrapped from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
end

module Bool_pb_capable =
  struct
    include Core.Std.Bool
    type bool_t = private bool [@@deriving protobuf]
    let to_protobuf = bool_t_to_protobuf
    let from_protobuf = bool_t_from_protobuf
    let sc = new serializable_from_pb_capable from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Bool_pb_capable_versioned =
  struct
    include Core.Std.Bool
    type bool_t = private bool [@@deriving protobuf]
    let to_protobuf = bool_t_to_protobuf
    let from_protobuf = bool_t_from_protobuf
    let sc = new protobuf_capable_class_version_wrapped from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end
    
module Int_pb_capable =
  struct
    include Core.Std.Int
    let to_protobuf t e = Protobuf.Encoder.varint (Int64.of_int t) e
    let from_protobuf d = Int64.to_int (Protobuf.Decoder.varint d)
    let sc = new serializable_from_pb_capable from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Int_pb_capable_versioned =
  struct
    include Core.Std.Int
    let to_protobuf t e = Protobuf.Encoder.varint (Int64.of_int t) e
    let from_protobuf d = Int64.to_int (Protobuf.Decoder.varint d)
    let sc = new protobuf_capable_class_version_wrapped from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Float_pb_capable =
  struct
    include Core.Std.Float
    type float_t = private float [@@deriving protobuf]
    let to_protobuf = float_t_to_protobuf
    let from_protobuf = float_t_from_protobuf
    let sc = new serializable_from_pb_capable from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Float_pb_capable_versioned =
  struct
    include Core.Std.Float
    type float_t = private float [@@deriving protobuf]
    let to_protobuf = float_t_to_protobuf
    let from_protobuf = float_t_from_protobuf
    let sc = new protobuf_capable_class_version_wrapped from_protobuf to_protobuf
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module String_json_capable = 
  struct
    include String
    type string_t = string [@@deriving yojson]
    let to_yojson = string_t_to_yojson
    let from_yojson = string_t_of_yojson
    let sc = new serializable_from_json_capable from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module String_json_capable_versioned = 
  struct
    include String
    type string_t = string [@@deriving yojson]
    let to_yojson = string_t_to_yojson
    let from_yojson = string_t_of_yojson
    let sc = new serializable_from_json_capable_version_wrapped from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Bytes_json_capable =
  struct
    include Bytes
    type bytes_t = bytes [@@deriving yojson]
    let to_yojson = bytes_t_to_yojson
    let from_yojson = bytes_t_of_yojson
    let sc = new serializable_from_json_capable from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Bytes_json_capable_versioned =
  struct
    include Bytes
    type bytes_t = bytes [@@deriving yojson]
    let to_yojson = bytes_t_to_yojson
    let from_yojson = bytes_t_of_yojson
    let sc = new serializable_from_json_capable_version_wrapped from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
end

module Bool_yojson_capable =
  struct
    include Core.Std.Bool
    type bool_t = bool [@@deriving yojson]
    let to_yojson = bool_t_to_yojson
    let from_yojson = bool_t_of_yojson
    let sc = new serializable_from_json_capable from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Bool_yojson_capable_versioned =
  struct
    include Core.Std.Bool
    type bool_t = bool [@@deriving yojson]
    let to_yojson = bool_t_to_yojson
    let from_yojson = bool_t_of_yojson
    let sc = new serializable_from_json_capable_version_wrapped from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Int_json_capable =
  struct
    include Core.Std.Int
    type int_t = int [@@deriving yojson]
    let to_yojson = int_t_to_yojson
    let from_yojson = int_t_of_yojson
    let sc = new serializable_from_json_capable from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Int_json_capable_versioned =
  struct
    include Core.Std.Int
    type int_t = int [@@deriving yojson]
    let to_yojson = int_t_to_yojson
    let from_yojson = int_t_of_yojson
    let sc = new serializable_from_json_capable_version_wrapped from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end
    
module Float_json_capable =
  struct
    include Core.Std.Float
    type float_t = float [@@deriving yojson]
    let to_yojson = float_t_to_yojson
    let from_yojson = float_t_of_yojson
    let sc = new serializable_from_json_capable from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Float_json_capable_versioned =
  struct
    include Core.Std.Float
    type float_t = float [@@deriving yojson]
    let to_yojson = float_t_to_yojson
    let from_yojson = float_t_of_yojson
    let sc = new serializable_from_json_capable_version_wrapped from_yojson to_yojson
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end
