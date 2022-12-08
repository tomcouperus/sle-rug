# Instructions
1. Open the rascal terminal.
2. `import Syntax;`
3. `import IDE;`
4. `import ParseTree;`
5. `loc binPath = |project://sle-rug/examples/binary.myql|;`
6. `loc cycPath = |project://sle-rug/examples/cyclic.myql|;`
7. `loc taxPath = |project://sle-rug/examples/tax.myql|;`
8. `start[Form] binsf = parse(#start[Form], binPath);`
9. `start[Form] cycsf = parse(#start[Form], cycPath);`
10. `start[Form] taxsf = parse(#start[Form], taxPath);`
11. `import AST;`
12. `import CST2AST;`
13. `AForm binaf = cst2ast(binsf);`
14. `AForm cycaf = cst2ast(cycsf);`
15. `AForm taxaf = cst2ast(taxsf);`
16. `import Resolve;`
17. `RefGraph binrg = resolve(binaf)`
18. `RefGraph cycrg = resolve(cycaf)`
19. `RefGraph taxrg = resolve(taxaf)`
20. `import Check;`
21. `TEnv binte = collect(binaf);`
22. `TEnv cycte = collect(cycaf);`
23. `TEnv taxte = collect(taxaf);`
24. `check(binaf, binte, binrg.useDef)`
25. `check(cycaf, cycte, cycrg.useDef)`
26. `check(taxaf, taxte, taxrg.useDef)`

## For long output, do the following
1. `import IO;`
2. `iprintln($$$)`


# Tests
```test bool function = ast_node := cst2ast;```
Then run it with `:test`

# Pretty print
1. `import vis::Text;`
2. `prettyTree(parseTree)`
3. `prettyNode(ast)` 