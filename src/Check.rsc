module Check

import AST;
import Resolve;
import Message; // see standard library

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

Type convert(AType t) {
  switch (t) {
    case strType(): return tstr();
    case intType(): return tint();
    case boolType(): return tbool();
    default: return tunknown();
  }
}

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str prompt, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  return { <t.src, id.name, p.string, convert(t)> | 
    /question(APrompt p, AId id, AType t) := f }
       + {<t.src, id.name, p.string, convert(t)> | 
    /calculated(APrompt p, AId id, AType t, _) := f}
    ; 
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  for (AQuestion q <- f.questions) {
    msgs += check(q, tenv, useDef);
  }
  return msgs; 
}

set[Message] checkTypeRedefinition() {
  set[Message] msgs = {};
  return msgs; 
}

set[Message] checkDuplicatePrompts() {
  set[Message] msgs = {};
  return msgs; 
}

set[Message] checkComputedExprType() {
  set[Message] msgs = {};
  return msgs; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate prompts should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  msgs += checkTypeRedefinition();
  msgs += checkDuplicatePrompts();
  msgs += checkComputedExprType();
  return msgs; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };

    // etc.
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    // etc.
  }
  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

