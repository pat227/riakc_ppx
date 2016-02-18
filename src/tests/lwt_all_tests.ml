open Core.Std
open Lwt
open Lwt_riakc
module Rconn = Lwt_riakc.Lwt_Conn
module Robj  = Lwt_riakc.Robj
module State = struct
  type t = unit
  let create () = ()
end

module String = Serializables.String_raw
module StringCache = Lwt_caches.String_rawkey_class_cache

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
  | true  -> Lwt.return (Ok ())
  | false -> begin
    printf "Error: %s\n" msg;
    Lwt.return (Error `Assert_failed)
  end

let ping_test c =
  Rconn.ping (StringCache.get_conn c) >|= fun _ -> Ok ()

let client_id_test c =
  Rconn.client_id (StringCache.get_conn c) >>= fun _ ->
  Lwt.return (Ok ())

let server_info_test c =
  Rconn.server_info (StringCache.get_conn c) >>= fun _ ->
  Lwt.return (Ok ())

let list_buckets_test c =
  Rconn.list_buckets (StringCache.get_conn c) >>= fun _ ->
  Lwt.return (Ok ())

let list_keys_test c =
  StringCache.list_keys c >>= function
			    | Ok(keys1) ->
			       (let robj =
				  StringCache.Robj.create
				    (StringCache.Robj.Content.create "lisk_keys_test")
				in
				let random_key = (Rand.key 10) in
				StringCache.put c ~k: random_key robj >>= fun _ ->
				StringCache.list_keys c >>= function
							  | Ok(keys2) ->
							     (assert_cond
								"Key not added"
								(List.length keys1 = (List.length keys2 - 1))
							      >>= fun _ ->
							      assert_cond
								"Key not in list"
								(List.mem keys2 random_key)
							     )
							  | Error err -> assert_cond "Failed to list keys index 74" false
			       )
			    | Error err -> assert_cond "Failed to list keys index 76" false

let get_notfound_test c =
  StringCache.get c "no_key_here" >>= function
    | Error `Notfound ->
      Lwt.return (Ok ())
    | Error err ->
      Lwt.return (Error err)
    | Ok _ ->
      Lwt.return (Error `Bad_response)

let get_found_test c =
  let robj =
    StringCache.Robj.create
      (StringCache.Robj.Content.create "foobar")
  in
  let key = Rand.key 10 in
  StringCache.put c ~k:key robj >>= function
				  | Ok (_, _) ->
				     (StringCache.get c key         >>= fun robj ->
				      Lwt.return (Ok ()))
				  | Error err -> assert_cond "Failed get_found_test index 97" false
						
let put_return_body_test c =
  let open Opts.Put in
  let module Robj = StringCache.Robj in
  let robj =
    Robj.create
      (Robj.Content.create "foobar")
  in
  let key = Rand.key 10 in
  StringCache.put c ~opts:[Return_body] ~k:key robj >>=
    function
    | Ok (robj', key) ->
       (assert_cond "Key created for unknown reason" (key = None) >>= fun _ ->
	assert_cond
	  "Add created sibling"
	  (List.length (Robj.contents robj) = List.length (Robj.contents robj')))
    | Error err -> assert_cond "Failed put_return_body_test index 114" false

let tests = [ ("ping"           , ping_test)
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
  | [] -> Lwt.return ()
  | (name, t)::ts ->
     begin
       execute_test t >>=
	 (function
	   | Ok () -> begin
		      printf "%s...PASSED\n" name;
		      execute_tests s ts
		    end
	   | Error _ -> begin
			printf "%s...FAILED\n" name;
			execute_tests s ts
		      end)
     end

let run_tests () =
  execute_tests (State.create ()) tests

let () =
  Random.self_init ();
  Lwt_main.run (run_tests ());
  
