%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "st.h"

int yylex();
int yyerror(char const *);
void printOutput();

int lines=1;
int numAds=0;
int numOffers=0;
%}
%union{
    int integer;
    char *string;
}
%start Input
%error-verbose

%token SPACE NL OP_ASSIGN
%token DATE_DESC DATE MAIN_SEP

%token AD_TYPE_DESC AD_MT_DESC AD_LOCATION_DESC AD_PRICE_DESC AD_MINPRICERANGE_DESC AD_ID_DESC
%type <integer> AdPriceMinRangeRow AdPriceRow
%token <integer> AD_PRICE_VALUE AD_MINPRICERANGE_VALUE
%token <string> AD_TYPE_VALUE AD_MT_VALUE AD_LOCATION_VALUE AD_ID_VALUE
%type <string> AdTypeRow AdMtRow AdLocationRow AdIdRow


%token <integer> OFFER_PRICE_VALUE
%type <integer> Offer_PriceRow
%token <string> OFFER_FULL_NAME_VALUE OFFER_LOCATION_VALUE OFFER_ID_VALUE
%type <string> Offer_NameRow Offer_LocationRow Offer_IdRow
/*%token AD_MT_VALUE AD_LOCATION_VALUE AD_PRICE_VALUE AD_MINPRICERANGE_VALUE AD_ID_VALUE*/
%token AD_SEP

%token OFFER_HEADER OFFER_SEP
%token OFFER_FULL_NAME_DESC OFFER_LOCATION_DESC OFFER_ID_DESC OFFER_PRICE_DESC
/*%token OFFER_FULL_NAME_VALUE OFFER_LOCATION_VALUE OFFER_ID_VALUE OFFER_PRICE_VALUE*/
%%
Input: Date Ads MAIN_SEP OffersSection {++lines;}
;

OffersSection:
| NL OFFER_HEADER NL Offers
| NL OFFER_HEADER

Date: DATE_DESC DATE NL {++lines;}
;

Ads: Ad AD_SEP NL Ads {++lines;}
| Ad
;

Ad: AdTypeRow AdMtRow AdLocationRow AdPriceRow AdPriceMinRangeRow AdIdRow {
    ad_node* ad = insTokenAd($6);
    ad->type = strdup($1);
    ad->mt = strdup($2);
    ad->location = strdup($3);
    ad->price = $4;
    ad->minPriceRange = $4 - $5;
    printf(">>> Parsed Ad #:%d \n",++numAds);
  }
;

AdTypeRow: AD_TYPE_DESC OP_ASSIGN SPACE AD_TYPE_VALUE NL {
    // printf(">>> AdTypeRow: %s\n", $4);
    ++lines;
    $$ = $4
  }
;

AdMtRow: AD_MT_DESC OP_ASSIGN SPACE AD_MT_VALUE NL {
    // printf(">>> AdMtRow: %s\n", $4);
    ++lines;
    $$ = $4
  }
;

AdLocationRow: AD_LOCATION_DESC OP_ASSIGN SPACE AD_LOCATION_VALUE NL {
    // printf(">>> AdLocationRow: %s\n", $$);
    ++lines;
    $$ = $4
  }
;

AdPriceRow: AD_PRICE_DESC OP_ASSIGN SPACE AD_PRICE_VALUE NL {
    // printf(">>> AdPriceRow: %s\n", $4);
    ++lines;
    $$ = $4
  }
;

AdPriceMinRangeRow: AD_MINPRICERANGE_DESC OP_ASSIGN SPACE AD_MINPRICERANGE_VALUE NL {
    // printf(">>> AdPriceMinRangeRow: %s\n", $4);
    ++lines;
    $$ = $4;
  }
;

AdIdRow: AD_ID_DESC OP_ASSIGN SPACE AD_ID_VALUE NL {
    // printf(">>> AdIdRow: %s\n", $4);
    ++lines;
    $$ = $4;
  }
;

Offers: {
    printf("Non è presente offerta #:%d\n",++numOffers);
  }
| OffersRec
;
OffersRec: Offer NL OFFER_SEP NL OffersRec {++lines;}
| Offer
;

Offer: Offer_NameRow Offer_LocationRow Offer_IdRow Offer_PriceRow {
    int ins = insOffer($3, $1, $2, $4);
    if (ins == 2) {
      printf("Line:%d >>> Annuncio %s non trovato\n",lines, $3);
    }
    else if (ins == 1) {
      printf("Line:%d >>> L'Offerta non ha un sufficiente importo per l'annuncio %s\n",lines, $3);
    }
    printf(">>>>Parsed Offer #:%d\n",++numOffers);
  }
;

Offer_NameRow: OFFER_FULL_NAME_DESC OP_ASSIGN SPACE OFFER_FULL_NAME_VALUE NL {
    // printf(">>> Offer_NameRow: %s\n", $4);
    ++lines;
    $$ = $4;
  }
;

Offer_LocationRow: OFFER_LOCATION_DESC OP_ASSIGN SPACE OFFER_LOCATION_VALUE NL  {
    // printf(">>> Offer_LocationRow: %s\n", $4);
    ++lines;
    $$ = $4;
  }
;

Offer_IdRow: OFFER_ID_DESC OP_ASSIGN SPACE OFFER_ID_VALUE NL {
    // printf(">>> Offer_IdRow: %s\n", $4);
    ++lines;
    $$ = $4;
  }
;

Offer_PriceRow: OFFER_PRICE_DESC OP_ASSIGN SPACE OFFER_PRICE_VALUE {
    // printf(">>> Offer_PriceRow: %s\n", $4);
    ++lines;
    $$ = $4;
  }
;

%%

int main(int argc, char** argv) {
  int k = 0;
  for (k = 0; k < HASH_SIZE; k++)
    st[k] = NULL;

  yyparse();
  printf("\n Lines Parsed : %d\n",lines);
  // stPrint();

  printf("\n *********** OUTPUT *********** \n");
  printOutput();
  return 0;
}

int yyerror(char const *s) {
  printf("\nLinea %d: %s\n",lines,s);
  exit(1);
}

void printOutput() {
  int k;
  ad_node* a;
  offer_node* b;
  int firstOffer;
  FILE *f = fopen("output.txt", "w");
  if (f == NULL)
  {
      printf("Error opening file!\n");
      exit(1);
  }

  for (k = 0; k < HASH_SIZE; k++) {
     if (st[k] != NULL){

       for (a = st[k]; a != NULL; a = a->next) {
        printf("%s: ", a->id);
        fprintf(f, "%s: ", a->id);
        b = a->offers;
        firstOffer = 1;
        if (b == NULL)
        {
          printf("Nessuna Offerta");
          fprintf(f, "Nessuna Offerta");
        }
        else {
          for (; b != NULL; b = b->next)
          {
            if (firstOffer)
            {
              firstOffer = 0;
              printf("%s > %d", b->fullName, b->value);
              fprintf(f, "%s > %d", b->fullName, b->value);
            } else {
              printf("; %s > %d", b->fullName, b->value);
              fprintf(f, "; %s > %d", b->fullName, b->value);
            }

          }

        }
        printf("\n");
        fprintf(f, "\n");
    }
  }

  }
  fclose(f);
}
