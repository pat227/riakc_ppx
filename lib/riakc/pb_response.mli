val client_id    : string Protobuf.Parser.t
val server_info  : (string option * string option) Protobuf.Parser.t
val list_buckets : string list Protobuf.Parser.t
val list_keys    : (string list * bool) Protobuf.Parser.t
