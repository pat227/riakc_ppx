open Core.Std
open Lwt
module String = Core.Std.String

type t = { r : Lwt_io.input_channel
	 ; w : Lwt_io.output_channel
	 }
type error = [ `Bad_conn ]
(*Unclear to me if testing for zero first is correct. How does a pipe 
behave exactly? Can read_into return 0 upon finding nothing in the pipe
yet we're not done reading? Or is calling read_into repeatedly correct
until we get the expected number of bytes.*)
let rec read_str r pos len s = 
  Lwt_io.read_into r s pos len >>= fun l ->
  if l = 0 then
    Lwt.return (Error `Bad_conn)
  else if (pos + l) <> Bytes.length s then
    read_str r (pos + l) (len - l) s
  else
    Lwt.return (Ok s)

let parse_length preamble =
  Lwt.return (Response.parse_length preamble)

let read_payload r preamble =
  parse_length (Bytes.to_string preamble) >>= fun resp_len ->
  match resp_len with
  | Ok resp_length -> let payload = Bytes.create resp_length in
		      read_str r 0 resp_length payload
  | Error `Overflow | Error `Bad_payload | Error `Incomplete_payload |
  Error `Protobuf_encoder_error | Error `Unknown_type |
  Error `Wrong_type | Error `Overflow -> Lwt.return(Error `Overflow)

let rec read_response r f acc =
  let preamble = Bytes.create 4 in
  read_str r 0 4 preamble >>=
    function
    | Ok pre -> read_payload r pre >>=
		  (function
		    | Ok pay_load -> Lwt.return (f (Bytes.to_string pay_load)) >>=
				       (function
					 | Ok (Response.More resp) ->
					    read_response r f (List.append acc [resp])
					 | Ok (Response.Done resp) ->
					    Lwt.return (Ok (List.append acc [resp]))
					 | Error _ -> Lwt.fail_with "Failed to parse response."
				       )		    
		    | Error err -> Lwt.fail_with "Could not read payload."
		  )
    | Error err -> Lwt.fail_with "Could not read preamble."

let do_request_stream t accum g f =
  Lwt.return (g ()) >>=
    function
    | Ok (request) ->
       Lwt_io.write t.w request;
       read_response t.r f accum
    | Error _ -> Lwt.return(Error `Bad_conn) (*IMPOSSIBLE--see request.ml...cannot fail*)
		
(*
Appears async pipes delimit inputs internally by means of a queue? And lwt pipes
do not? How are we going to get back list of inputs if it all runs together?
Turns out lwt_io.write_line and lwt_io.read_lines behaves in similar manner, 
but uses \n to delimit lines and if \n occurs in the data, we get spurious empty 
list elements.
So we could use write_line and Lwt_stream.get_available or read_lines. Lwt_io.read 
requires the pipe to be closed and runs everything together. Perhaps it would be 
best to use a plain old list here since it would be assured to keep response 
elements seperate and no chance a newline within a response element could cause 
problems.
  *)		
let do_request t g f =
  (*let (ic, oc) = Lwt_io.pipe () in
  let c x = Lwt_io.write oc x; Lwt.return () in*)
  do_request_stream t [] g f >>=
    function
    | Ok (l) -> Lwt.return (Ok l)
    | Error err ->
       Lwt.return (Error err)

let connect ~host ~port =
  let connect () =
    Lwt.catch
      (fun () ->
       ((Lwt_io.open_connection
	   (Unix.ADDR_INET
	      ((Core.Std.Unix.Inet_addr.of_string host), port))
	) >>= (function (r,w) -> Lwt.return (Ok (r,w))))
      )
      (function _ -> Lwt.return (Error `Bad_conn))
  in
  connect () >|= function
	       | Ok (r, w) -> Ok { r; w }
	       | Error err -> Error err

let close t =
  Lwt_io.close t.w >>= fun () ->
  Lwt.return (Ok ())

let with_conn ~host ~port f =
  connect host port >>= function
    | Ok c -> begin
      f c >>= fun r ->
      close c >>= fun _ ->
      Lwt.return r
    end
    | Error err ->
       Lwt.return (Error err)

let ping t =
  do_request
    t
    Request.ping
    Response.ping
  >|= function
    | Ok [()] ->
      Ok ()
    | Ok _ ->
      Error `Wrong_type
    | Error err ->
      Error err

let client_id t =
  do_request
    t
    Request.client_id
    Response.client_id
  >|= function
    | Ok [client_id] ->
      Ok client_id
    | Ok _ ->
      Error `Wrong_type
    | Error err ->
      Error err

let server_info t =
  do_request
    t
    Request.server_info
    Response.server_info
  >|= function
    | Ok [(node, version)] ->
      Ok (node, version)
    | Ok _ ->
      Error `Wrong_type
    | Error err ->
      Error err

let bucket_props t bucket =
  do_request
    t
    (Request.bucket_props bucket)
    Response.bucket_props
  >|= function
    | Ok [props] ->
      Ok props
    | Ok _ ->
      Error `Wrong_type
    | Error err ->
      Error err

let list_buckets t =
  do_request
    t
    Request.list_buckets
    Response.list_buckets
  >|= function
      Ok [buckets] ->
      Ok buckets
    | Ok _ ->
      Error `Wrong_type
    | Error err ->
      Error err


let list_keys_stream t bucket consumer =
  do_request_stream
    t
    consumer
    (Request.list_keys bucket)
    Response.list_keys

let list_keys t bucket =
  do_request
    t
    (Request.list_keys bucket)
    Response.list_keys
  >|= function
    | Ok keys -> 
      Ok (List.concat keys)
    | Error err ->
      Error err

let get t ?(opts = []) ~b k =
  do_request
    t
    (Request.get (Opts.Get.get_of_opts opts ~b ~k))
    Response.get
  >|= function
    | Ok [robj] -> begin
      if Robj.contents robj = [] && Robj.vclock robj = None then
	(printf "\nget::Not found";
	 Error `Notfound)
      else
	Ok robj
    end
    | Ok _ ->  (printf "\nget::Ok_ error";
      Error `Wrong_type)
    | Error err ->  (printf "\nget::Error error";
      Error err)

let put t ?(opts = []) ~b ?k robj =
  do_request
    t
    (Request.put (Opts.Put.put_of_opts opts ~b ~k robj))
    Response.put
  >|= function
    | Ok [(robj, key)] ->
      Ok (robj, key)
    | Ok _ -> (printf "\nput::Ok_ error";
      Error `Wrong_type)
    | Error err ->  (printf "\nput::Error err";
      Error err)

let delete t ?(opts = []) ~b k =
  do_request
    t
    (Request.delete (Opts.Delete.delete_of_opts opts ~b ~k))
    Response.delete
  >|= function
    | Ok [()] ->
      Ok ()
    | Ok _ ->
      Error `Wrong_type
    | Error err ->
      Error err

(*Add support for purging a bucket--not nativly supported by RIAK. 
Might have to sleep test thread b4 list keys or key list might be stale*)
let purge t ~b =
  let rec thepurge keys =
    match keys with  
    | key :: tail -> delete t ~b key >>=
		       (function
			 | Ok ()-> thepurge tail
			 | Error err -> Lwt.return(Error err))
    | [] -> Lwt.return(Ok()) in
  list_keys t b >>= (fun lok -> match lok with
				| Ok keys -> thepurge keys
				| Error err -> Lwt.return(Error err))

let index_search t ?(opts = []) ~b ~index query_type =
  let idx_s =
    Opts.Index_search.index_search_of_opts
      opts
      ~b
      ~index
      ~query_type
  in
  do_request
    t
    (Request.index_search ~stream:false idx_s)
    Response.index_search
  >|= function
    | Ok [results] ->
      Ok results
    | Ok _ ->
      Error `Wrong_type
    | Error err ->
      Error err

