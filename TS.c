#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TS.h"

//LES POINTEURS DES TETE DES LISTES
TSNode* TS_head = NULL;
SMNode* M_head = NULL;
SMNode* S_head = NULL;

//INITIALISATION:
void initialisation() {
    TS_head = NULL;
    M_head = NULL;
    S_head = NULL;
}

//INSERTIONS:
void inserer_TS(char* entite, char* code, char* type, char* val) {
    TSNode* newNode = (TSNode*)malloc(sizeof(TSNode));

    strcpy(newNode->name, entite);
    strcpy(newNode->code, code);
    strcpy(newNode->type, type);
    strcpy(newNode->val, val);

    newNode->next = TS_head;
    TS_head = newNode;
}

void inserer_SM(SMNode** head, char* entite, char* type) {
    SMNode* newNode = (SMNode*)malloc(sizeof(SMNode));

    strcpy(newNode->name, entite);
    strcpy(newNode->type, type);

    newNode->next = *head;
    *head = newNode;
}

// SEARCH:
int exists_TS(char* entite) {
    TSNode* cur = TS_head;
    while (cur != NULL) {
        if (strcmp(cur->name, entite) == 0)
            return 1;
        cur = cur->next;
    }
    return 0;
}

int exists_SM(SMNode* head, char* entite) {
    SMNode* cur = head;
    while (cur != NULL) {
        if (strcmp(cur->name, entite) == 0)
            return 1;
        cur = cur->next;
    }
    return 0;
}

//RECHERCHER:
void rechercher(char entite[], char code[], char type[], char val[], int y) {

    switch (y) {

        case 1: // IDF + CST
            if (!exists_TS(entite))
                inserer_TS(entite, code, type, val);
            // Removed message for duplicate IDF/CST
            break;

        case 2: // keywords
            if (!exists_SM(M_head, entite))
                inserer_SM(&M_head, entite, code);
            // Removed message for duplicate keywords
            break;

        case 3: // separators
            if (!exists_SM(S_head, entite))
                inserer_SM(&S_head, entite, code);
            // Removed message for duplicate separators
            break;

        default:
            printf(">>>> Erreur: type de table inconnu\n");
    }
}

// AFFICHER:
void afficher_TS() {
    printf("\n/*************** Table des IDF et CONST ***************/\n");
    printf("| %-15s | %-10s | %-10s | %-10s |\n", 
           "Nom", "Code", "Type", "Val");
    printf("---------------------------------------------------------\n");

    TSNode* cur = TS_head;
    while (cur != NULL) {
        printf("| %-15s | %-10s | %-10s | %-10s |\n",
            cur->name, cur->code, cur->type, cur->val);
        cur = cur->next;
    }
}

void afficher_SM(SMNode* head, char* titre) {
    printf("\n/*************** %s ***************/\n", titre);
    printf("| %-15s | %-10s |\n", "Nom", "Code");
    printf("--------------------------------------\n");

    SMNode* cur = head;
    while (cur != NULL) {
        printf("| %-15s | %-10s |\n", cur->name, cur->type);
        cur = cur->next;
    }
}

void afficher() {
    afficher_TS();
    afficher_SM(M_head, "Table des mots cles");
    afficher_SM(S_head, "Table des separateurs");
}

// ========== SEMANTIC ANALYSIS FUNCTIONS ==========

// Check if a variable is declared
int is_declared(char* name) {
    TSNode* cur = TS_head;
    while (cur != NULL) {
        if (strcmp(cur->name, name) == 0 && strcmp(cur->code, "IDF") == 0) {
            // Check if it has a type (meaning it was declared)
            // Variables inserted by lexer have type "-"
            if (strcmp(cur->type, "") != 0 && 
                strcmp(cur->type, "?") != 0 && 
                strcmp(cur->type, "-") != 0) {
                return 1;
            }
        }
        cur = cur->next;
    }
    return 0;
}

// Get the type of a variable (1 = INT, 2 = FLOAT, -1 = ERROR)
int get_type(char* name) {
    TSNode* cur = TS_head;
    while (cur != NULL) {
        if (strcmp(cur->name, name) == 0 && strcmp(cur->code, "IDF") == 0) {
            if (strcmp(cur->type, "Entier") == 0) {
                return 1; // TYPE_INT
            } else if (strcmp(cur->type, "Reel") == 0) {
                return 2; // TYPE_FLOAT
            }
        }
        cur = cur->next;
    }
    return -1; // TYPE_ERROR
}

// Declare a variable with a type
void declare_variable(char* name, int type) {
    TSNode* cur = TS_head;
    char* type_str = (type == 1) ? "Entier" : "Reel";
    
    // First check if the IDF already exists in the table
    while (cur != NULL) {
        if (strcmp(cur->name, name) == 0 && strcmp(cur->code, "IDF") == 0) {
            // Update the type - ALWAYS update even if it has a type
            strcpy(cur->type, type_str);
            return;
        }
        cur = cur->next;
    }
    
    // If not found, insert new entry
    inserer_TS(name, "IDF", type_str, "");
}

// Check if a variable is already declared (for duplicate detection)
int check_duplicate(char* name) {
    int count = 0;
    TSNode* cur = TS_head;
    
    while (cur != NULL) {
        if (strcmp(cur->name, name) == 0 && strcmp(cur->code, "IDF") == 0) {
            // If it has a type (not "-" and not "?" and not ""), it's declared
            if (strcmp(cur->type, "-") != 0 && 
                strcmp(cur->type, "?") != 0 && 
                strcmp(cur->type, "") != 0) {
                count++;
                if (count > 1) {
                    return 1; // Found duplicate declaration
                }
            }
        }
        cur = cur->next;
    }
    return 0; // Not a duplicate
}

// Update the type of an existing variable
void update_type(char* name, char* type) {
    TSNode* cur = TS_head;
    while (cur != NULL) {
        if (strcmp(cur->name, name) == 0 && strcmp(cur->code, "IDF") == 0) {
            strcpy(cur->type, type);
            return;
        }
        cur = cur->next;
    }
}