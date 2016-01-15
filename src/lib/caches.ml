open Protobuf_capables
module BytesCache = Cache.Make(Bytes)(Bytes)
module BytesBoolCache = Cache.Make(Bytes)(Bool)
module BytesIntCache = Cache.Make(Bytes)(Int)
module IntBytesCache = Cache.Make(Int)(Bytes)
module IntBoolCache = Cache.Make(Int)(Bool)
module StringCache = Cache.Make(String)(String)
module StringBoolCache = Cache.Make(String)(Bool)
module StringIntCache = Cache.Make(String)(Int)

module Bytes_class = Cache_classes.Make(Converter.Make_serializable_from_protobuf_capable(Bytes))(Converter.Make_serializable_from_protobuf_capable(Bytes))
