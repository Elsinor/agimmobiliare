/*
Symbol Table Implementation
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "st.h"




// Dichiarazione della funzione di hash
hashcode h(char* s) {
  int c = 0;
  for (; *s!='\0'; s++)
    c = (127 * c + *s) % HASH_SIZE;
  return c;
}

// Dichiarazione della funzione di lookup
ad_node* lu (char* id) {
  ad_node* a;
  for (a = st[h(id)]; a != NULL; a = a->next)
    if (strcmp(id, a->id) == 0)
      return a;
  return NULL;

}

// Dichiarazione della funzione di inserimento attributo
int insOffer(char* id, char* fullName, char* birthPlace, int value) {
  ad_node* a;
  offer_node* b;
  a = lu(id);
  if (a != NULL) {
    //printf("%s: %d >= %d\n", fullName, value, a->minPriceRange);
    if (value >= a->minPriceRange)
    {
      if ((b = (offer_node*) malloc(sizeof(*b))) == NULL)
        return NULL;
        b->fullName = strdup(fullName);
        b->birthPlace = strdup(birthPlace);
        b->value = value;

      if (a->offers == NULL)
      {
        a->offers = b;
        b->next = NULL;
      } else {
        b->next = a->offers;
        //for (; a->offers->next == NULL; a->offers = a->offers->next);
        a->offers = b;
      }


    } else
    return 1;

  } else
    return 2;
  return 0;
}

// Dichiarazione della funzione di inserimento token
ad_node* insTokenAd(char* id) {
  ad_node* a; hashcode c;
  if ((a = lu(id)) == NULL) {
    if ((a = (ad_node*) malloc(sizeof(*a))) == NULL)
      return NULL;
    a->id = strdup(id);
    a->offers = NULL;
    c = h(id);
    a->next = st[c];
    st[c] = a;
  }
  return a;
}

void stPrint() {
  int k;
  ad_node* a;
  for (k = 0; k < HASH_SIZE; k++) {
    printf("[%d]: ", k);
    for (a = st[k]; a != NULL; a = a->next)
      printf("[%s]", a->id);
    printf("\n");
  }
}
