%{ open Ast %}

(* Values *)
%token <string> ID
%token <int> INT_LITERAL

(* Keywords *)
%token INTERFACE
%token PARAMETER
%token WIRE (* tmp: we should eventually remove this *)

(* Punctuation *)
%token PARAN_L PARAN_R
%token CURLY_L CURLY_R
%token SQUARE_L SQUARE_R
%token ANGLE_L ANGLE_R

%token COLON
%token SEMI_COLON
%token COMMA
%token EOF

%start main             /* the entry point */
%type <Ast.program> main
%%
main:
    program EOF { $1 }
;

program:
    | (* Empty *) { [] }
    | program interface_definition { $2 :: $1 }
;

(* Interface Definitions *)
interface_definition:
    | alias_interface_defition { AliasInterface $1 }
    | record_interface_definition { RecordInterface $1 }
;

alias_interface_defition:
    INTERFACE i=ID
      ANGLE_L gidl=generic_interface_definition_list ANGLE_R
      PARAN_L gpdl=generic_parameter_definition_list PARAN_R
      alias=interface_expression { (i, gidl, gpdl, alias) }
;

record_interface_definition:
      INTERFACE i=ID
        ANGLE_L gidl=generic_interface_definition_list ANGLE_R
        PARAN_L gpdl=generic_parameter_definition_list PARAN_R
        COLON il=inherit_list
        CURLY_L pdl=port_definition_list CURLY_R { (i, gidl, gpdl, il, pdl) }
    | INTERFACE i=ID
        ANGLE_L gidl=generic_interface_definition_list ANGLE_R
        PARAN_L gpdl=generic_parameter_definition_list PARAN_R
        CURLY_L pdl=port_definition_list CURLY_R { (i, gidl, gpdl, [], pdl) }
;

(* Helpers for Interface Definitions *)
generic_interface_definition_list:
    | (* Empty *)                                                   { [] }
    | i=ID                                                          { [i] }
    | remainder=generic_interface_definition_list COMMA i=ID        { i :: remainder }
    | remainder=generic_interface_definition_list COMMA i=ID COMMA  { i :: remainder }
;

generic_parameter_definition_list:
    | (* Empty *)                                                                               { [] }
    | gpd=generic_parameter_definition                                                          { [gpd] }
    | remainder=generic_parameter_definition_list COMMA gpd=generic_parameter_definition        { gpd :: remainder }
    | remainder=generic_parameter_definition_list COMMA gpd=generic_parameter_definition COMMA  { gpd :: remainder }
;

generic_parameter_definition:
    | PARAMETER i=ID COLON t=ID { (i, t) }
;

inherit_list:
    | interface=declared_interface_expression                               { [interface] }
    | remainder=inherit_list COMMA interface=declared_interface_expression  { interface :: remainder }
;

port_definition_list:
    | (* Empty *)                                         { [] }
    | remainder=port_definition_list port=port_definition { port :: remainder }
;

port_definition:
    i=ID COLON interface=interface_expression SEMI_COLON { (i, interface) }
;

(* Interface Expressions *)
interface_expression:
    | WIRE { Wire }
    | declared_interface_expression { DeclaredInterface $1 }
    | vector_interface_expression { VectorInterface $1 }
    | i=ID { GenericInterface (i) }
;

declared_interface_expression:
    i=ID
      ANGLE_L givl=generic_interface_value_list ANGLE_R
      PARAN_L gpvl=generic_parameter_value_list PARAN_R { (i, givl, gpvl) }
;

vector_interface_expression:
    interface=interface_expression
      SQUARE_L bounds=array_bounds_specifier SQUARE_R { (interface, bounds) }
;

(* Helpers for Interface Expressions *)
generic_interface_value_list:
    | (* Empty *)                                                                       { [] }
    | interface=interface_expression                                                    { [interface] }
    | remainder=generic_interface_value_list COMMA interface=interface_expression       { interface :: remainder }
    | remainder=generic_interface_value_list COMMA interface=interface_expression COMMA { interface :: remainder }
;

generic_parameter_value_list:
    | (* Empty *)                                                          { [] }
    | v=parameter_value                                                    { [v] }
    | remainder=generic_parameter_value_list COMMA v=parameter_value       { v :: remainder }
    | remainder=generic_parameter_value_list COMMA v=parameter_value COMMA { v :: remainder }
;

parameter_value: (* TOOD: This should support static expressions *)
    | v=INT_LITERAL { v }
;

array_bounds_specifier:
    | v=INT_LITERAL { v }
;