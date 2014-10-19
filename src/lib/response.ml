module E = Protobuf.Encoder
module D = Protobuf.Decoder

module Result = Core.Std.Result

type error = [ `Bad_payload | `Incomplete_payload | `Protobuf_encoder_error ]

module type Key = sig include Protobuf_capable.S end
module type Value = sig include Protobuf_capable.S end


type 'a t = More of 'a | Done of 'a

open Result

let ping = function
  | "\x02" ->
    Result.Ok (Done ())
  | _ ->
    Error `Bad_payload


type list_buckets = string list [@@deriving Protobuf]
type client_id   = string [@@deriving Protobuf]
type server_info = (string option * string option) [@@deriving Protobuf]
type bucket_props = (int option * bool option) [@@deriving Protobuf]

module Make (Key:Key) (Value:Value) =
struct
module Content = Robj.Content(Key)(Value)
type pair = (Key.t * string option) [@@deriving Protobuf]
type keys = Key.t list [@key 1] [@@deriving Protobuf]
type list_keys    = (keys * bool)  [@@deriving Protobuf]
type get          = (Content.t list * string option * bool option) [@@deriving Protobuf]
type put          = (Content.t list * string option * string option) [@@deriving Protobuf]
type index_search = (keys * pair list * string option * bool option) [@@deriving Protobuf]
end
