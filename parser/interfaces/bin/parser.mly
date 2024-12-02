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

(* Operators *)
%token ADD SUBTRACT
%token MULTIPLY DIVIDE
%token EQUALS NOT_EQUALS
%token GREATER_THAN_EQUALS LESS_THAN_EQUALS

(* Precedence *)
%left ADD SUBTRACT
%left MULTIPLY DIVIDE
%left GREATER_THAN_EQUALS LESS_THAN_EQUALS ANGLE_L ANGLE_R
%left EQUALS NOT_EQUALS

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
      gidl=generic_interface_definition_list
      gpdl=generic_parameter_definition_list
      alias=interface_expression { (i, gidl, gpdl, alias) }
;

record_interface_definition:
      INTERFACE i=ID
        gidl=generic_interface_definition_list
        gpdl=generic_parameter_definition_list
        COLON il=inherit_list
        CURLY_L pdl=port_definition_list CURLY_R { (i, gidl, gpdl, il, pdl) }
    | INTERFACE i=ID
        gidl=generic_interface_definition_list
        gpdl=generic_parameter_definition_list
        CURLY_L pdl=port_definition_list CURLY_R { (i, gidl, gpdl, [], pdl) }
;

(* Helpers for Interface Definitions *)
generic_interface_definition_list:
    | (* Empty *)                                                     { [] }
    | ANGLE_L values=generic_interface_definition_list_values ANGLE_R { values }
;

generic_interface_definition_list_values:
    | i=ID                                                                { [i] }
    | remainder=generic_interface_definition_list_values COMMA i=ID       { i :: remainder }
    | remainder=generic_interface_definition_list_values COMMA i=ID COMMA { i :: remainder }
;

generic_parameter_definition_list:
    | PARAN_L PARAN_R                                                 { [] }
    | PARAN_L values=generic_parameter_definition_list_values PARAN_R { values }
;

generic_parameter_definition_list_values:
    | gpd=generic_parameter_definition                                                                { [gpd] }
    | remainder=generic_parameter_definition_list_values COMMA gpd=generic_parameter_definition       { gpd :: remainder }
    | remainder=generic_parameter_definition_list_values COMMA gpd=generic_parameter_definition COMMA { gpd :: remainder }
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
    | i=ID { GenericInterface i }
;

declared_interface_expression:
    | i=ID
        ANGLE_L givl=generic_interface_value_list ANGLE_R
        PARAN_L gpvl=generic_parameter_value_list PARAN_R { (i, givl, gpvl) }
    | i=ID
        PARAN_L gpvl=generic_parameter_value_list PARAN_R { (i, [], gpvl) }
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

parameter_value:
    v=static_value { v }
;

array_bounds_specifier:
    v=static_value { v }
;

static_value: (**)
    | v=INT_LITERAL                                 { Literal v }
    | i=ID                                          { Variable i }
    | PARAN_L static_value PARAN_R                  { $2 }
    | static_value ADD static_value                 { Add ($1, $3) }
    | static_value SUBTRACT static_value            { Subtract ($1, $3) }
    | static_value MULTIPLY static_value            { Multiply ($1, $3) }
    | static_value DIVIDE static_value              { Divide ($1, $3) }
    | static_value EQUALS static_value              { Equals ($1, $3) }
    | static_value NOT_EQUALS static_value          { NotEquals ($1, $3) }
    | static_value ANGLE_L static_value             { LessThan ($1, $3) }
    | static_value ANGLE_R static_value             { GreaterThan ($1, $3) }
    | static_value LESS_THAN_EQUALS static_value    { LessThanEquals ($1, $3) }
    | static_value GREATER_THAN_EQUALS static_value { GreaterThanEquals ($1, $3) }
;