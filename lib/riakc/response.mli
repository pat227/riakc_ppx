open Core.Std

type t =
  | Ping
  | Client_id of string
  | Server_info of (string option * string option)
  | Buckets of string list
  | Keys of (string list * bool)

type error = [ `Bad_payload | `Incomplete_payload | Protobuf.Parser.error ]

val of_string    : string -> (t, [> error ]) Result.t
val parse_length : string -> (int, [> error ]) Result.t
