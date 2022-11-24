module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id name QuestionBlock; 

syntax QuestionBlock = "{" Question* questions "}";

// TODO: question, computed question, block, if-then-else, if-then
syntax Question 
  = Prompt prompt Id param ":" Type
  | "if" "(" Expr ")" QuestionBlock ("else" QuestionBlock)?
  ;

syntax Prompt = "\"" [a-zA-Z0-9?:]+ "\"";

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  ;
  
syntax Type 
  = Str
  | Int
  | Bool;

lexical Str = "string";

lexical Int = "integer";

lexical Bool = "boolean";



