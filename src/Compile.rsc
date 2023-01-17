module Compile

import AST;
import Resolve;
import IO;
import lang::html::AST; // see standard library
import lang::html::IO;


int availableIfElseId = 0;

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTMLElement type and the `str writeHTMLString(HTMLElement x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  availableIfElseId = 0;
  writeFile(f.src[extension="js"].top, form2js(f));
  availableIfElseId = 0;
  writeFile(f.src[extension="html"].top, writeHTMLString(form2html(f)));
}

HTMLElement form2html(AForm f) {
  list[HTMLElement] elems = [];
  for (AQuestion q <- f.questions) {
    elems += question2html(q);
  }
  elems += script([], src="<f.src[extension="js"].file>");
  return html(elems);
}

HTMLElement question2html(AQuestion q) {
  str class = "";
  str id = "";
  list[HTMLElement] elems = [];
  switch (q) {
    case question(APrompt p, AId qid, AType t): {
      class = "question";
      id = qid.name + "Container";
      elems += label([\data(p.string)], \for=qid.name);
      elems += genQuestionInput(qid.name, t, false);
    }
    case calculated(APrompt p, AId qid, AType t, _): {
      class = "calculated";
      id = qid.name + "Container";
      elems += label([\data(p.string)], \for=qid.name);
      elems += genQuestionInput(qid.name, t, true);
    }
    case ifelse(_, list[AQuestion] ifqs, list[AQuestion] elseqs): {
      class = "ifelse";
      str ifelseid = "ifelse<availableIfElseId>";
      availableIfElseId += 1;
      list[HTMLElement] ifs = [];
      list[HTMLElement] elses = [];
      for (AQuestion q <- ifqs) ifs += question2html(q);
      for (AQuestion q <- elseqs) elses += question2html(q);
      elems += div(ifs, class="if <ifelseid>");
      elems += div(elses, class="else <ifelseid>");
    }
  }
  HTMLElement qElem = div(elems, class=class, id=id);
  return qElem;
}

HTMLElement genQuestionInput(str id, AType t, bool readonly) {
  str \type = "text";
  str placeholder = "";
  str val = "";
  str oninput = "<id> = ";
  switch (t) {
    case strType(): {
      \type = "text";
      placeholder = "text";
      val = "";
      oninput += "this.value";
    }
    case intType(): {
      \type = "number";
      placeholder = "0";
      val = "0";
      oninput += "parseInt(this.value)";
    }
    case boolType(): {
      \type = "checkbox";
      val = "false";
      oninput += "this.checked";
    }
  }
  oninput += "; console.log(<id>)";
  oninput += "; SetCalculatedValues()";
  oninput += "; SetIfBlocks()";
  if (readonly) {
    return input(id=id, \type=\type, placeholder=placeholder, disabled="true");
  } else {
    switch (t) {
      case strType(): return input(id=id, \type=\type, placeholder=placeholder, oninput=oninput);
      case intType() :return input(id=id, \type=\type, placeholder=placeholder, oninput=oninput);
      case boolType() :return input(id=id, \type=\type, placeholder=placeholder, onclick=oninput);
      default: return div([]);
    }
  }
}

str form2js(AForm f) {
  str js = "";
  RefGraph rg = resolve(f);
  js += declareJSVars(rg);
  
  js += jsInitVarsFunction(f, rg);
  js += jsSetCalculatedValuesFunction(f, rg);
  js += jsSetIfBlocksFunction(f);
  js += jsInitFunction();

  js += "Initialize();\n";
  return js;
}

str declareJSVars(RefGraph rg) {
  str js = "";
  for (str name <- rg.defs.name) {
    js += "var <name>;\n";
  }
  js += "\n";
  return js;
}

str jsInitVarsFunction(AForm f, RefGraph rg) {
  str js = "function InitializeVars() {\n";
  for (str name <- rg.defs.name) {
    for (/question(_, id(name), AType t) := f) {
      js += "<name> = ";
      switch (t) {
        case strType(): js += "\"hi\"";
        case intType(): js += "2";
        case boolType(): js += "false";
      }
      js += ";\n";
      js += "document.getElementById(\"<name>\")";
      switch (t) {
        case strType(): {
          js += ".value";
        }
        case intType(): {
          js += ".value";
        }
        case boolType(): {
          js += ".checked";
        }
      }
      js += " = <name>;\n";
    }
  }
  js += "}\n\n";
  return js;
}

str AExprToJSExpr(AExpr e) {
  str js = "(";
  switch (e) {
    case unop(uNot(), AExpr rhs): js += "!" + AExprToJSExpr(rhs);
    case unop(uMinus(), AExpr rhs): js += "-" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, mult(), AExpr rhs):     js += AExprToJSExpr(lhs) + "*" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, modulo(), AExpr rhs):   js += AExprToJSExpr(lhs) + "%" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, div(), AExpr rhs):      js += AExprToJSExpr(lhs) + "/" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, add(), AExpr rhs):      js += AExprToJSExpr(lhs) + "+" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, bMinus(), AExpr rhs):   js += AExprToJSExpr(lhs) + "-" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, less(), AExpr rhs):     js += AExprToJSExpr(lhs) + "\<" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, leq(), AExpr rhs):      js += AExprToJSExpr(lhs) + "\<=" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, greater(), AExpr rhs):  js += AExprToJSExpr(lhs) + "\>" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, geq(), AExpr rhs):      js += AExprToJSExpr(lhs) + "\>=" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, eq(), AExpr rhs):       js += AExprToJSExpr(lhs) + "===" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, neq(), AExpr rhs):      js += AExprToJSExpr(lhs) + "!==" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, land(), AExpr rhs):     js += AExprToJSExpr(lhs) + "&&" + AExprToJSExpr(rhs);
    case binop(AExpr lhs, lor(), AExpr rhs):      js += AExprToJSExpr(lhs) + "||" + AExprToJSExpr(rhs);
    case ref(AId id):                 js += id.name;
    case lit(strLit(str string)):     js += string;
    case lit(intLit(int number)):     js += "<number>";
    case lit(boolLit(bool boolean)):  js += "<boolean>";
  }
  js += ")";
  return js;
}

str jsSetCalculatedValuesFunction(AForm f, RefGraph rg) {
  str js = "function SetCalculatedValues() {\n";
  for (str name <- rg.defs.name) {
    for (/calculated(_, id(name), AType t, AExpr e) := f) {
      js += "<name> = "+ AExprToJSExpr(e) +";\n";
      js += "document.getElementById(\"<name>\")";
      switch (t) {
        case strType(): {
          js += ".value";
        }
        case intType(): {
          js += ".value";
        }
        case boolType(): {
          js += ".checked";
        }
      }
      js += " = <name>;\n";
    }
  }
  js += "}\n\n";
  return js;
}

str jsSetIfBlocksFunction(AForm f) {
  str js = "function SetIfBlocks() {\n";
  for (/ifelse(AExpr e, _, _) := f) {
    str exprString = AExprToJSExpr(e);
    str ifelseid = "ifelse<availableIfElseId>";
    availableIfElseId += 1;
    js += "if (" + exprString + ") {\n";
    js += "document.getElementsByClassName(\"" + ifelseid + "\")[0].style.display = \"block\";\n";
    js += "document.getElementsByClassName(\"" + ifelseid + "\")[1].style.display = \"none\";\n";
    js += "} else {\n";
    js += "document.getElementsByClassName(\"" + ifelseid + "\")[0].style.display = \"none\";\n";
    js += "document.getElementsByClassName(\"" + ifelseid + "\")[1].style.display = \"block\";\n";
    js += "}\n";
  }
  js += "}\n\n";
  return js;
}

str jsInitFunction() {
  str js = "function Initialize() {\n";
  js += "InitializeVars();\n";
  js += "SetCalculatedValues();\n";
  js += "SetIfBlocks();\n";
  js += "}\n\n";
  return js;
}