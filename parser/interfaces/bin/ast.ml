(* INTERFACES *)

type identifier = string
[@@deriving show]

type static_value_expression =
  | Literal of int
  | Variable of identifier
  | Add of static_value_expression * static_value_expression
  | Subtract of static_value_expression * static_value_expression
  | Multiply of static_value_expression * static_value_expression
  | Divide of static_value_expression * static_value_expression
  | Equals of static_value_expression * static_value_expression
  | NotEquals of static_value_expression * static_value_expression
  | GreaterThan of static_value_expression * static_value_expression
  | LessThan of static_value_expression * static_value_expression
  | GreaterThanEquals of static_value_expression * static_value_expression
  | LessThanEquals of static_value_expression * static_value_expression
[@@deriving show]
type parameter_value = static_value_expression
[@@deriving show]
type parameter_type = identifier (* TODO: Should these be reserved words? *)
[@@deriving show]
type parameter_definition = identifier * parameter_type
[@@deriving show]
type generic_interface_definition = identifier
[@@deriving show]

(* INTERFACE EXPRESSIONS *)
type array_bounds_specifier = static_value_expression
[@@deriving show]

type interface_expression =
  | Wire
  | DeclaredInterface of declared_interface_expression
  | VectorInterface of vector_interface_expression
  | GenericInterface of identifier
[@@deriving show]
and declared_interface_expression = instantiation
[@@deriving show]
and vector_interface_expression = interface_expression * array_bounds_specifier
[@@deriving show]
and instantiation = identifier * interface_expression list * parameter_value list
[@@deriving show]

(* INTERFACE DEFINITIONS *)
type record_interface_ports = identifier * interface_expression
[@@deriving show]

type interface_definition =
  | AliasInterface of alias_interface_definition
  | RecordInterface of record_interface_definition
[@@deriving show]

and alias_interface_definition = identifier * generic_interface_definition list * parameter_definition list * interface_expression
[@@deriving show]
and record_interface_definition = identifier * generic_interface_definition list * parameter_definition list * declared_interface_expression list * record_interface_ports list
[@@deriving show]

(* FUNCTION EXPRESSION *)
type function_expression = instantiation
[@@deriving show]

(* FUNCTION DEFINITION *)
type function_type =
  | CombinationalFunction
  | SequentialFunction
  | DefaultFunction
[@@deriving show]

type function_io_type =
  | CombinationalIO
  | SequentialIO
  | DefaultIO
[@@deriving show]

type function_io = identifier * function_io_type * interface_expression
[@@deriving show]

(* Circuit Statements *)
type circuit_expression_node_definition = identifier * instantiation
[@@deriving show]
and circuit_expression_node_expression =
  | Definition of circuit_expression_node_definition
  | Expression of identifier
[@@deriving show]
and circuit_expression_node_list_expression = circuit_expression_node_expression list
[@@deriving show]
and circuit_expression_record_interface_constructor = circuit_statement list
[@@deriving show]
and conditional_circuit_statement = static_value_expression * circuit_statement list * circuit_statement list
[@@deriving show]
and circuit_statement =
  | Conditional of conditional_circuit_statement
  | NonConditional of circuit_expression
[@@deriving show]

and circuit_expression_consumer =
  | ExpressionConsumer of circuit_expression
  | NodeListConsumer of circuit_expression_node_list_expression
[@@deriving show]
and circuit_expression_producer =
  | ExpressionProducer of circuit_expression
  | NodeListProducer of circuit_expression_node_list_expression
  | InterfaceConstructorProducer of circuit_expression_record_interface_constructor
[@@deriving show]
and circuit_expression_connection = circuit_expression_producer * circuit_expression_consumer
[@@deriving show]
and circuit_expression =
  | Definition of circuit_expression_node_definition
  | Connection of circuit_expression_connection
[@@deriving show]

(* TODO: Functions as parameters *)
type function_definiton = identifier * function_type * generic_interface_definition list * parameter_definition list * function_io list * function_io list * circuit_statement list
[@@deriving show]


(* PROGRAM *)
type definition =
  | InterfaceDefinition of interface_definition
  | FunctionDefinition of function_definiton
[@@deriving show]
type program = definition list [@@deriving show]