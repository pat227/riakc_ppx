all:	mli_files mlo_files
protobuf_capables:	protobuf_capables.ml
	ocamlfind ocamlc -w A-4-33-39-40-41-42-43-34 -g -c -principal -safe-string -thread -package core,lwt,bitstring,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime protobuf_capables.ml
mli_files:	protobuf_capables response.mli opts.mli protobuf_capable.mli robj.mli lwt_conn.mli
	ocamlfind ocamlc -w A-4-33-39-40-41-42-43-34 -g -c -principal -safe-string -thread -package core,lwt,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime protobuf_capable.mli robj.mli response.mli opts.mli request.mli lwt_conn.mli lwt_cache.mli
mlo_files:	mli_files opts.ml robj.ml protobuf_capable.ml response.ml request.ml lwt_conn.ml protobuf_capables.ml 
	ocamlfind ocamlc -w A-4-33-39-40-41-42-43-34 -g -c -principal -safe-string -thread -package core,lwt,bitstring,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime opts.ml robj.ml protobuf_capables.ml protobuf_capable.ml response.ml request.ml lwt_conn.ml lwt_cache.ml
clean:
	rm *.cmi *.cmo *.o 
