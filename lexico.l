%{
#include "sintatico.h"
#include "stdlib.h"
#include "funcoes.h"
#include "stack.h"
#include <string.h>
#include <stdlib.h>
char token[100], variavel[100], tipoTermo[100];
int atribuicao=0, estaNoIf=0, corpoIf=0, estaNoElse=0, corpoElse=0, corpoWhile = 0, estaNoWhile=0, fimArquivo = 0;
int parametroIf=0,  parametroWhile=0;
Parametros parametros;
Stack stack;
extern FILE *ArquivoStart;
extern int condicao;
extern int enquanto;
%}

branco [ \t\n]+
digito [0-9]
letra [a-zA-Z]
numeroInteiro {digito}+
numeroReal {numeroInteiro}("."{numeroInteiro})?
identificador {letra}+({digito}|{letra})*
inteiro "int"
float "float"
main "main"
recebe "="
se "if"
senao "else"
parentesesEsquerda "("
parentesesDireita ")"
chaveEsquerda "{"
chaveDireita "}"
pontoVirgula ";"
comparacao "=="
maiorIgual ">="
menorIgual "<="
maiorQue ">"
menorQue "<"
diferente "!="
enquanto "while"

%%

{branco} { /* Desconsiderar espaços em branco */ }
{main} {
	criarArquivoStart();

	return(MAIN);
}
{numeroInteiro} {
	if(atribuicao)
	{
		atribuir(variavel, yytext);
		atribuicao=0;
	}

	if(parametroIf || parametroWhile)
	{
		strcpy(tipoTermo, "numero");
		popularParametros(&parametros, yytext, tipoTermo);
	}

	return(NUMERO_INTEIRO);
}

{numeroReal} {
	if(atribuicao)
	{
		atribuir(variavel, yytext);
		atribuicao=0;
	}

	if(parametroIf || parametroWhile)
	{
		strcpy(tipoTermo, "numero");
		popularParametros(&parametros, yytext, tipoTermo);
	}

	return(NUMERO_REAL);
}

{se} {
	parametroIf=1;
	estaNoIf=1;
	return(IF);
}

{senao} {
	estaNoElse=1;
	return(ELSE);
}

{enquanto} {
	estaNoWhile = 1;
	parametroWhile=1;
	return(WHILE);
}

"for" return(FOR);

{inteiro} {
	strcpy(token, yytext);
	return(INT);
}

{float} {
	strcpy(token, yytext);
	return(FLOAT);
}

"+" return(SOMA);
"-" return(SUBTRACAO);
"*" return(MULTIPLICACAO);
"/" return(DIVISAO);

{parentesesEsquerda} {
	inserirElementoPilha(&stack, '(');
	return(PARENTESES_ESQUERDA);
}

{parentesesDireita} {
	apagarElementoPilha(&stack);

	if(!stack.top)
	{
		parametroWhile=0;
		parametroIf=0;
	}

	return(PARENTESES_DIREITA);
}

{recebe} {
	atribuicao=1;
	return(RECEBE);
}

{comparacao} {
	strcpy(parametros.operador,yytext);
	return(COMPARACAO);
}

{maiorIgual} {
	strcpy(parametros.operador,yytext);
	return(MAIOR_IGUAL);
}

{menorIgual} {
	strcpy(parametros.operador,yytext);
	return(MENOR_IGUAL);
}

{maiorQue} {
	strcpy(parametros.operador,yytext);
	return(MAIOR_QUE);
}

{menorQue} {
	strcpy(parametros.operador,yytext);
	return(MENOR_QUE);
}

{diferente} {
	strcpy(parametros.operador,yytext);
	return(DIFERENTE);
}

"&&" return(E);
"||" return(OU);
"++" return(INCREMENTO);
"--" return(DECREMENTO);

{chaveEsquerda} {
	if(estaNoIf)
		corpoIf=1;

	if(estaNoElse)
		corpoElse=1;
	if(estaNoWhile)
		corpoWhile = 1;
	
	fimArquivo++;

	return(CHAVE_ESQUERDA);
}

{chaveDireita} {
	if(estaNoIf == 1)
	{
		estaNoIf=0;
		corpoIf=0;
		ArquivoStart = fopen("start.asm", "a");
		fprintf(ArquivoStart, "\n\t\tJMP fimCondicao%d", condicao - 1);
		fclose(ArquivoStart);
	}
	else if(estaNoElse == 1)
	{
		estaNoElse=0;
		corpoElse=0;
		ArquivoStart = fopen("start.asm", "a");
		fprintf(ArquivoStart, "\n\t\tfimCondicao%d:", condicao - 1);
		fclose(ArquivoStart);
	}
	else if(estaNoWhile == 1)
	{
		estaNoWhile=0;
		corpoWhile=0;
		ArquivoStart = fopen("start.asm", "a");
		fprintf(ArquivoStart, "\n\tJMP Enquanto%d", enquanto);
		fprintf(ArquivoStart,"\n\n\tCondicao%d:",condicao-1);
		fclose(ArquivoStart);
	}
	fimArquivo--;
	if(!fimArquivo)
	{
		exit(0);
	}

	return(CHAVE_DIREITA);
}

{pontoVirgula} {
	/* Reinicando todas as variáveis */
	strcpy(token, "");
	strcpy(variavel, "");
	strcpy(tipoTermo, "");
	atribuicao=0;
	parametroIf=0;
	parametroWhile=0;

	return(PONTOVIRGULA);
}

"," return(VIRGULA);
"\"" return(ASPAS);

{identificador} {
	strcpy(variavel,yytext);

	if(strcmp(token, "")!=0)
		declaracaoVariavel(token, yytext);
	
	if(parametroIf || parametroWhile)
	{
		strcpy(tipoTermo, "variavel");
		popularParametros(&parametros, yytext, tipoTermo);
	}

	
	return(IDENTIFICADOR);
}

%%

yywrap () {
return 0;
}
