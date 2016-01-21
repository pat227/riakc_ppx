(*
open Core.Std
open Async.Std

module StringCache = Caches.String_class_cache

let option_to_string =
  Option.value ~default:"<none>"

let hex_of_string =
  String.concat_map ~f:(fun c -> sprintf "%X" (Char.to_int c))

let print_usermeta content =
  let module U = StringCache.Robj.Usermeta in
  List.iter
    ~f:(fun u ->
      printf "USERMETA: %s = %s\n" (U.key u) (option_to_string (U.value u)))
    (StringCache.Robj.Content.usermeta content)
  
let print_indices content = 
  let module I = Cache.Default_index in
  let index_value_to_string = function
    | I.String s  -> "String " ^ s
    | I.Integer i -> "Integer " ^ (Int.to_string i)
    | I.Bad_int s -> "Bad_int " ^ s
    | I.Unknown s -> "Unknown " ^ s
  in
  List.iter
    ~f:(fun i ->
      printf "INDEX: %s = %s\n" (StringCache.Robj.Index.key i) 
      (option_to_string (Option.map (StringCache.Robj.Index.value i) index_value_to_string)))
    (StringCache.Robj.Content.indices content)

let print_value content =
  let value = StringCache.Robj.Content.value content in
  List.iter
    ~f:(printf "CONTENT: %s\n")
    (String.split ~on:'\n' value)

let print_contents =
  List.iter
    ~f:(fun content ->
      let module C = StringCache.Robj.Content in
      printf "CONTENT_TYPE: %s\n" (option_to_string (C.content_type content));
      printf "CHARSET: %s\n" (option_to_string (C.charset content));
      printf "CONTENT_ENCODING: %s\n" (option_to_string (C.content_encoding content));
      print_usermeta content;
      print_indices content;
      print_value content)

let fail s =
  printf "%s\n" s;
  shutdown 1

let parse_index s = 
  let module R = StringCache.Robj in
  match String.lsplit2 ~on:':' s with
    | Some ("bin", kv) -> begin
      match String.lsplit2 ~on:':' kv with
	| Some (k, v) ->
	  R.Index.create ~k ~v:(Some (Cache.Default_index.String v))
	| None ->
	  failwith ("Bad index: " ^ s)
    end
    | Some ("int", kv) -> begin
      match String.lsplit2 ~on:':' kv with
	| Some (k, v) ->
	  R.Index.create ~k ~v:(Some (Cache.Default_index.Integer (Int.of_string v)))
	| None ->
	  failwith ("Bad index: " ^ s)
    end
    | _ ->
      failwith ("Bad index: " ^ s)

let rec add_2i r idx = 
  if idx < Array.length Sys.argv then
    let module R = StringCache.Robj in
    let content = List.hd_exn (R.contents r) in
    let indices = R.Content.indices content in
    add_2i
      (R.set_content
	 (R.Content.set_indices
	    ((parse_index Sys.argv.(idx))::indices)
	    content)
	 r)
      (idx + 1)
  else
    r

let exec () =
  let host = Sys.argv.(1) in
  let port = Int.of_string Sys.argv.(2) in
  let b    = Sys.argv.(3) in
  let k    = Sys.argv.(4) in
  let v    = Sys.argv.(5) in
  StringCache.with_cache
    ~host
    ~port
    ~bucket:b
    (fun c ->
      let module R = StringCache.Robj in
      let robj = R.create (R.Content.create v) in
      let robj = add_2i robj 6 in 
      StringCache.put c ~k ~opts:[Opts.Put.Return_body] robj)

let eval () =
  exec () >>| function
    | Ok (robj, _) -> begin
      let module R = StringCache.Robj in
      let vclock =
	match R.vclock robj with
	  | Some v ->
	    hex_of_string v
	  | None ->
	    "<none>"
      in
      printf "VCLOCK: %s\n" vclock;
      print_contents (R.contents robj);
      shutdown 0
    end
    | Error `Bad_conn           -> fail "Bad_conn"
    | Error `Bad_payload        -> fail "Bad_payload"
    | Error `Incomplete_payload -> fail "Incomplete_payload"
    | Error `Notfound           -> fail "Notfound"
    | Error `Incomplete         -> fail "Incomplete"
    | Error `Overflow           -> fail "Overflow"
    | Error `Unknown_type       -> fail "Unknown_type"
    | Error `Wrong_type         -> fail "Wrong_type"
    | Error `Protobuf_encoder_error         -> fail "Protobuf_encoder_error"


let () =
  ignore (eval ());
  never_returns (Scheduler.go ())
 *)
