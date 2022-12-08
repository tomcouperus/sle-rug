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

str typeString(Type t) {
  switch (t) {
    case tint(): return "integer";
    case tbool(): return "boolean";
    case tstr(): return "string";
    case tunknown(): return "unknown";
    default: return "Error: Type not found";
  }
}

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str prompt, Type \type];

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  return { <id.src, id.name, p.string, convert(t)> | 
    /question(APrompt p, AId id, AType t) := f }
       + {<id.src, id.name, p.string, convert(t)> | 
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

// - produce an error if there are declared questions with the same name but different types.
// - duplicate prompts should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  if (/ifelse(_, _, _) := q) {
    return msgs;
  } else {
    msgs += checkTypeRedefinition(q, tenv);
    msgs += checkDuplicatePrompts(q, tenv);
    msgs += checkComputedExprType();
  }
  return msgs;
}

set[Message] checkTypeRedefinition(AQuestion q1, TEnv tenv) {
  set[Message] msgs = {};
  for (q2 <- tenv) {
    if (q1.id.name == q2.name && convert(q1.idtype) != q2.\type) {
      msgs += error("Type redefinition. Earlier defined as <typeString(convert(q1.idtype))>", 
        q2.def);
      break;
    }
    continue;
  }
  return msgs; 
}

set[Message] checkDuplicatePrompts(AQuestion q, TEnv tenv) {
  set[Message] msgs = {};
  bool first = true;
  for(q2 <- tenv) {
    if (q2.prompt == q.prompt.string) {
      if (!first) {
        msgs += warning("Duplicate prompt", q.prompt.src);
        break;
      }
      first = false;
    }
  }
  return msgs; 
}

set[Message] checkComputedExprType() {
  set[Message] msgs = {};
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
 
 

