#include <stdio.h>
#include <stdlib.h>


#include <stdint.h>
typedef uint8_t BYTE;
typedef uint16_t WORD;
typedef char CHAR;

#pragma pack(1)

#define GIF_EXTENSION           0x21

    #define GRAPHICS_CONTROL_EXT    0xF9
    #define PLAIN_TEXT_EXT          0x01
    #define COMMENT_EXT             0xFE
    #define APPLICATION_EXT         0xFF

#define IMAGE_DESCRIPTOR        0x2c

#define GIF_END                 0x3b


/* Barva PAPER kterou naznacime ze polopruhledny znak ma ponechat puvodni hodnotu PAPER */
#define FAKE_PAPER_RED      0x33
#define FAKE_PAPER_GREEN    0x33
#define FAKE_PAPER_BLUE     0x33

int alfa_prah = 34;

enum ZX_Colors {
Black = 0,          // 0
Blue,               // 1
Red,                // 2
Magenta,            // 3
Green,              // 4
Cyan,               // 5
Yellow,             // 6
White,              // 7
Light_Black ,
Light_Blue,
Light_Red,
Light_Magenta,
Light_Green,
Light_Cyan,
Light_Yellow,
Light_White,
Previous_Paper,
Alfa };


typedef struct _GifHeader {
    // Header                
    char    Signature[3];       /* oznaceni, vzdy ("GIF") */
    char    Version[3];         /* verze, ("87a", nebo "89a") */
    WORD    ScreenWidth;        /* sirka obrazu v px */
    WORD    ScreenHeight;       /* vyska obrazu v px */
    BYTE    Packed;             /* informace o obrazove a barevne mape */
    BYTE    BackGroundColor;    /* index barvy pozadi */
    BYTE    AspectRatio;        /* pomer stran obrazku */
} GIFHEAD;


typedef struct _GifGraphicsControlExtension {
    /* 21h identifikator Gif rozsireni */
    /* F9h Gif Graphics Control Extension */
    BYTE    BlockSize;          /* velikost ostatnich poli, vzdy 04h */
    BYTE    Packed;             /* metoda, pomoci ktere se bude pracovat s grafikou */
    WORD    DelayTime;          /* pauza v desetinach vteriny */
    BYTE    ColorIndex;         /* index pruhledne barvy */
    BYTE    Terminator;         /* terminator bloku, vzdy 0 */
} GCE;


typedef struct _GifImageDescriptor {
    /* 2Ch indetifikator Gif Image Descriptoru */
    WORD    Left;               /* souradnice X obrazku na obrazovce */
    WORD    Top;                /* souradnice Y obrazku na obrazovce    */
    WORD    Width;              /* vyska obrazku v px */
    WORD    Height;             /* sirka obrazku v px */
    BYTE    Packed;             /* informace o obrazove a barevne mape */
} GIFIMGDESC;


typedef struct _GifPlainTextExtension {
    /* 21h identifikator Gif rozsireni */
    /* 01h Gif Plaint Text Extension */
    BYTE     BlockSize;         /* velikost bloku rozsireni */
    WORD    TextGridLeft;       /* X-ova pozice textoveho ramecku v px */
    WORD    TextGridTop;        /* Y-ova pozice textoveho ramecku v px */
    WORD    TextGridWidth;      /* sirka textoveho ramecku v px */
    WORD    TextGridHeight;     /* vyska textoveho ramecku v px */
    BYTE    CelWidth;           /* sirka pola v px */
    BYTE    CelHeight;          /* vyska pola v px */
    BYTE    TextFgColor;        /* barva textu (index) */
    BYTE    TextBgColor;        /* barva pozadi (index) */
//     BYTE    *PlainTextData;  /* vlastni ASCII text */
//     BYTE    Terminator;      /* terminator bloku, vzdy 0 */
} GIFPLAINTEXT;


// typedef struct _GifCommentExtension {
    /* 21h identifikator Gif rozsireni */
    /* FEh Gif Comment Extension */
//     BYTE    *CommentData;    /* delka dalsi casti komentare */
//     BYTE    Terminator;      /* terminator, vzdy 0 */
// } GIFCOMM;




typedef struct _GifApplicationExtension {
    /* 21h identifikator Gif rozsireni */
    /* FFh Gif Application Extension */
    BYTE    BlockSize;          /* velikost bloku rozsireni, vzdy 0Bh */
    CHAR    IdApplication[8];   /* identifikator aplikacie    */    
    BYTE    AuthentCode[3];     /* opravňovací kód aplikacie */
//     BYTE    *ApplicationData;    /* pointer na subbloky príslušnych dat    */
//     BYTE    Terminator;      /* terminator bloku, vzdy 0    */
} GIFAPPLICATION;


typedef struct
{
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    //unsigned char reserved; Removed for convenience in fread; info.bitDepth/8 doesn't seem to work for some reason
} RGB;


void ViewHeader( GIFHEAD * Head, int numGColors ) 
{
    int color = 1;
    color <<= 1 + ((Head->Packed & 0x70) >> 4);
    
    printf( 
      "Gif Header\n" 
      "\t%c%c%c\t:Signature\n"  
      "\t%c%c%c\t:Version\n" 
      "\t%u\t:Logical Screen Width\n" 
      "\t%u\t:Logical Screen Height\n"\
//       packed
      "\t  %s\t:Global Table Color\n" 
      "\t  %u\t:Puvodni pocet barev\n" 
      "\t  %s\t:Barvy trideny od nejvyznamnejsich\n" 
      "\t  %i\t:Pocet barev v palete\n" 
      
      "\t%i\t:Background Color Index\n" 
      "\t%i\t:Pixel Aspect Ratio\n",
      Head->Signature[0], Head->Signature[1], Head->Signature[2],
      Head->Version[0], Head->Version[1], Head->Version[2],
      Head->ScreenWidth,
      Head->ScreenHeight,
//       packed
      (Head->Packed & 0x80) ? "true" : "false",
      color,
      (Head->Packed & 0x08) ? "true" : "false",
      numGColors,
      
      Head->BackGroundColor,
      Head->AspectRatio );
}


void ViewGraphicControlExtension( GCE * gce ) 
{
    printf( "Gif Graphic Control Extension\n" );

    printf( "\t%#04x\t= 0x04 (BlockSize)\n", gce->BlockSize );
    printf( "\t%s\t:Pruhledna barva\n", (gce->Packed & 0x01) ? "true" : "false");
    printf( "\t%s\t:Ceka se na uzivateluv vstup\n", (gce->Packed & 0x02) ? "true" : "false");
    printf( "\t%u\t:0 nespecifikovano, 1 nemenit, 2 prepsat pozadim, 4 prepsat predchozimi daty\n", (gce->Packed & 0x1C) >> 2 ); 
    printf( "\t%u\t:Rezervovane\n", (gce->Packed & 0xE0) >> 5 );     
    printf( "\t%u\t:DelayTime\n", gce->DelayTime );
    printf( "\t%i\t:Index pruhledne barvy\n", gce->ColorIndex );
    printf( "\t%i\t= 0\n", gce->Terminator );
}


void ViewPlainTextExtensionBlock( GIFPLAINTEXT * gpt )
{
    printf( "\t%i\t= 0x0c BlockSize\n", gpt->BlockSize );
    
    printf( "\t%u\t:X-ova pozice textoveho ramecku v px\n", gpt->TextGridLeft );
    printf( "\t%u\t:Y-ova pozice textoveho ramecku v px", gpt->TextGridTop);
    printf( "\t%u\t:sirka textoveho ramecku bodoch",gpt->TextGridWidth);
    printf( "\t%u\t:vyska textoveho ramecku v px",gpt->TextGridHeight);
    printf( "\t%i\t:sirka pola v px",gpt->CelWidth);
    printf( "\t%i\t:vyska pola v px",gpt->CelHeight);
    printf( "\t%i\t:barva textu (index)",gpt->TextFgColor);
    printf( "\t%i\t:barva pozadi (index)",gpt->TextBgColor);
}

void ViewGifImageDescriptor( GIFIMGDESC * idesc, int numLColors ) 
{
    printf( "\t%u\t:X pocatku obrazku\n", idesc->Left );
    printf( "\t%u\t:Y pocatku obrazku\n", idesc->Top );
    printf( "\t%u\t:Width\n", idesc->Width );
    printf( "\t%u\t:Height\n", idesc->Height );
    
    printf( "\t  %s\t:Lokalni tabulka barev\n", (idesc->Packed & 0x80) ? "true" : "false");
    printf( "\t  %s\t:Prokladany (interlaced) obrazek\n", (idesc->Packed & 0x40) ? "true" : "false" ); 
    printf( "\t  %s\t:Trideni barev od nejvyznamnejsich\n", (idesc->Packed & 0x20) ? "true" : "false");
    printf( "\t  %u\t:Rezervovane\n", (idesc->Packed & 0x18) >> 3 );
    printf( "\t  %u\t:Pocet barev lokalni tabulky barev\n", numLColors ); 
       
}


void ViewAplication( GIFAPPLICATION * gap ) 
{
    printf( "Gif Application\n" );

    printf( "\t%i\t= 0x0b BlockSize\n", gap->BlockSize );
    printf( "\t%8s\tApplication Label\n", gap->IdApplication );
    printf( "\t%#04x %#04x %#04x\t Authentication Code\n", gap->AuthentCode[0], gap->AuthentCode[1], gap->AuthentCode[2] );       
}


void ViewPalette( int Colors, RGB * Palette )
{
    int i;
    for ( i = 0; i < Colors; i++ ) {
         printf( "\t%4i %#04x %#04x %#04x :iRGB\n",i ,Palette[i].red, Palette[i].green, Palette[i].blue );
    }
}




void Nacti(void * kam, int velikost, unsigned kolikrat, FILE *odkud, char * varovani ) {
    if( fread( kam, velikost, kolikrat, odkud) != kolikrat ) {
        fprintf(stderr, "Error reading %s.\n", varovani );
        exit (-1);
    }  
}


int CtiBitovyProud(BYTE * Buff, int * index, int sirka_cisla, int * uz_nacteno_bitu )
{
    int ctene;
    int maska_cisla;
    
    maska_cisla = ~0;
    maska_cisla <<= sirka_cisla;
    maska_cisla = ~maska_cisla;
    
    ctene = *Buff;
    ctene += *(++Buff) << 8;        // do 9 bitu
    ctene += *(++Buff) << 16;        // do 17 bitu
    ctene >>= *uz_nacteno_bitu;
    ctene &= maska_cisla;
    *uz_nacteno_bitu += sirka_cisla;
    while ( *uz_nacteno_bitu > 7 ) {
        *uz_nacteno_bitu -= 8;
        *index += 1;
    }
    
    return ctene;
}




#define MAXSLOVNIK    16384
#define MAXSLOVO    1024

typedef struct
{
    BYTE    hodnota;
    WORD    predchozi;
} SLOVO;


typedef struct
{
    int vyska;
    int sirka;
    int pocet_barev;
    int alfa_index;
    BYTE *palette;
    BYTE *screen_buf;
} PICTURE;


void DecodeBuff(BYTE * Buff, PICTURE *screen, int minimalni_sirka ) {

    int kod;                        // nacteny n-bitovy kod z bitoveho streamu
    int i;                          // index aktivniho bajtu do bufferu
    int kod_size;                   // aktualni sirka ctenych kodu v bitech
    int uz_nacteno_bitu = 0;        // kolik nejnizsich bitu aktualniho bajtu zahodime / jsou uz precteny
    int clearcode = ( 1 << (minimalni_sirka-1) );    // signal pro vymazani slovniku
    int stopcode = clearcode + 1;   // signal ukonceni cteni streamu
    int kod_overflows;              // prvniho hodnota ktera potrebuje uz vic bitu pro nacteni z bitoveho proudu
    int new;                        // aktualni nejvyssi index do slovniku
    int predchozi;                  // predchozi nacteny kod z bitoveho proudu

    SLOVO Slovnik[4096];
    
// inicializace slovniku
    i = clearcode;
    while ( i-- ) Slovnik[i].hodnota = i;
    i++;        // = 0

    int sum = 0;
#if INFO
    printf("Ctene kody:");
#endif
// cteni prvniho kodu
    kod = CtiBitovyProud( &(Buff[i]), &i, minimalni_sirka, &uz_nacteno_bitu );
#if INFO
    printf(" %i", kod );    
    if ( kod == clearcode ) printf(" = Clear Code");
    else {
        printf(" Prvni kod se nerovna Clear Code (%i)!\n", clearcode );
    }
#endif

after_clearcode:
    new = stopcode + 1;
    kod_overflows = clearcode << 1;
    kod_size = minimalni_sirka;
#if INFO
    printf("\n\t%i-bit", kod_size );
#endif
// cteni prvniho skutecneho kodu, ktery se neuklada do slovniku    
    kod = CtiBitovyProud( &(Buff[i]), &i, kod_size, &uz_nacteno_bitu );
#if INFO
    printf(" %i", kod );
#endif
// prvni kod je vzdy mensi jak clearcode, zatim nic neobsahuje, ani predchozi neni takze nemuze byt ani roven new
    screen->screen_buf[sum++] = kod;    
    predchozi = kod;

// cteni dalsich kodu, pokazde se vytvori nove slovo ve slovniku
    while ( 1 ) {
        kod = CtiBitovyProud( &(Buff[i]), &i, kod_size, &uz_nacteno_bitu );
#if INFO
        printf(" %i", kod );
#endif
        if ( kod == stopcode  ) {
#if INFO
            printf(" = Stop Code\n");
#endif
            break;
        }

        if ( kod == clearcode ) {
#if INFO
            printf(" = Clear Code\n");
#endif
            goto after_clearcode;    // alias "double break"
        }
        
        int m,n;
        
        int nenalezen = (kod == new);    // posledni kod nebyl nalezen ve slovniku
        if ( nenalezen ) m = predchozi; else m  = kod;
        
// vypis indexu do palety na indexstream
        
// prvne zjistime pocet znaku slova
        n = m;
        while ( n > stopcode ) {
            n = Slovnik[n].predchozi;
            sum++;
        }
        int prvni = n; // prvni index slova
        
// tisk indexu pozpatku
        n = m;
        m = sum;
        while ( 1 ) {
            screen->screen_buf[sum--] = Slovnik[n].hodnota;
            if ( n < stopcode ) break;
            n = Slovnik[n].predchozi;
        }
        sum = m + 1;

// mame jeste vytisknout jeden znak?
        if ( nenalezen ) screen->screen_buf[sum++] = prvni;
        

        if ( new == kod_overflows ) continue; // pouze v pripade ze new = 4096

        if ( new + 1 == kod_overflows ) {
          
            if ( kod_size < 12 ) {
                kod_size++;
#if INFO
                printf("\n\t%i-bit", kod_size );
#endif
                kod_overflows <<= 1;
            }
#if INFO
            else     
                printf("\n\tdosazeno limitu 12 bitu, index do tabulky je %i\n", new );
#endif
        }

// vytvorime nove slovo ve slovniku
        Slovnik[new].hodnota = prvni;
        Slovnik[new].predchozi = predchozi;
        new++;
        predchozi = kod;
                
// cteni dalsiho kodu
    }
        
#if INFO
    int n;
    printf("\nIndex stream: ");
    for ( n = 0; n < sum; n++ ) printf("%i,", screen->screen_buf[n] );
    printf("(%i polozek) \n", sum );
#endif
}


// pokud je screen nenulovy ukazatel, bude prevadet bitovy stream na indexovy stream a ukladat do screen->screen_buf
void ReadDataSubBlocks( FILE * f, PICTURE *screen, int sirka_cisla )
{
    BYTE * Buff;
    BYTE * aktualni;
    unsigned char sum;
    long pozice;

// posunu se na konec souboru a zjistim jeho velikost a vratim se zpet
    pozice=ftell(f);
    fseek(f, 0L, SEEK_END);
    Buff = malloc(ftell(f));
    if (Buff == NULL) { 
        fprintf(stderr, "Nedostatek pameti!\n");
        exit (-1);
    }
    fseek(f,pozice,SEEK_SET);
    
    aktualni = Buff;

    while ( 1 ) {
    
        Nacti (&sum, 1, 1, f, "size data subblocks" );
    
        if ( sum == 0 ) {
#if INFO
            printf( "\t0 = Block Terminator\n" );
#endif
             if ( screen != NULL ) DecodeBuff( Buff, screen, sirka_cisla );
            return;
        }
#if INFO
        printf( "\t%i\t:velikost dalsiho bloku v bajtech\n", sum );
#endif
        Nacti ( aktualni, sum, 1, f,"data subblocks" );
        aktualni += sum;
    }

    free(Buff);
}


BYTE *zx_palette(RGB *gpal, int pocet)
{
    BYTE *ret=calloc(pocet,1);
    while ( ret != NULL && --pocet >= 0 )
    {
        if (gpal[pocet].blue == FAKE_PAPER_BLUE || gpal[pocet].red == FAKE_PAPER_RED || gpal[pocet].green == FAKE_PAPER_GREEN ) 
            ret[pocet] = Previous_Paper;
        else
        {
            if (gpal[pocet].blue  >= 0xA0 ) ret[pocet]++;
            if (gpal[pocet].red   >= 0xA0 ) ret[pocet]+=2;
            if (gpal[pocet].green >= 0xA0 ) ret[pocet]+=4;
        
            if (gpal[pocet].blue >= 0xE0 || gpal[pocet].red >= 0xE0 || gpal[pocet].green >= 0xE0 ) ret[pocet] +=8;
        }
        
// printf("r:%i g:%i b:%i -> zx: %i\n", gpal[pocet].red, gpal[pocet].green, gpal[pocet].blue, ret[pocet] );
    }
    return ret;
}

#define MEZERA	0x3F /* black black */

#define FLASH_MASK  0x80
#define BRIGHT_MASK 0x40
#define PAPER_MASK  0x38
#define INK_MASK    0x07

typedef struct {
    BYTE    Offset;       /* na data */
    BYTE    width;        /* sirka ve znacich */
    BYTE    height;       /* vyska ve znacich */
    /* atributy */
    /* data */
} ZXPIC;

/*
; nasleduje Atribute data jednotlivych znaku ...
; nasleduje pixel data znaku po 8 bajtech ( pripadne 16 pokud znak obsahuje masku )... ( neda se zjistit delka, protoze nektere znaky mohou mit jen atribut )
; znaky jsou ulozeny prednostne dolu po sloupci a pak zpet nahoru a doprava na novy sloupec

; Specialni hodnoty atributu
; atribut = MEZERA:
;	znaci preskoc znak, je to dira v datech, predstavuje to celopruhledny znak
; atribut s PAPER nastaveno na 0:
;	znaci polopruhledny znak, INK je pomoci OR vlozeno na puvodni znak a prepsan INK v atributu ( PAPER hodnota zustava puvodni )
;	INK vzdy prebira BRIGHTNESS puvodni hodnoty ( nikdy neni nastaven v spritu )
; atribut s FLASH:
; 	znaci ze v datech je ulozena i maska kde v masce 1 je PRUHLEDNY ( ( puvodni AND maska ) OR novy )
; 	pokud i PAPER = 0 tak to znamena ze vetsina obrazku je pruhledna, ale ta drobna cast potrebuje zachovat PAPER i kdyby
; 	pod tim byla jednicka (INK), ale protoze je to mensi cast puvodniho znaku tak hodnota barvy zustane puvodni
*/


void ErrorExit(int ErrorCode, char * ErrorMessage, PICTURE *screen)
{
    free(screen->palette);
    free(screen->screen_buf);
    fprintf(stderr,"%s.\n", ErrorMessage );
    exit (ErrorCode);
}



void write_zx_format(PICTURE *screen, char * soubor)
{
    int x,y,dx,dy,i;
    
    BYTE attr_buf[screen->sirka*screen->vyska*2/64];
    int attr_sum = 0;

    BYTE data_buf[screen->sirka*screen->vyska*2/8];
    int data_sum = 0;
    
    for ( x = 0; x < screen->sirka; x += 8)
    for ( y = 0; y < screen->vyska; y += 8)
    {
        int alfa_sum = 0, ink_sum = 0, paper_sum = 0, ink = 0, paper = 0;
        
        for ( dy = 0; dy < 8; dy++)        
        for ( dx = 0; dx < 8; dx++)
        {
            i = screen->screen_buf[(y+dy) * screen->sirka + x+dx];
            if (i == screen->alfa_index ) 
                alfa_sum++;
            else 
            {
                i = screen->palette[i]; /* index z palety obrazku na index zx barvy */
                if ( ink_sum == 0 || ink == i )
                {
                    ink = i;
                    ink_sum++;
                    if ( paper_sum == 0 ) paper = ink;
                }
                else if ( paper_sum == 0 || paper == i )
                {
                    paper = i;
                    paper_sum++;
                }
                else
                {
                    fprintf(stderr, "Vic jak 2 barvy na znak! x=%i, y=%i, ink=%i, paper=%i, new=%i\n", x/8, y/8, ink, paper, i);
                    paper = i;
                    paper_sum++;
                }
            }
        }
#if INFO
    printf("x: %2i, y: %2i\n", x/8, y/8);
    printf("\talfa_sum: %i, %2ix ink: %2i, %2ix paper: %2i\n", alfa_sum, ink_sum, ink, paper_sum, paper);
#endif
        // Analyza kombinace barev
    
        if ( ink == Previous_Paper )    // $555555
        {
#if INFO
    printf("\tink = $555555 -> prohozeni ink za paper\n");
#endif
            i = paper;
            paper = ink;
            ink = i;
            // jeste by to chtelo prohodit sumy...
        }

        if ( paper == Black ) /* cerna musi vzdy jako INK, protoze cerny PAPER znamena polopruhledny znak, anebo ignoruj hodnotu barvy PAPER kdyz obsahuje masku */
        {
#if INFO
    printf("\tpaper = 0 -> prohozeni ink za paper\n");
#endif
            i = paper;
            paper = ink;
            ink = i;
            // jeste by to chtelo prohodit sumy...
        }
        
        if ( ink == paper && alfa_sum == 0 )
        {
            if ( paper == Black )    /* obe jsou cerne */
                paper = White;       /* do PAPER dame libovolnou barvu co nebude pouzite, budou same jednicky, cerny paper totiz znamena polopruhledny znak */
            else
                ink = Black;         /* barvu dame do PAPER, budou sam nuly */ 
        }

        i = (paper * 8 & PAPER_MASK) + (ink & INK_MASK);
        if ( paper != Previous_Paper && (paper | ink) > 7 ) i |= BRIGHT_MASK;
        if ( alfa_sum ) 
        {
            if ( alfa_sum == 64 )  
                i = MEZERA;             /* celopruhledny znak */
            else if ( ink == paper ) 
                i &= ~PAPER_MASK;       /* polopruhledny znak s jednou barvou (PAPER == 0)*/
            else                        /* polopruhledny s 2 barvami */
            {
                /* Pokud ma matice 8x8 prilis mnoho pruhlednych znaku, nebo primo je PAPER kreslen barvou $555555 tak bude PAPER pouzit aby vynuloval bity ale barva zustane puvodni */
                if ( alfa_sum > alfa_prah || paper == Previous_Paper )
                {
#if INFO
    printf("\talfa_sum > alfa_prah, %i > %i\n", alfa_sum, alfa_prah);
#endif
                    /* PAPER nastavime na Black */
                    i = ink & INK_MASK;   /* zachovame puvodni paper => nastavime tento na BLACK */
                    if ( ink > 7 ) i |= BRIGHT_MASK;    /* muzeme ztratit i brightness */
                }
                i |= FLASH_MASK;
            }
        }
        
#if INFO
    printf("\tattr: %02x\n", i);
#endif
        
        attr_buf[attr_sum++] = i;

        if ( i != MEZERA )
        for ( dy = 0; dy < 8; dy++)
        {
            int bits = 0;
            int mask = 0;
            
            for ( dx = 0; dx < 8; dx++)
            {
                int i = screen->screen_buf[(y+dy) * screen->sirka + x+dx];
                bits <<= 1;
                mask <<= 1;
                if ( i == screen->alfa_index )
                    mask |= 1;
                else
                    bits |= ( screen->palette[i] == ink );
            }
            if ( attr_buf[attr_sum-1]  & FLASH_MASK ) 
                data_buf[data_sum++] = mask;
            data_buf[data_sum++] = bits;            
        }
    }
    
    /* vypis dat */

    FILE *outFile = fopen( soubor, "wb" );
    if( !outFile ) 
    {
        fprintf(stderr, "Outputfile \"%s\" ", soubor );
        ErrorExit(-1,"Error opening",screen);
    }
    
    BYTE head[3];
    head[0] = attr_sum+3;
    head[1] = screen->sirka/8;
    head[2] = screen->vyska/8;
    
    printf("%02x%02x%02x\n", head[0], head[1], head[2]);

    if ( fwrite(head, sizeof(head), 1, outFile ) != 1 ) {
        fclose(outFile);
        ErrorExit(6 ,"Error write header", screen );
    }
    
    /* save atributy */
    i = -1;
    while ( ++i < attr_sum )
    {
        printf("%02x",attr_buf[i]);
        if ( attr_buf[i] != MEZERA || attr_buf[i+1] != MEZERA) 
            printf("\n");
    }
    
    if ( fwrite(attr_buf, attr_sum, 1, outFile ) != 1 ) {
        fclose(outFile);
        ErrorExit(7,"Error write Attribute Array", screen );
    }

    /* save data */
    i = -1;
    y = -1;
    
    while ( ++i < attr_sum )
    {
        if ( attr_buf[i] == MEZERA ) continue;
        
        x = 8;
        if ( attr_buf[i] & FLASH_MASK )
            x += 8;
        
        while ( x-- )
            printf("%02x",data_buf[++y]);
        printf("\n");
    }
    printf("\n");
    
    if ( fwrite(data_buf, data_sum, 1, outFile ) != 1 ) {
        fclose(outFile);
        ErrorExit(8,"Error write Data Array", screen );
    }
    
    fclose(outFile);
        
}





int main( int argc, char **argv ) {

    if ( argc == 4 )
    {
        alfa_prah = strtol(argv[3], NULL, 10);
        if ( alfa_prah <= 0 || alfa_prah >= 63 )
        {
            fprintf(stderr, "Hodnota alfa_prah musi byt v rozsahu 1-62\n\n");
            return 1;
        }
    }

    
    if ( argc < 3 && argc > 4)
    {
        fprintf(stderr, "Spatny pocet parametru! Ocekavam\n\t%s vstupni.gif vystupni\n\n", argv[0]);
        return 1;
    }
    
 // File ---------------------
    FILE *inFile;

    fprintf( stderr, "Opening file %s for reading.\n", argv[1] );

    inFile = fopen( argv[1], "rb" );
    if( !inFile ) {
        fprintf(stderr,"Error opening file %s.\n", argv[1] );
        return -1;
    }

// Header --------------------
    GIFHEAD header;
    RGB *gpal;
    int i = 0;
    unsigned char c;
    int numGColors;

    Nacti (&header, sizeof(GIFHEAD), 1, inFile, "Gif header" );
    numGColors = (header.Packed & 0x80) >> 6;    // 0 nebo 2
    numGColors <<= (header.Packed & 0x07);
#if INFO
    ViewHeader(&header, numGColors);
#endif
    if( numGColors > 0 ) {
#if INFO
        printf( "\n\tReading %lu bytes size palette.\n", sizeof(RGB) * numGColors );
#endif
        gpal = (RGB*)malloc(sizeof(RGB) * numGColors);
        Nacti (gpal, sizeof(RGB), numGColors, inFile, "global palette." );
#if INFO
        ViewPalette( numGColors, gpal );
#endif
    }
    
    PICTURE screen;
    screen.vyska = header.ScreenHeight;
    screen.sirka = header.ScreenWidth;
    if ( (screen.screen_buf = calloc(screen.vyska*screen.sirka,1)) == NULL )
    {
        fclose(inFile);
        fprintf(stderr, "Malo pameti na ulozeni obrazku do pameti.\n");
        return -1;
    }
    screen.pocet_barev = numGColors;
    screen.alfa_index = -1;
    if ((screen.palette = zx_palette(gpal, numGColors)) == NULL)
    {
        fclose(inFile);
        fprintf(stderr, "Malo pameti na ulozeni obrazku do pameti.\n");
        return -1;
    }   
// Blocks ------------------------

    while ( 1 ) {
    
        Nacti (&c, 1, 1, inFile,"next Gif frame header" );
    
// Trailer ----------------------
#if INFO
        printf( "\n\t%#04x\t= ", c);
#endif
        
        if ( c == GIF_END ) {
#if INFO
            printf( "Done.\n" );
#endif
            fclose(inFile);
            break;
        }
    
        else if ( c == GIF_EXTENSION ) {
#if INFO
            printf( "Identifier Gif Extension\n");
#endif
            Nacti (&c, 1, 1, inFile,"Gif frame label" );
#if INFO
            printf( "\t%#04x\t= ", c);
#endif
            if ( c == GRAPHICS_CONTROL_EXT ) {
                GCE gce;
                Nacti (&gce, sizeof(GCE), 1, inFile,"Gif Graphics Control Extension" );
                
                if (gce.Packed & 0x01)
                    screen.alfa_index = gce.ColorIndex;
#if INFO
                ViewGraphicControlExtension(&gce);
#endif
            }

            else if ( c == COMMENT_EXT ) {
#if INFO
                printf( "Comment Extension\n" );
#endif
                Nacti (&c, sizeof(c), 1, inFile,"Delka komentare" );
                int i = c;
#if INFO
                printf( "\t%i\t: Delka komentare\n", i );
                char c = '\t';
#endif
                for ( ; i >= 0; i-- ) {
#if INFO
                    printf("%c", c);
#endif
                    Nacti (&c, sizeof(c), 1, inFile,"Gif Comment Extension" );
                }
#if INFO
                printf( "\n\t%i\t= 0\n", c );
#endif
            }

            else if ( c == PLAIN_TEXT_EXT ) {
#if INFO
                printf( "Plain Text Extension Block\n" );
#endif
                GIFPLAINTEXT gpt;
                Nacti (&gpt, sizeof(gpt), 1, inFile,"Plain Text Extension Block" );
#if INFO
                ViewPlainTextExtensionBlock( &gpt );
#endif
                ReadDataSubBlocks( inFile, NULL, 0 );
            }

            else if ( c == APPLICATION_EXT ) {
#if INFO
                printf( "Application frame\n" );
#endif
                GIFAPPLICATION gap;
                Nacti (&gap, sizeof(gap), 1, inFile,"Application Header" );
#if INFO
                ViewAplication( &gap );
#endif
                ReadDataSubBlocks( inFile, NULL, 0 );
            }

            else {
#if INFO
                printf( "Nezname rozsireni: t%#04x\n", c );
#endif
                return -1;
            }
      
        }
        else if ( c == IMAGE_DESCRIPTOR ) {
#if INFO
            printf( "Gif Image Descriptor\n");
#endif
            GIFIMGDESC idesc;
            RGB *lpal;
            int numLColors;
            unsigned char sizeLZW;
            
            Nacti (&(idesc.Left), sizeof(GIFIMGDESC), 1, inFile, "Gif Graphics Control Extension" );
            numLColors = (idesc.Packed & 0x80) >> 6;    // 0 nebo 2
            numLColors <<= (idesc.Packed & 0x07);
#if INFO
            ViewGifImageDescriptor(&idesc, numLColors);
#endif
            if( numLColors > 0 ) {
#if INFO
                printf( "Reading %lu bytes size palette.\n", sizeof(RGB) * numLColors );
#endif
                lpal = (RGB*)malloc(sizeof(RGB) * numLColors);
                Nacti (lpal, sizeof(RGB), numLColors, inFile, "local palette" );
#if INFO
                ViewPalette( numGColors, lpal );
#endif
            }
            
            Nacti (&sizeLZW, 1, 1, inFile,"size LZW" );
            sizeLZW++;
#if INFO
            printf( "\t%i\t:velikost LZW kodu v bitech\n", sizeLZW );                
#endif
            ReadDataSubBlocks( inFile, &screen, sizeLZW );

        } else {
            fprintf(stderr,"Neznamy blok\n");
            return -1;
        }
    }    

    write_zx_format(&screen, argv[2]);
    return 0;
}

