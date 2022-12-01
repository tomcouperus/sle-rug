# Software Language Engineering Lectures

## Lecture 1

Tradeoffs of performance and useability, as well as scale is very important.

A Software Language needs the following:
- Syntax
  - How the language is formed, the rules of the language.
- Semantics
  - The meaning of the syntax
- Tooling
  - Not just the semantics, also able to reformat, visualize and other things.
- Transformation
  - Many semantics and tooling are transformations. 
  - So is compilation
- Analysis
  - Can we derive properties? Error msgs, concurrency, consistency and performance, etc
- Representation
  - To represent the source code in a way that SLEngineers can modify it.


## Lecture 2
Why are grammars and parsing relevant?
- Grammar is a formal method to describe a language
  - Programming
  - Domain-specific
  - Data format
- Parsing
  - Tests whether a text conforms to a grammar
  - Turns a correct text into a parse tree

### Define a language
- Simple solution: finite set of a acceptable sentences
  - Very limited
- Realistic solution: finite recipe that describes all acceptable sentences
- Grammar is finite description of a possibly infinite set of acceptable sentences.

### Exam note
Doesn't care about notation, as long as you show you understand what a grammar is.

### In practice
Regular grammars used for lexical syntax:
- Keywords
- Constants
- Comments

Context-free grammars used for structured and nested concepts
- Class declaration
- if statement

### General approaches to parsing
- Top-Down (Predictive)
  - each non-terminal is a goal
  - replace each goal by subgoals
  - parse is built from top to bottom
- Bottom-Up
  - Recognize terminals
  - Replace terminals by non-terminals
  - replace terminals and non-terminals by left-hand side of rule

### Parser impl
- Manual
  + Good error recovery
  + Flexible combination of parsing and action
  - Lot of work
- gen
  + May save lot work
  - Complex and rigid frameworks
  - Rigid actions
  - Error recovery more difficult 

## Lecture 3
No notes

