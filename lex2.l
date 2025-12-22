%{
#include <stdio.h>
#include <string.h>
#include "syn.tab.h"
int nb_ligne=1;
int nb_colonne=1;

void rechercher(char entite[], char code[], char type[], char val[], int y);
%}

IDF     [a-zA-Z]([a-zA-Z0-9])*
CST     [0-9]+
CHAINE  \"[^\"]*\"
CMNT    "##".*

%%

"MainProgram"   { rechercher("MainProgram","MC_MAIN","mot_cle","-",2); return MC_MAIN; nb_colonne+=yyleng; }
"Declaration"   { rechercher("Declaration","DEC","mot_cle","-",2); return DEC; nb_colonne+=yyleng; }
"Entier"        { rechercher("Entier","T_INT","mot_cle","-",2); return T_INT; nb_colonne+=yyleng; }
"Reel"          { rechercher("Reel","T_FLOAT","mot_cle","-",2); return T_FLOAT; nb_colonne+=yyleng; }
"Body"          { rechercher("Body","BODY","mot_cle","-",2); return BODY; nb_colonne+=yyleng; }
"begin"         { rechercher("begin","BEG","mot_cle","-",2); return BEG; nb_colonne+=yyleng; }
"end"           { rechercher("end","END","mot_cle","-",2); return END; nb_colonne+=yyleng; }
"Write"         { rechercher("Write","WRITE","mot_cle","-",2); return WRITE; nb_colonne+=yyleng; }

"If"            { rechercher("If","IF","mot_cle","-",2); return IF; nb_colonne+=yyleng; }
"Else"          { rechercher("Else","ELSE","mot_cle","-",2); return ELSE; nb_colonne+=yyleng; }
"EndIf"         { rechercher("EndIf","ENDIF","mot_cle","-",2); return ENDIF; nb_colonne+=yyleng; }
"For"           { rechercher("For","FOR","mot_cle","-",2); return FOR; nb_colonne+=yyleng; }
"de"            { rechercher("de","DE","mot_cle","-",2); return DE; nb_colonne+=yyleng; }
"à"             { rechercher("à","A","mot_cle","-",2); return A; nb_colonne+=yyleng; }
"pas"           { rechercher("pas","PAS","mot_cle","-",2); return PAS; nb_colonne+=yyleng; }
"Do"            { rechercher("Do","DO","mot_cle","-",2); return DO; nb_colonne+=yyleng; }
"While"         { rechercher("While","WHILE","mot_cle","-",2); return WHILE; nb_colonne+=yyleng; }

":="            { rechercher(":=","ASSIGN","sep","-",3); return ASSIGN; nb_colonne+=yyleng; }
"=="            { rechercher("==","EQ","sep","-",3); return EQ; nb_colonne+=yyleng; }
"!="            { rechercher("!=","NE","sep","-",3); return NE; nb_colonne+=yyleng; }
">="            { rechercher(">=","GE","sep","-",3); return GE; nb_colonne+=yyleng; }
"<="            { rechercher("<=","LE","sep","-",3); return LE; nb_colonne+=yyleng; }
">"             { rechercher(">","GT","sep","-",3); return GT; nb_colonne+=yyleng; }
"<"             { rechercher("<","LT","sep","-",3); return LT; nb_colonne+=yyleng; }

"AND"           { rechercher("AND","AND","mot_cle","-",2); return AND; nb_colonne+=yyleng; }
"OR"            { rechercher("OR","OR","mot_cle","-",2); return OR; nb_colonne+=yyleng; }
"NOT"           { rechercher("NOT","NOT","mot_cle","-",2); return NOT; nb_colonne+=yyleng; }

"+"  { int i=0; rechercher("+", "PLUS", "", "", 3); nb_colonne += yyleng; return PLUS; }
"-"  { int i=0; rechercher("-", "MINUS", "", "", 3); nb_colonne += yyleng; return MINUS; }
"*"  { int i=0; rechercher("*", "MUL", "", "", 3); nb_colonne += yyleng; return MUL; }
"/"  { int i=0; rechercher("/", "DIV", "", "", 3); nb_colonne += yyleng; return DIV; }
";"  { int i=0; rechercher(";", "SEMICOL", "", "", 3); nb_colonne += yyleng; return SEMICOL; }
","  { int i=0; rechercher(",", "COMMA", "", "", 3); nb_colonne += yyleng; return ','; }
":"  { int i=0; rechercher(":", "COLON", "", "", 3); nb_colonne += yyleng; return ':'; }

"{"             { rechercher("{","LBRACE","sep","-",3); return LBRACE; nb_colonne+=yyleng; }
"}"             { rechercher("}","RBRACE","sep","-",3); return RBRACE; nb_colonne+=yyleng; }
"("             { rechercher("(","LPAREN","sep","-",3); return LPAREN; nb_colonne+=yyleng; }
")"             { rechercher(")","RPAREN","sep","-",3); return RPAREN; nb_colonne+=yyleng; }
"["             { rechercher("[","LBRACKET","sep","-",3); return LBRACKET; nb_colonne+=yyleng; }
"]"             { rechercher("]","RBRACKET","sep","-",3); return RBRACKET; nb_colonne+=yyleng; }

{IDF}  { yylval.str = strdup(yytext); rechercher(yytext,"IDF","-", "-",1); nb_colonne+=yyleng; return IDF; }
{CST}  { yylval.ival = atoi(yytext); rechercher(yytext,"CST","int",yytext,1); nb_colonne+=yyleng; return CST; }
{CHAINE}        { return CHAINE; nb_colonne+=yyleng; }

{CMNT}          { }

[ \t]+          { nb_colonne+=yyleng; }
\n              { nb_ligne++; nb_colonne=1; }

.               { printf("Erreur lexicale sur '%s' à la ligne %d\n",yytext,nb_ligne); }

%%

int yywrap(){ return 1; }

