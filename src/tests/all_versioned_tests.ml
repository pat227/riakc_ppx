open Core.Std
open Async.Std
module Log = Mylogging.Log
module Rconn = Riakc.Conn
module Robj  = Riakc.Robj

open Deferred.Result.Monad_infix

module State = struct
  type t = unit
  let create () = ()
end

(*module String = Protobuf_capables.String*)
module String = Serializables.String_pb_capable
(*module StringCache = Caches.StringCache*)
module StringCache = Caches.String_class_cache
(*module Protobuf_capable = Protobuf_capable*)
module Rand = struct
  let lowercase = "abcdefghijklmnopqrstuvwxyz"
  let alpha     = lowercase ^ String.uppercase lowercase
  let num       = "0123456789"
  let alphanum  = alpha ^ num
  let symbols   = "!@#$%^&*();:<>,.?"
  let all       = alphanum ^ symbols

  let pick_n src len =
    let s   = Bytes.create len in
    let s_l = Bytes.length src in
    for i = 0 to len - 1 do
      Bytes.set s i (Bytes.get src (Random.int s_l))
    done;
    s

  let key n = let bytes = pick_n (Bytes.of_string alpha) n in
  Bytes.to_string bytes
end
  
let assert_cond msg = function
  | true  -> Deferred.return (Ok ())
  | false -> begin
    printf "Error: %s\n" msg;
    Deferred.return (Error `Assert_failed)
  end

let roundtrip_test c =
  let k = "abcdefghij" in
  let serialized_k = StringCache.Key.to_encoding k in
  let deserialized_k = StringCache.Key.from_encoding serialized_k in
  let b1 = Bytes.of_string k in
  let b2 = Bytes.of_string deserialized_k in
  let _ = print_string ("k:" ^ k ^ "  |serialized_k:" ^ serialized_k ^ "  |deserialized_k:" ^ deserialized_k ^ "\n") in
  assert_cond "Roundtrip failed." ((Bytes.compare b1 b2) = 0);;

let ping_test c =
  Rconn.ping (StringCache.get_conn c) >>= fun _ ->
  Deferred.return (Ok ())

let client_id_test c =
  Rconn.client_id (StringCache.get_conn c) >>= fun _ ->
  Deferred.return (Ok ())

let server_info_test c =
  Rconn.server_info (StringCache.get_conn c) >>= fun _ ->
  Deferred.return (Ok ())

let list_buckets_test c =
  Rconn.list_buckets (StringCache.get_conn c) >>= fun _ ->
  Deferred.return (Ok ())

let list_keys_test c =
  StringCache.list_keys c >>= fun keys1 ->
  let robj =
    StringCache.Robj.create
      (StringCache.Robj.Content.create "foobar")
  in
  let randkey = "abcdefghij" in (*Rand.key 10 in*)
  StringCache.put c ~k:randkey robj >>= fun _ ->
  let span = Core.Std.Time.Span.of_int_sec 3 in
  let _ = Core.Std.Time.pause span in
  StringCache.list_keys c >>= fun keys2 ->
  assert_cond
    "Key not added"
    (List.length keys1 = (List.length keys2 - 1))
  >>= fun _ ->
  assert_cond
    "Key not in list"
    (List.mem keys2 randkey)

let get_notfound_test c =
  let open Deferred.Monad_infix in
  StringCache.get c "no_key_here" >>= function
    | Error `Notfound ->
      Deferred.return (Ok ())
    | Error err ->
      Deferred.return (Error err)
    | Ok _ ->
      Deferred.return (Error `Bad_response)

(*let roundtrip_robj c =
  let robj =
    let content = (StringCache.Robj.Content.create "foobar2") in 
    let content_ = StringCace.Content.set_ content_encoding "ascii-utf8" in
    StringCache.Robj.create content_ in
  let _ = print_string (StringCache.Robj.show robj) in
  let putopts = Opts.Put.put_of_opts [] "" "klmnopqrst" robj in
  let pbofput = Opts.Put.put_to_protobuf putopts in
  let _ = printstring pbofput in*)
    
let get_found_test c =
  let robj =
    StringCache.Robj.create
      (StringCache.Robj.Content.create "foobar2") in
  let key = (*"UjtaiBbuNU" Rand.key 10*) "klmnopqrst" in
  StringCache.put c ~k:key robj >>= fun (_, _) ->
  let span = Core.Std.Time.Span.of_int_sec 3 in
  let _ = Core.Std.Time.pause span in
  let _ = print_string "all_tests.ml::get_found_test() resuming from sleep\n" in
  StringCache.get c key >>= fun robj ->
  let _ = print_string ("all_tests.ml::get_found_test() got robj") in (* ^ (Log.hex_of_string (Robj.to_protobuf robj))) in*)
  Deferred.return (Ok ())

let put_return_body_test c =
  let open Opts.Put in
  let module Robj = StringCache.Robj in
  let robj =
    Robj.create
      (Robj.Content.create "foobar3")
  in
  let key = (*Rand.key 10*) "uvwxyz0102" in
  StringCache.put c ~opts:[Return_body] ~k:key robj >>= fun (robj', key) ->
  assert_cond "Key created for unknown reason" (key = None) >>= fun _ ->
  assert_cond
    "Add created sibling"
    (List.length (Robj.contents robj) = List.length (Robj.contents robj'))
(*
let tests = [("roundtrip_test", roundtrip_test)]
 *)
let tests = [ ("roundtrip_test"  , roundtrip_test)
	    ; ("ping"           , ping_test)
	    ; ("client_id"      , client_id_test)
	    ; ("server_info"    , server_info_test)
	    ; ("list_buckets"   , list_buckets_test)
	    ; ("list_keys"      , list_keys_test)
	    ; ("get_notfound"   , get_notfound_test)
	    ; ("get_found"      , get_found_test)
	    ; ("put_return_body", put_return_body_test)
	    ]

let execute_test t =
  let with_cache () =
    StringCache.with_cache
      ~host:Sys.argv.(1)
      ~port:(Int.of_string Sys.argv.(2))
      ~bucket:(Sys.argv.(3))
      (fun cache -> t cache)
  in
  with_cache ()

let rec execute_tests s = function
  | [] -> Deferred.return (shutdown 0)
  | (name, t)::ts -> begin
    let open Deferred.Monad_infix in
    execute_test t >>= function
      | Ok () -> begin
	printf "%s...PASSED\n" name;
	execute_tests s ts
      end
      | Error _ -> begin
	printf "%s...FAILED\n" name;
	execute_tests s ts
      end
  end

let run_tests () =
  execute_tests (State.create ()) tests

let () =
  Random.self_init ();
  ignore (run_tests ());
  never_returns (Scheduler.go ())