module Eval

import AST;
import Resolve;

import IO;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  VEnv init = ();
  for (/question(_, AId id, AType t) := f) {
    switch (t) {
      case strType(): init[id.name] = vstr("");
      case intType(): init[id.name] = vint(0);
      case boolType(): init[id.name] = vbool(false);
    }
  }
  for (/calculated(_, AId id, AType t, _) := f) {
    switch (t) {
      case strType(): init[id.name] = vstr("");
      case intType(): init[id.name] = vint(0);
      case boolType(): init[id.name] = vbool(false);
    }
  }
  return init;
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

int typeOf(Value v) {
  switch (v) {
    case vint(_): return 0;
    case vbool(_): return 1;
    case vstr(_): return 2;
    default: return -1;
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  println(inp);
  println(venv);
  if (typeOf(inp.\value) != typeOf(venv[inp.question])) {
    println("Type error");
    return venv;
  }
  for(q <- f.questions) venv = eval(q, inp, venv);
  return venv; 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  str name = inp.question;
  switch (q) {
    case question(_, id(name) ,_): venv[name] = inp.\value;
    case calculated(_,_,_,_): return venv;
    case ifelse(_,_,_): return venv;
  }
  return venv; 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    
    // etc.
    
    default: throw "Unsupported expression <e>";
  }
}