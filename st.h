/*
Symbol Table Header
*/

// Definizione della struttura per le offerte
typedef struct offer_node {
  struct offer_node*  next;
  char*               fullName;
  char*               birthPlace;
  int                 value;
} offer_node;

// Definizione della struttura della Symbol Table
typedef struct ad_node {
  struct offer_node*  offers;
  struct ad_node*     next;
  char*               id;
  char*               type;
  char*               mt;
  char*               location;
  int                 price;
  int                 minPriceRange;
} ad_node;

typedef unsigned int hashcode;

// Definizione della costante lunghezza della hashtable
#define HASH_SIZE 101

// Definizione della tabella hash
ad_node* st[HASH_SIZE];

// Definizione della funzione di hash
hashcode h(char* id);

// Definizione della funzione di lookup
ad_node* lu(char* id);

// Definizione della funzione di inserimento offerta
// ritorna 0 se l'offerta è maggiore di minPriceRange del rispettivo ad_node con l'id
// ritorna 1 se l'offerta non dev'essere presa in considerazione e quindi non aggiunta alla lista.
// ritorna 2 se il token non è stato trovato.
int insOffer(char* id, char* fullName, char* birthPlace, int value);

// Definizione della funzione di inserimento token
ad_node* insTokenAd(char* id);

void stPrint();
