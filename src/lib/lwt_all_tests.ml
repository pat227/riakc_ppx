open Core.Std
open Lwt
open Lwt_log
open Lwt_riakc
module Rconn = Lwt_riakc.Lwt_Conn
module Robj  = Lwt_riakc.Robj
module State = struct
  type t = unit
  let create () = ()
end

module String = Lwt_riakc.Lwt_Cache.String
(*module StringCache = Lwt_riakc.Lwt_Cache.StringCache*)
module StringCache = Lwt_riakc.Lwt_Cache.Make_with_string_key(String)
let lwt_logger = Lwt_log.file ~mode:`Truncate ~file_name:"lwt_all_tests_log";;
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
  | true  -> Lwt.return (Core.Std.Result.Ok ())
  | false -> Lwt.return(Ok(printf "Error: %s\n" msg)) >>=
	       fun _ -> lwt_logger () >>=
	       fun l -> Lwt_log.log ~logger:l ~level:Lwt_log.Debug ("Error: " ^ msg) >|=
	       fun () -> Core.Std.Result.Error `Assert_failed

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
				    (StringCache.Robj.Content.create "foobar")
				in
				StringCache.put c ~k:(Rand.key 10) robj >>= fun _ ->
				StringCache.list_keys c >>= function
							  | Ok(keys2) ->
							     (assert_cond
								"Key not added"
								(List.length keys1 = (List.length keys2 - 1))
							      >>= fun _ ->
							      assert_cond
								"Key not in list"
								(List.mem keys2 "foobar")
							     )
							  | Core.Std.Result.Error err -> assert_cond "Failed to list keys index 74" false
			       )
			    | Core.Std.Result.Error err -> assert_cond "Failed to list keys index 76" false

let get_notfound_test c =
  StringCache.get c "no_key_here" >>= function
    | Core.Std.Result.Error `Notfound ->
      Lwt.return (Ok ())
    | Core.Std.Result.Error err ->
      Lwt.return (Core.Std.Result.Error err)
    | Ok _ ->
      Lwt.return (Core.Std.Result.Error `Bad_response)

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
				  | Core.Std.Result.Error err -> assert_cond "Failed get_found_test index 97" false

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
    | Core.Std.Result.Error err -> assert_cond "Failed put_return_body_test index 114" false

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

let rec execute_tests s =
  match s with 
  | [] -> begin
	  printf "Finished list of tests\n";
	  Lwt.return (printf "Finished list of tests\n")
	end
  | (name, t)::ts ->
     begin
       printf "Doing a test\n";
       execute_test t >>=
	 (function
	   | Ok () -> begin
		      printf "%s...PASSED\n" name;
		      execute_tests ts
		    end
	   | Core.Std.Result.Error _ -> begin
					printf "%s...FAILED\n" name;
					execute_tests ts
				      end)
     end

let run_tests tests =
  printf "run_tests\n";
  execute_tests tests
		
let () =
  Random.self_init ();
  Lwt_main.run (Lwt.join
		  [
		    Lwt.return(printf "Starting tests\n");
		    run_tests tests;
		  ]);
  (*Lwt_main.run (Lwt.return(printf "test"));*)
  
