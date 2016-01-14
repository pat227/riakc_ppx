module Serializable_class = Serializable_class.Serializable_class
open Serializable_class
       
module Bytes_pb_capable =
  struct
    module Bytes_pbcapable = Protobuf_capables.Bytes
    module Bytes_s = Converter.Make_serializable_from_protobuf_capable(Bytes_pbcapable)
    let t = new serializable_class Bytes_s.from_encoding Bytes_s.to_encoding;;
  end

module Bytes_pb_capable_versioned =
  struct
    module Bytes_pbcapable = Protobuf_capables.Bytes
    module Bytes_s = Converter.Make_serializable_from_protobuf_capable(Bytes_pbcapable)
    let t = new protobuf_capable_class_version_wrapped Bytes_s.from_encoding Bytes_s.to_encoding;;
end

module String_pb_capable = 
  struct
    module String_pbcapable = Protobuf_capables.String
    module String_s = Converter.Make_serializable_from_protobuf_capable(String_pbcapable)
    let t = new serializable_class String_s.from_encoding String_s.to_encoding
  end

module String_pb_capable_versioned = 
  struct
    module String_pbcapable = Protobuf_capables.String
    module String_s = Converter.Make_serializable_from_protobuf_capable(String_pbcapable)
    let t = new protobuf_capable_class_version_wrapped String_s.from_encoding String_s.to_encoding
  end

module Bool_pb_capable =
  struct
    module Bool = Protobuf_capables.Bool
    module Bool_s = Converter.Make_serializable_from_protobuf_capable(Bool)
    let t = new serializable_class Bool_s.from_encoding Bool_s.to_encoding
  end

module Bool_pb_capable_versioned =
  struct
    module Bool = Protobuf_capables.Bool
    module Bool_s = Converter.Make_serializable_from_protobuf_capable(Bool)
    let t = new protobuf_capable_class_version_wrapped Bool_s.from_encoding Bool_s.to_encoding
  end
    
module Int_pb_capable =
  struct
    module Int = Protobuf_capables.Int
    module Int_s = Converter.Make_serializable_from_protobuf_capable(Int)
    let t = new serializable_class Int_s.from_encoding Int_s.to_encoding
  end

module Int_pb_capable_versioned =
  struct
    module Int = Protobuf_capables.Int
    module Int_s = Converter.Make_serializable_from_protobuf_capable(Int)
    let t = new protobuf_capable_class_version_wrapped Int_s.from_encoding Int_s.to_encoding
  end

module Float_pb_capable =
  struct
    module Float = Protobuf_capables.Float
    module Float_s = Converter.Make_serializable_from_protobuf_capable(Float)
    let t = new serializable_class Float_s.from_encoding Float_s.to_encoding
  end
    
module Float_pb_capable_versioned =
  struct
    module Float = Protobuf_capables.Float
    module Float_s = Converter.Make_serializable_from_protobuf_capable(Float)
    let t = new protobuf_capable_class_version_wrapped Float_s.from_encoding Float_s.to_encoding
  end
