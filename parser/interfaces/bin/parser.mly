%{ open Ast %}

(* Values *)
%token <string> ID
%token <int> INT_LITERAL

(* Keywords *)
%token INTERFACE
%token PARAMETER
%token WIRE
%token FUNCTION
%token COMBINATIONAL
%token SEQUENTIAL
%token IF
%token ELSE
%token NULL
%token TRUE
%token FALSE

(* Punctuation *)
%token PARAN_L PARAN_R
%token CURLY_L CURLY_R
%token SQUARE_L SQUARE_R
%token ANGLE_L ANGLE_R

%token COLON
%token SEMI_COLON
%token EOF

(* Operators *)
%token ADD SUBTRACT
%token MULTIPLY DIVIDE
%token EQUALS NOT_EQUALS
%token GREATER_THAN_EQUALS LESS_THAN_EQUALS
%token CONNECTOR
%token COMMA
%token DOT

(* Precedence *)
%left CONNECTOR
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
    | program definition { $2 :: $1 }
;

definition:
    | interface_definition { InterfaceDefinition $1 }
    | function_definition  { FunctionDefinition $1 }

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
    instantiation { $1 }
;

instantiation:
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

static_value:
    | TRUE                                          { Literal 1 } (* TODO: Boolean static expressions *)
    | FALSE                                         { Literal 0 }
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

(* FUNCTION DEFINITIONS *)

function_definition:
    | t=function_type FUNCTION i=ID
        gidl=generic_interface_definition_list
        gpdl=generic_parameter_definition_list
        inputs=function_io_list CONNECTOR outputs=function_io_list
        CURLY_L body=circuit_statement_list CURLY_R { (i, t, gidl, gpdl, inputs, outputs, body) }
;

function_type:
    | (* Empty *)   { DefaultFunction }
    | SEQUENTIAL    { SequentialFunction }
    | COMBINATIONAL { CombinationalFunction }

function_io_type:
    | (* Empty *)   { DefaultIO }
    | SEQUENTIAL    { SequentialIO }
    | COMBINATIONAL { CombinationalIO }

function_io_list:
    | NULL                      { [] }
    | function_io_list_values   { $1 }
;

function_io_list_values:
    | v=function_io_list_value                                               { [v] }
    | remainder=function_io_list_values COMMA v=function_io_list_value       { v :: remainder }
    | remainder=function_io_list_values COMMA v=function_io_list_value COMMA { v :: remainder }

function_io_list_value:
    t=function_io_type i=ID COLON interface=interface_expression { (i, t, interface) }
;

circuit_statement_list:
    | (* Empty *) { [] }
    | remainder=circuit_statement_list statement=circuit_statement { statement :: remainder }
;

circuit_statement:
    | conditional_circuit_statement { ConditionalStatement $1 }
    | circuit_expression SEMI_COLON { NonConditionalStatement $1 }
;

conditional_circuit_statement: (* TODO: This is a bit hacky. A better way to do this is probably to create the concept of a scope? *)
    | IF PARAN_L condition=static_value PARAN_R if_body=if_body_circuit_statement_list                                               { (condition, if_body, []) }
    | IF PARAN_L condition=static_value PARAN_R if_body=if_body_circuit_statement_list ELSE else_body=if_body_circuit_statement_list { (condition, if_body, else_body) }
;

if_body_circuit_statement_list:
    | CURLY_L statements=circuit_statement_list CURLY_R { statements }
    | statement=circuit_statement                       { [statement] }
;

circuit_expression:
    | circuit_producer_expression                 { ProducerExpression $1 }
    | circuit_consumer_expression                 { ConsumerExpression $1 }
;

circuit_producer_expression:
    | v=circuit_producer_expression_value { v }
    | PARAN_L v=circuit_producer_expression_value PARAN_R { v }
;

circuit_consumer_expression:
    | v=circuit_consumer_expression_value { v }
    | PARAN_L v=circuit_consumer_expression_value PARAN_R { v }
;

circuit_producer_expression_value:
    | circuit_producer_connection_expression          { ProducerConnectionExpression $1 }
    | circuit_producer_group_expression               { ProducerGroupExpression $1 }
    | circuit_record_interface_constructor_expression { ProducerInterfaceConstructorExpression $1 }
    | circuit_consumer_expression                     { ProducerConsumerExpression $1 }
;

circuit_consumer_expression_value:
    | circuit_node_expression                { ConsumerNodeExpression $1 }
    | circuit_consumer_connection_expression { ConsumerConnectionExpression $1 }
    | circuit_consumer_group_expression      { ConsumerGroupExpression $1 }
;

circuit_producer_connection_expression:
    p=circuit_producer_expression CONNECTOR c=circuit_consumer_expression { (p, c) }
;

circuit_consumer_connection_expression:
    p=circuit_consumer_expression CONNECTOR c=circuit_consumer_expression { (p, c) }
;

circuit_producer_group_expression:
    | second=circuit_producer_expression COMMA first=circuit_producer_expression { [second; first] }
    | remainder=circuit_producer_group_expression COMMA expression=circuit_producer_expression { expression :: remainder }
;

circuit_consumer_group_expression:
    | second=circuit_consumer_expression COMMA first=circuit_consumer_expression { [second; first] }
    | remainder=circuit_consumer_group_expression COMMA expression=circuit_consumer_expression { expression :: remainder }
;

circuit_expression_node_definition:
    i=ID COLON t=instantiation { (i, t) }
;

circuit_node_expression:
    | circuit_expression_node_definition { DefinitionExpression $1 }
    | ID                                 { ReferenceExpression $1 }
;

circuit_record_interface_constructor_expression:
    CURLY_L statements=circuit_statement_list CURLY_R { statements }
;

