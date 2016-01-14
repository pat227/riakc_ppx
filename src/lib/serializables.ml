module Serializable_class = Serializable_class.Serializable_class
open Serializable_class
       
module Bytes_pb_capable =
  struct
    module Bytes_pbcapable = Protobuf_capables.Bytes
    module Bytes_s = Converter.Make_serializable_from_protobuf_capable(Bytes_pbcapable)
    let t = new Serializable_class.serializable_class Bytes_s.from_encoding Bytes_s.to_encoding;;
  end

module Bytes_pb_capable_versioned =
  struct
    module Bytes_pbcapable = Protobuf_capables.Bytes
    module Bytes_s = Converter.Make_serializable_from_protobuf_capable(Bytes_pbcapable)
    let t = new Serializable_class.protobuf_capable_class_version_wrapped Bytes_s.from_encoding Bytes_s.to_encoding;;
end
