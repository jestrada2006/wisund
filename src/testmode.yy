%skeleton "lalr1.cc"
%require "3.0.4"
%debug
%defines
%define parser_class_name {Parser}

%code requires {
    class Scanner;

// The following definitions is missing when %locations isn't used
# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

}
%parse-param {Scanner &scanner} 
%parse-param {Console &console} 

%{
#include <cstdint>
#include <iostream>
#include <iomanip>
#include "diag.h"
#include "Message.h"
#include "Serial.h"
#include "SafeQueue.h"
#include "Console.h"
#include "scanner.h"

#undef yylex
#define yylex scanner.yylex

void yy::Parser::error(const std::string &s)
{
    std::cerr << s << '\n';
}

static const Message RestartCmd = Message{0xff};

static void errortxt(void)
{
    std::cerr << "syntax error\n";
}

static void help(void)
{
    std::cerr << "Usage: testmode /dev/ttyUSB0\n\n"
        "Accepted commands:\n"
        "fchan nn\nphy nn\ntr51cf\nlbr\nnlbr\nbuildid\n"
        "commands accepted n LBR or NLBR active state:\n"
        "state\ndiag nn\nget nn\nping nn\nrestart\n"
        "help\n\n";
}

%}
%define api.value.type variant
%define parse.assert

%token FCHAN TR51CF PHY LBR NLBR STATE DIAG BUILDID GETZZ PING RESTART HELP
%token <int> HEXBYTE
%token NEWLINE CHAR

%%
script:     /* empty */
    |   script command NEWLINE
    

command:    FCHAN HEXBYTE   { console.compound(0x01, $2); }
    |       PHY HEXBYTE     { console.compound(0x04, $2); }
    |       TR51CF          { console.simple(0x02); }
    |       LBR             { console.simple(0x10); }
    |       NLBR            { console.simple(0x11); }
    |       STATE           { console.simple(0x20); }
    |       DIAG HEXBYTE    { std::cout << "should have run diagnostic " << $2 << " here\n"; 
                                // diag(0x21, $2, *serial); 
                            }
    |       BUILDID         { console.simple(0x22); }
    |       GETZZ HEXBYTE   { console.compound(0x2F, $2); }
    |       PING HEXBYTE    { console.compound(0x30, $2); }
    |       RESTART         { console.push(RestartCmd); }
    |       HELP            { help(); }
    |       errors          { errortxt(); }
    ;

errors:     error
    |   errors error
    ;

%%

#if 0
int main(int argc, char *argv[])
{
    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " serialport\n";
        return 1;
    }
    yydebug = 0;
    SafeQueue<Message> msgDeque;
    std::cout << "Opening port " << argv[1] << "\n";
    Serial s{argv[1], 115200};
    serial = &s;
    return yyparse();
}
#endif