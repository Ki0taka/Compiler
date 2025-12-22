#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

//STRUCTURES DES TS:

typedef struct TSNode {
    char name[20];
    char code[20];
    char type[20];
    char val[20];
    struct TSNode* next;
} TSNode;

typedef struct SMNode {
    char name[20];
    char type[20];
    struct SMNode* next;
} SMNode;

//LES TETE DES LISTES:
extern TSNode* TS_head;   // pour les IDFs et CSTs
extern SMNode* M_head;    // mots clés
extern SMNode* S_head;    // separateurs

//LES FONCTIONS:
void initialisation();

void inserer_TS(char* entite, char* code, char* type, char* val);
void inserer_SM(SMNode** head, char* entite, char* type);

int exists_TS(char* entite);
int exists_SM(SMNode* head, char* entite);

void rechercher(char entite[], char code[], char type[], char val[], int y);

void afficher();

// SEMANTIC ANALYSIS FUNCTIONS
int is_declared(char* name);
int get_type(char* name);
void declare_variable(char* name, int type);
int check_duplicate(char* name);
void update_type(char* name, char* type);

#endif
