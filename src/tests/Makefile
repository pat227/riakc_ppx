all:	tests lwt_tests conflict_tests lwt_conflict_tests

tests:	all_tests.ml
	ocamlfind ocamlc -g -principal all_tests.ml -linkpkg -thread -I ./ -package async,core,ppx_tools,ppx_deriving_protobuf,riakc_ppx
lwt_tests:	lwt_all_tests.ml

conflict_tests:	conflict_tests.ml
	ocamlfind ocamlc -g -principal conflict_tests.ml -linkpkg -thread -I ./ -package async,core,ppx_tools,ppx_deriving_protobuf,riakc_ppx
lwt_conflict_tests:	lwt_conflict_tests.ml

clean:
	rm *.cmo *.cmi a.out
#.cmo:	.ml .cmi 
#	ocamlfind ocamlc -g -c .ml timePB.ml -thread -package core,riakc_ppx
#.cmi:	.mli
#	ocamlfind ocamlc -g -c .mli -thread -package core,riakc_ppx

#ALMOST WORKS FROM OTHER DIR 
#ocamlfind ocamlc -g -principal lwt_conn.mli lwt_conn.ml protobuf_capable.ml protobuf_capables.ml robj.ml lwt_cache.ml lwt_riakc.ml lwt_all_tests.ml -linkpkg -thread -I ../lib/ -package lwt,core,ppx_tools,ppx_deriving_protobuf,ppx_deriving.show

#ocamlfind ocamlc -g -principal robj.ml response.ml opts.ml request.ml lwt_conn.mli lwt_conn.ml protobuf_capable.ml protobuf_capables.ml lwt_cache.ml lwt_riakc.ml lwt_all_tests.ml -linkpkg -thread -I ../lib/ -package lwt,lwt.unix,bitstring,core,ppx_tools,ppx_deriving_protobuf,ppx_deriving.show
