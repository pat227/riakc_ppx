all:	mli_files mlo_files

mli_files:	response.mli opts.mli robj.mli protobuf_capable.mli lwt_conn.mli
	ocamlfind ocamlc -w A-4-33-39-40-41-42-43-34 -g -c -principal -safe-string -thread -package core,lwt,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime robj.mli protobuf_capable.mli response.mli opts.mli request.mli lwt_conn.mli
mlo_files:	opts.ml robj.ml protobuf_capable.ml response.ml request.ml lwt_conn.ml
	ocamlfind ocamlc -w A-4-33-39-40-41-42-43-34 -g -c -principal -safe-string -thread -package core,lwt,bitstring,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime opts.ml robj.ml protobuf_capable.ml response.ml request.ml lwt_conn.ml
clean:
	rm lwt_*.c??? lwt_*.o
