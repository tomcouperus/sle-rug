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
  if (/ifelse(AExpr cond, list[AQuestion] ifqs, list[AQuestion] elseqs) := q) {
    msgs += check(cond, tenv, useDef);
    for (ifq <- ifqs) {
      msgs += check(ifq, tenv, useDef);
    }
    for (elseq <- elseqs) {
      msgs += check(elseq, tenv, useDef);
    }
    return msgs;
  } else {
    msgs += checkTypeRedefinition(q, tenv);
    msgs += checkDuplicatePrompts(q, tenv);
  }
  if(/calculated(_, _, _, AExpr expr) := q) {
    msgs += checkComputedExprType(q, tenv, useDef);
    msgs += check(expr, tenv, useDef);
  }
  return msgs;
}

set[Message] checkTypeRedefinition(AQuestion q1, TEnv tenv) {
  set[Message] msgs = {};
  for (q2 <- tenv) {
    if (q1.id.name == q2.name) {
      if (convert(q1.idtype) != q2.\type) {
        msgs += error("Redefinition with different type: \'<typeString(convert(q1.idtype))>\' vs \'<typeString(q2.\type)>\'", q1.id.src);
      } else if (q1.id.src != q2.def) {
        msgs += warning("Redefinition", q1.id.src);
      }
      // break;
    }
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

set[Message] checkComputedExprType(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  if (convert(q.idtype) != typeOf(q.expr, tenv, useDef))
    msgs += error("Type of id does not match type of expression", q.expr.src);
  return msgs; 
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case unop(uNot(), AExpr rhs): {
      msgs += check(rhs, tenv, useDef);
      if(typeOf(rhs, tenv, useDef) != tbool()) {
        msgs += error("Wrong expression type with operand", unop.src);
      }
    }
    case unop(uMinus(), AExpr rhs): {
      msgs += check(rhs, tenv, useDef);
      if(typeOf(rhs, tenv, useDef) != tint()) {
        msgs += error("Wrong expression type with operand", unop.src);
      }
    }
    case binop(AExpr lhs, ABinOperator binop, AExpr rhs): {
      msgs += check(lhs, tenv, useDef);
      msgs += check(rhs, tenv, useDef);
      Type lhsType = typeOf(lhs, tenv, useDef);
      Type rhsType = typeOf(rhs, tenv, useDef);
      switch(binop) {
        case mult(): {
          if (lhsType != tint()) {
            msgs += error("multiplication operator requires integer type operands", lhs.src);
          }
          if (rhsType != tint()) {
            msgs += error("multiplication operator requires integer type operands", rhs.src);
          }
        }
        case modulo(): {
          if (lhsType != tint()) {
            msgs += error("modulo operator requires integer type operands", lhs.src);
          }
          if (rhsType != tint()) {
            msgs += error("modulo operator requires integer type operands", rhs.src);
          }
        }
        case div(): {
          if (lhsType != tint()) {
            msgs += error("division operator requires integer type operands", lhs.src);
          }
          if (rhsType != tint()) {
            msgs += error("division operator requires integer type operands", rhs.src);
          }
        }
        case add(): {
          if (lhsType != tint()) {
            msgs += error("addition operator requires integer type operands", lhs.src);
          }
          if (rhsType != tint()) {
            msgs += error("addition operator requires integer type operands", rhs.src);
          }
        }
        case bMinus(): {
          if (lhsType != tint()) {
            msgs += error("subtraction operator requires integer type operands", lhs.src);
          }
          if (rhsType != tint()) {
            msgs += error("subtraction operator requires integer type operands", rhs.src);
          }
        }
        case less(): {
          if (lhsType != tint()) {
            msgs += error("lesser than comparison requires integer type operands", lhs.src);
          }
          if (rhsType != tint()) {
            msgs += error("lesser than comparison requires integer type operands", rhs.src);
          }
        }
        case leq(): {
          if (lhsType != tint()) {
            msgs += error("lesser than or equal comparison requires integer type operands", lhs.src);
          }
          if (rhsType != tint()) {
            msgs += error("lesser than or equal comparison requires integer type operands", rhs.src);
          }
        }
        case greater(): {
          if (lhsType != tint()) {
            msgs += error("greater than comparison requires integer type operands", lhs.src);
          }
          if (rhsType != tint()) {
            msgs += error("greater than comparison requires integer type operands", rhs.src);
          }
        }
        case geq(): {
          if (lhsType != tint()) {
            msgs += error("greater than or equal comparison requires integer type operands", lhs.src);
          }
          if (rhsType != tint()) {
            msgs += error("greater than or equal comparison requires integer type operands", rhs.src);
          }
        }
        case eq(): {
          if (!(lhsType == tint() && rhsType == tint()) || !(lhsType == tbool() && rhsType == tbool())) {
            msgs += error("equals comparison requires both operands to be matching integer or boolean types", binop.src);
          }
        }
        case neq(): {
          if (!(lhsType == tint() && rhsType == tint()) || !(lhsType == tbool() && rhsType == tbool())) {
            msgs += error("not equals comparison requires both operands to be matching integer or boolean types", binop.src);
          }
        }
        case land(): {
          if (lhsType != tbool()) {
            msgs += error("logical and operator requires boolean type operands", lhs.src);
          }
          if (rhsType != tbool()) {
            msgs += error("logical and operator requires boolean type operands", rhs.src);
          }
        }
        case lor(): {
          if (lhsType != tbool()) {
            msgs += error("logical or operator requires boolean type operands", lhs.src);
          }
          if (rhsType != tbool()) {
            msgs += error("logical or operator requires boolean type operands", rhs.src);
          }
        }
        default: msgs += error("unknown binary operator", binop.src);
      }
    }
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case unop(uNot(),_): 
      return tbool;
    case unop(uMinus(),_): 
      return tint;
    case binop(_, ABinOperator binop, _):
      return typeOf(binop);
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    case lit(ALiteral lit):
      return typeOf(lit);
  }
  return tunknown(); 
}

Type typeOf(ABinOperator binop) {
  switch (binop) {
    case mult(): return tint();
    case modulo(): return tint();
    case div(): return tint();
    case add(): return tint();
    case bMinus(): return tint();
    case less(): return tbool();
    case leq(): return tbool();
    case greater(): return tbool();
    case geq(): return tbool();
    case eq(): return tbool();
    case neq(): return tbool();
    case land(): return tbool();
    case lor(): return tbool();
    default: return tunknown();
  }
}

Type typeOf(ALiteral lit) {
  switch (lit) {
    case strLit(_): return tstr();
    case intLit(_): return tint();
    case boolLit(_): return tbool();
    default: return tunknown();
  }
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
 
 

