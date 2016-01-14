(*Use inheritance from a base class to accomodate the use of Versioned.t or 
 not, and instead use the to/from_encoding functions of whatever other type t. 
 The dependency upon protobuf decoder and encoders by the functions produced 
 by the protobuf ppx extension means for any type t in a module using protobuf 
 ppx extension we'll need a functor in this project to generate equivalent 
 functions to/from_encoding; see converter.ml. This will make using json or 
 any other encoding easier to substitute in place of protocol buffers for 
 use with riak. *)
module Serializable_class : sig
  type 'a t = < from_encoding : string -> 'a ; to_encoding : 'a -> string >;;
  class
    ['a] serializable_class :
      (string -> 'a) -> ('a -> string) ->
      object
	method from_encoding : string -> 'a
	method to_encoding : 'a -> string
      end
  class
    ['a] protobuf_capable_class_version_wrapped :
      (string -> 'a) -> ('a -> string) ->
      object
	method from_encoding : string -> 'a
	method to_encoding : 'a -> string
      end
end (*= Serializable_class*)

(*Let's also try this with a module and functors
module Serializable : sig
  type t
  val from_encoding : bytes -> 't
  val to_encoding : 't -> bytes
end 
		      *)
