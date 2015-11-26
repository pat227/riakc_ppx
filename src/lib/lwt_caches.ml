open Protobuf_capables
module BytesCache = Lwt_cache.Make(Bytes)(Bytes)
module BytesBoolCache = Lwt_cache.Make(Bytes)(Bool)
module BytesIntCache = Lwt_cache.Make(Bytes)(Int)
module IntBytesCache = Lwt_cache.Make(Int)(Bytes)
module IntBoolCache = Lwt_cache.Make(Int)(Bool)
module StringCache = Lwt_cache.Make(String)(String)
module Lwt_StringCache = Lwt_cache.Make(String)(String)
module RawStringKeyCache = Lwt_cache.Make_with_string_key(String)
module StringBoolCache = Lwt_cache.Make(String)(Bool)
module StringIntCache = Lwt_cache.Make(String)(Int)
module StringPrimitiveCache = Lwt_cache.Make_with_string_key(String)

