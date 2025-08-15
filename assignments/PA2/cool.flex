/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
#include <cstdio>
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int nested_comment_depth;
char error_msg[MAX_STR_CONST];
char *error_msg_ptr;
%}

/*
 * Define names for regular expressions here.
 */
%x COMMENT

DARROW          =>
ASSIGN          <-
LE              <=
WS              [ \t\v\f]
NL              (\r\n)|\r|\n
DIGIT           [0-9]
ALPHANUMERIC    [a-zA-Z0-9_]

/* Keywords, case insensitive */
CLASS           [cC][lL][aA][sS][sS]
ELSE            [eE][lL][sS][eE]
FI              [fF][iI]
IF              [iI][fF]
IN              [iI][nN]
INHERITS        [iI][nN][hH][eE][rR][tT][sS]
ISVOID          [iI][sS][vV][oO][iI][dD]
LET             [lL][eE][tT]
LOOP            [lL][oO][oO][pP]
POOL            [pP][oO][oO][lL]
THEN            [tT][hH][eE][nN]
WHILE           [wW][hH][iI][lL][eE]
CASE            [cC][aA][sS][eE]
ESAC            [eE][sS][aA][cC]
NEW             [nN][eE][wW]
OF              [oO][fF]
NOT             [nN][oO][tT]

/* Keywords, first letter as lower case */
TRUE            t[rR][uU][eE]
FALSE           f[aA][lL][sS][eE]

%%

 /*
  *  Nested comments
  */
"(*"           { BEGIN(COMMENT); nested_comment_depth = 1; }
"*)"           {
  std::string error = "Unmatched *)";
  cool_yylval.error_msg = strdup(error.c_str());
  return ERROR; 
}
<COMMENT>"(*"  { ++nested_comment_depth; }
<COMMENT>")*"  { if (--nested_comment_depth == 0) BEGIN(INITIAL); }
<COMMENT>{NL}  { curr_lineno; }
<COMMENT>.     { /* comments */}
<COMMENT><EOF> {
  std::string error = "EOF in comment";
  cool_yylval.error_msg = strdup(error.c_str());
  return ERROR;
}

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }
{ASSIGN}    { return (ASSIGN); }
{LE}        { return (LE); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

{CLASS}     { return CLASS; }
{ELSE}      { return ELSE; }
{FI}        { return FI; }
{IF}        { return IF; }
{IN}        { return IN; }
{INHERITS}  { return INHERITS; }
{ISVOID}    { return ISVOID; }
{LET}       { return LET; }
{LOOP}      { return LOOP; }
{POOL}      { return POOL; }
{THEN}      { return THEN; }
{WHILE}     { return WHILE; }
{CASE}      { return CASE; }
{ESAC}      { return ESAC; }
{NEW}       { return NEW; }
{OF}        { return OF; }
{NOT}       { return NOT; }

{TRUE}      {
  cool_yylval.boolean = true;
  return BOOL_CONST;
}

{FALSE}     {
  cool_yylval.boolean = false;
  return BOOL_CONST;
}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%
