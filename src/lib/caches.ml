open Serializables
(*
open Protobuf_capables
module BytesCache = Cache.Make(Bytes)(Bytes)
module BytesBoolCache = Cache.Make(Bytes)(Bool)
module BytesIntCache = Cache.Make(Bytes)(Int)
module IntBytesCache = Cache.Make(Int)(Bytes)
module IntBoolCache = Cache.Make(Int)(Bool)
module StringCache = Cache.Make(String)(String)
module StringBoolCache = Cache.Make(String)(Bool)
module StringIntCache = Cache.Make(String)(Int)
 *)
(*
module Bytes_class_cache = Cache_classes.Make(Bytes_pb_capable)(Bytes_pb_capable)
module BytesBool_class_cache = Cache_classes.Make(Bytes_pb_capable)(Bool_pb_capable)
module BytesInt_class_cache = Cache_classes.Make(Bytes_pb_capable)(Int_pb_capable)
module IntBytes_class_cache = Cache_classes.Make(Int_pb_capable)(Bytes_pb_capable)
module IntBool_class_cache = Cache_classes.Make(Int_pb_capable)(Bool_pb_capable)
 *)
module String_class_cache = Cache_classes.Make(String_pb_capable)(String_pb_capable)
(*module StringBool_class_cache = Cache_classes.Make(String_pb_capable)(Bool_pb_capable)
module StringInt_class_cache = Cache_classes.Make(String_pb_capable)(Int_pb_capable)

module Bytes_class_versioned_cache = Cache_classes.Make(Bytes_pb_capable_versioned)(Bytes_pb_capable_versioned)
module BytesBool_class_versioned_cache = Cache_classes.Make(Bytes_pb_capable_versioned)(Bool_pb_capable_versioned)
module BytesInt_class_versioned_cache = Cache_classes.Make(Bytes_pb_capable_versioned)(Int_pb_capable_versioned)
module IntBytes_class_versioned_cache = Cache_classes.Make(Int_pb_capable_versioned)(Bytes_pb_capable_versioned)
module IntBool_class_versioned_cache = Cache_classes.Make(Int_pb_capable_versioned)(Bool_pb_capable_versioned)
 *)
module String_class_versioned_cache = Cache_classes.Make(String_pb_capable_versioned)(String_pb_capable_versioned)
(*
module StringBool_class_versioned_cache = Cache_classes.Make(String_pb_capable_versioned)(Bool_pb_capable_versioned)
module StringInt_class_versioned_cache = Cache_classes.Make(String_pb_capable_versioned)(Int_pb_capable_versioned)
 *)
