module Compile

import AST;
import Resolve;
import IO;
import lang::html::AST; // see standard library
import lang::html::IO;

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
  writeFile(f.src[extension="js"].top, form2js(f));
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
      list[HTMLElement] ifs = [];
      list[HTMLElement] elses = [];
      for (AQuestion q <- ifqs) ifs += question2html(q);
      for (AQuestion q <- elseqs) elses += question2html(q);
      elems += div(ifs, class="if");
      elems += div(elses, class="else");
    }
  }
  HTMLElement qElem = div(elems, class=class, id=id);
  return qElem;
}

HTMLElement genQuestionInput(str id, AType t, bool readonly) {
  str \type = "text";
  str placeholder = "";
  str val = "";
  switch (t) {
    case strType(): {
      \type = "text";
      placeholder = "text";
      val = "";
    }
    case intType(): {
      \type = "number";
      placeholder = "0";
      val = "0";
    }
    case boolType(): {
      \type = "checkbox";
      val = "false";
    }
  }
  if (readonly) {
    return input(id=id, \type=\type, placeholder=placeholder, \value=val, disabled="true");
  } else {
    return input(id=id, \type=\type, placeholder=placeholder, \value=val);
  }
}

str form2js(AForm f) {
  return "console.log(\"hello world\")";
}
