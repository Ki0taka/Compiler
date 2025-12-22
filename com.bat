flex lex2.l
bison -d syn.y
gcc lex.yy.c syn.tab.c TS.c -o ACADAB.exe
ACADAB.exe<test.txt
