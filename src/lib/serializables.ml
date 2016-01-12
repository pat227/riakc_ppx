module Bytes_serializable = struct
  include Protobuf_capables.Bytes
  let c = new Serializable_class.serializable_class to_protobuf from_protobuf;;
end

module Bytes_serializable_versioned = struct
  include Protobuf_capables.Bytes
  let c = new Serializable_class.protobuf_capable_class_version_wrapped to_protobuf from_protobuf;;
end
