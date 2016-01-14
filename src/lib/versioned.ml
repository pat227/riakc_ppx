module Versioned = struct
  let proto_version = 0
  type t = {version: int [@key 1]; data:string [@key 2]} [@@deriving protobuf,yojson]
end
