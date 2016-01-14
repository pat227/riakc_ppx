all:	mli_files mlo_files versioned converter classes
protobuf_capables:	protobuf_capables.ml
	ocamlfind ocamlc -w A-4-33-39-40-41-42-43-34 -g -c -principal -safe-string -thread -package core,lwt,bitstring,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime protobuf_capables.ml
mli_files:	protobuf_capables response.mli opts.mli protobuf_capable.mli robj.mli lwt_conn.mli
	ocamlfind ocamlc -w A-4-33-39-40-41-42-43-34 -g -c -principal -safe-string -thread -package core,lwt,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime protobuf_capable.mli robj.mli response.mli opts.mli request.mli lwt_conn.mli lwt_cache.mli 
mlo_files:	mli_files opts.ml robj.ml protobuf_capable.ml response.ml request.ml lwt_conn.ml protobuf_capables.ml 
	ocamlfind ocamlc -w A-4-33-39-40-41-42-43-34 -g -c -principal -safe-string -thread -package core,lwt,bitstring,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime opts.ml robj.ml protobuf_capables.ml protobuf_capable.ml response.ml request.ml lwt_conn.ml lwt_cache.ml lwt_riakc.ml lwt_cache.ml lwt_caches.ml
versioned:	versioned.ml versioned.mli
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,yojson,bitstring,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime,ppx_deriving_yojson versioned.mli versioned.ml
converter:	converter.ml converter.mli
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,yojson,bitstring,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show,ppx_deriving_protobuf.runtime converter.mli converter.ml
classes:	serializable_class.mli serializable_class.ml
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,yojson,ppx_deriving,ppx_deriving_protobuf serializable_class.mli serializable_class.ml
mylogger:	mylogging.ml
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,async mylogging.ml
pbcapables:	protobuf_capables.ml
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,ppx_deriving_protobuf protobuf_capables.ml
pbcapable:	protobuf_capable.ml protobuf_capable.mli
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,ppx_deriving_protobuf protobuf_capable.mli protobuf_capable.ml
robj:	robj.mli robj.ml
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,ppx_deriving_protobuf robj.mli robj.ml
response:	response.mli response.ml robj
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,bitstring,ppx_deriving_protobuf response.mli response.ml
opts:	opts.mli opts.ml
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,ppx_deriving_protobuf opts.mli opts.ml
request:	request.ml request.mli
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,ppx_deriving_protobuf request.mli request.ml
conn:	conn.mli conn.ml response opts request
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,async,ppx_deriving_protobuf conn.mli conn.ml
cache_classes:	versioned converter classes mylogger pbcapables pbcapable conn cache_classes.ml cache_classes.mli
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,async,ppx_deriving,ppx_deriving_protobuf,ppx_deriving.show cache_classes.mli cache_classes.ml
serializables:	cache_classes serializables.ml
	ocamlfind ocamlc -g -c -principal -safe-string -thread -package core,yojson,ppx_deriving_protobuf,ppx_deriving_yojson serializables.ml
clean:
	rm *.cmi *.cmo *.o
