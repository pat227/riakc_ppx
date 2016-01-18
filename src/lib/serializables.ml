module Serializable_class = Serializable_class.Serializable_class
open Serializable_class
(*Given any protobuf capable type t -- in its own module -- run it 
 through Converter.Make_serializable_from_protobuf_capable functor 
 and then create either a versioned.t wrapped class or a non-version.t
 wrapped class. Also possible to do this for Yojson or any other 
 encoding scheme.*)
module Bytes_pb_capable =
  struct
    module Bytes_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.Bytes)
    type t = Bytes_s.t
    let sc = new serializable_class Bytes_s.from_encoding Bytes_s.to_encoding
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Bytes_pb_capable_versioned =
  struct
    module Bytes_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.Bytes)
    type t = Bytes_s.t
    let sc = new protobuf_capable_class_version_wrapped Bytes_s.from_encoding Bytes_s.to_encoding;;
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
end

module String_pb_capable = 
  struct
    module String_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.String)
    type t = String_s.t
    let sc = new serializable_class String_s.from_encoding String_s.to_encoding
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module String_pb_capable_versioned = 
  struct
    module String_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.String)
    type t = String_s.t
    let sc = new protobuf_capable_class_version_wrapped String_s.from_encoding String_s.to_encoding
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Bool_pb_capable =
  struct
    module Bool_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.Bool)
    type t = Bool_s.t
    let sc = new serializable_class Bool_s.from_encoding Bool_s.to_encoding
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Bool_pb_capable_versioned =
  struct
    module Bool_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.Bool)
    type t = Bool_s.t
    let sc = new protobuf_capable_class_version_wrapped Bool_s.from_encoding Bool_s.to_encoding
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end
    
module Int_pb_capable =
  struct
    module Int_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.Int)
    type t = Int_s.t
    let sc = new serializable_class Int_s.from_encoding Int_s.to_encoding
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Int_pb_capable_versioned =
  struct
    module Int_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.Int)
    type t = Int_s.t
    let sc = new protobuf_capable_class_version_wrapped Int_s.from_encoding Int_s.to_encoding
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Float_pb_capable =
  struct
    module Float_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.Float)
    type t = Float_s.t
    let sc = new serializable_class Float_s.from_encoding Float_s.to_encoding
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end

module Float_pb_capable_versioned =
  struct
    module Float_s = Converter.Make_serializable_from_protobuf_capable(Protobuf_capables.Float)
    type t = Float_s.t
    let sc = new protobuf_capable_class_version_wrapped Float_s.from_encoding Float_s.to_encoding
    let from_encoding (b:string) = sc#from_encoding b
    let to_encoding v = sc#to_encoding v
  end
