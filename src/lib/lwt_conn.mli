open Core.Std
open Lwt

type t

type error = [ `Bad_conn ]

val connect   : host:string -> port:int -> (t, [> error ]) Result.t Lwt.t
val close     : t -> (unit, [> error ]) Result.t Lwt.t

val with_conn :
  host:string ->
  port:int ->
  (t -> ('a, [> error ] as 'e) Result.t Lwt.t) ->
  ('a, 'e) Result.t Lwt.t

val ping        : t -> (unit, [> error | Response.error ]) Result.t Lwt.t
val client_id   : t -> (string, [> error | Response.error ]) Result.t Lwt.t
val server_info : 
  t ->
  ((string option * string option), [> error | Response.error ]) Result.t Lwt.t

val bucket_props : t -> string -> (Response.Props.t, [> error | Response.error ]) Result.t Lwt.t
val list_buckets : t -> (string list, [> error | Response.error ]) Result.t Lwt.t

val list_keys :
  t ->
  string ->
  (string list, [> error | Response.error ]) Result.t Lwt.t

val list_keys_stream :
  t ->
  string ->
  (string list -> unit Lwt.t) ->
  (unit, [> error | Response.error ]) Result.t Lwt.t

val get :
  t ->
  ?opts:Opts.Get.t list ->
  b:string ->
  string ->
  ([ `Maybe_siblings ] Robj.t, [> Opts.Get.error ]) Result.t Lwt.t

val put :
  t ->
  ?opts:Opts.Put.t list ->
  b:string ->
  ?k:string ->
  [ `No_siblings ] Robj.t ->
  (([ `Maybe_siblings ] Robj.t * string option), [> Opts.Put.error ]) Result.t Lwt.t

val delete :
  t ->
  ?opts:Opts.Delete.t list ->
  b:string ->
  string ->
  (unit, [> Opts.Delete.error ]) Result.t Lwt.t

val purge :
  t ->
  b:string ->
  (unit, [>Opts.Delete.error]) Result.t Lwt.t

val index_search :
  t ->
  ?opts:Opts.Index_search.t list ->
  b:string ->
  index:string ->
  Opts.Index_search.Query.t ->
  (Response.Index_search.t, [> Opts.Index_search.error ]) Result.t Lwt.t
