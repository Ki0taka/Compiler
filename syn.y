%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TS.h"
extern int nb_ligne;
extern int nb_colonne;
int yylex();
extern void afficher();
void yyerror(const char *s);

int is_declared(char* name);
int get_type(char* name);
void declare_variable(char* name, int type);
int check_duplicate(char* name);
void semantic_error(const char* msg);

#define TYPE_INT 1
#define TYPE_FLOAT 2
#define TYPE_ERROR -1

int semantic_errors = 0;

char* id_list[100];
int id_count = 0;

void add_id_to_list(char* name) {
    id_list[id_count++] = strdup(name);
}

void process_id_list(int type) {
    for (int i = 0; i < id_count; i++) {
        if (check_duplicate(id_list[i])) {
            char msg[100];
            sprintf(msg, "Variable '%s' deja declaree", id_list[i]);
            semantic_error(msg);
        } else {
            declare_variable(id_list[i], type);
        }
        free(id_list[i]);
    }
    id_count = 0;
}
%}

%union {
    char* str;
    int type;
    int ival;
}

%token MC_MAIN DEC T_INT T_FLOAT BODY BEG END WRITE
%token IF ELSE ENDIF FOR DE A PAS DO WHILE
%token <str> IDF CHAINE
%token <ival> CST
%token PLUS MINUS MUL DIV EQ NE LT LE GT GE ASSIGN
%token AND OR NOT
%token LBRACE RBRACE LPAREN RPAREN LBRACKET RBRACKET SEMICOL

%type <type> TYPE EXPR

%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left MUL DIV
%right NOT

%%

S : MC_MAIN IDF SEMICOL DEC_PART BODY_PART {
    if (semantic_errors == 0) {
        printf("Syntaxe correcte\n");
        printf("Analyse semantique: Aucune erreur\n");
    } else {
        printf("Analyse semantique: %d erreur(s) detectee(s)\n", semantic_errors);
    }
};

DEC_PART : DEC DECLS ;

DECLS : DECLS DECL | DECL ;

DECL : IDS ':' TYPE SEMICOL {
    process_id_list($3);
};

IDS : IDF {
    add_id_to_list($1);
}
| IDF ',' IDS {
    add_id_to_list($1);
};

TYPE : T_INT { $$ = TYPE_INT; }
| T_FLOAT { $$ = TYPE_FLOAT; };

BODY_PART : BODY BEG LBRACE INSTS RBRACE END ;

INSTS : INST | INSTS INST ;

INST : AFFECT SEMICOL
| WRITE LPAREN CHAINE RPAREN SEMICOL
| COND
| LOOP
| ARRAY_DECL SEMICOL ;

AFFECT : IDF ASSIGN EXPR {
    if (!is_declared($1)) {
        char msg[100];
        sprintf(msg, "Variable '%s' non declaree", $1);
        semantic_error(msg);
    } else {
        int var_type = get_type($1);
        int expr_type = $3;
        if (var_type != expr_type && expr_type != TYPE_ERROR && var_type != TYPE_ERROR) {
            char msg[150];
            sprintf(msg, "Incompatibilite de type pour '%s': %s attendu",
                $1, var_type == TYPE_INT ? "INT" : "FLOAT");
            semantic_error(msg);
        }
    }
};

ARRAY_DECL : IDF LBRACKET CST RBRACKET {
    if (!is_declared($1)) {
        char msg[100];
        sprintf(msg, "Tableau '%s' non declare", $1);
        semantic_error(msg);
    }
    if ($3 <= 0) {
        char msg[100];
        sprintf(msg, "Taille du tableau doit etre positive (obtenu: %d)", $3);
        semantic_error(msg);
    }
};

EXPR : EXPR PLUS EXPR {
    if ($1 == TYPE_ERROR || $3 == TYPE_ERROR) {
        $$ = TYPE_ERROR;
    } else if ($1 == TYPE_FLOAT || $3 == TYPE_FLOAT) {
        $$ = TYPE_FLOAT;
    } else {
        $$ = TYPE_INT;
    }
}
| EXPR MINUS EXPR {
    if ($1 == TYPE_ERROR || $3 == TYPE_ERROR) {
        $$ = TYPE_ERROR;
    } else if ($1 == TYPE_FLOAT || $3 == TYPE_FLOAT) {
        $$ = TYPE_FLOAT;
    } else {
        $$ = TYPE_INT;
    }
}
| EXPR MUL EXPR {
    if ($1 == TYPE_ERROR || $3 == TYPE_ERROR) {
        $$ = TYPE_ERROR;
    } else if ($1 == TYPE_FLOAT || $3 == TYPE_FLOAT) {
        $$ = TYPE_FLOAT;
    } else {
        $$ = TYPE_INT;
    }
}
| EXPR DIV EXPR {
    if ($1 == TYPE_ERROR || $3 == TYPE_ERROR) {
        $$ = TYPE_ERROR;
    } else if ($1 == TYPE_FLOAT || $3 == TYPE_FLOAT) {
        $$ = TYPE_FLOAT;
    } else {
        $$ = TYPE_INT;
    }
}
| LPAREN EXPR RPAREN { $$ = $2; }
| CST { $$ = TYPE_INT; }
| IDF {
    if (!is_declared($1)) {
        char msg[100];
        sprintf(msg, "Variable '%s' non declaree", $1);
        semantic_error(msg);
        $$ = TYPE_ERROR;
    } else {
        $$ = get_type($1);
    }
};

COND : IF LPAREN COND_EXPR RPAREN LBRACE INSTS RBRACE ELSE_PART ENDIF SEMICOL ;

ELSE_PART : ELSE LBRACE INSTS RBRACE | ;

COND_EXPR : EXPR LT EXPR
| EXPR LE EXPR
| EXPR GT EXPR
| EXPR GE EXPR
| EXPR EQ EXPR
| EXPR NE EXPR
| COND_EXPR AND COND_EXPR
| COND_EXPR OR COND_EXPR
| NOT COND_EXPR
| LPAREN COND_EXPR RPAREN ;

LOOP : FOR IDF DE CST A CST PAS CST LBRACE INSTS RBRACE {
    if (!is_declared($2)) {
        char msg[100];
        sprintf(msg, "Variable de boucle '%s' non declaree", $2);
        semantic_error(msg);
    } else {
        int var_type = get_type($2);
        if (var_type != TYPE_INT) {
            char msg[100];
            sprintf(msg, "Variable de boucle '%s' doit etre de type INT", $2);
            semantic_error(msg);
        }
    }
    if ($8 == 0) {
        semantic_error("Le pas de la boucle FOR ne peut pas etre zero");
    }
    if (($8 > 0 && $4 > $6) || ($8 < 0 && $4 < $6)) {
        semantic_error("Boucle FOR infinie: verifier debut, fin et pas");
    }
}
| DO LBRACE INSTS RBRACE WHILE LPAREN COND_EXPR RPAREN SEMICOL ;

%%

void semantic_error(const char* msg) {
    printf("Erreur semantique ligne %d col %d: %s\n", nb_ligne, nb_colonne, msg);
    semantic_errors++;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erreur syntaxique ligne %d col %d: %s\n", nb_ligne, nb_colonne, s);
}

int main() {
    if (yyparse() == 0) {
        printf("\n************* Analyse syntaxique terminee *************\n");
        afficher();
    }
    return 0;
}