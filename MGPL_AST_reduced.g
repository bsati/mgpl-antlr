grammar MGPL_AST_reduced;

options { backtrack = false; k=1; output = AST;}
tokens {
	GAME;
	DECLARATIONS;
	BLOCKS;
	VALUE;
	ASSIGN;
	SIZE;
	ATTRIBUTES;
	ANIMATION;
	OBJECT;
	TYPE;
	CONDITION;
	CONSEQUENCE;
	ALTERNATIVE;	
	EVENT;
	HANDLER;
	IF;
	FOR;
	INIT;
	LOOP_CONDITION;
	LOOP_COUNTER;
	INDEX;
	AND;
	OR;
	LOOP_BODY;
	STATEMENTS;
}
start: prog;

// comment skipper
COMMENT :	'//' ~('\r' | '\n')* '\r'? '\n'{skip();};

// general rules
prog 	: 'game' IDENTIFIER '(' attr_ass_list? ')' decl* stmt_block block* 
	-> ^(GAME IDENTIFIER ^(DECLARATIONS decl*) stmt_block ^(BLOCKS block*));
decl 	:  var_decl ';'! | obj_decl ';'!;
var_decl
	:	'int' IDENTIFIER var_decl_ext -> ^(IDENTIFIER var_decl_ext?);
var_decl_ext
	:	init? | '[' NUMBER ']';
init 	:	 '=' expr -> ^(VALUE expr);
obj_decl 
	:	 OBJ_TYPE IDENTIFIER obj_decl_ext -> ^(OBJECT IDENTIFIER ^(TYPE OBJ_TYPE) obj_decl_ext);
obj_decl_ext
	:	 '('! attr_ass_list? ')'! | '[' NUMBER ']' -> ^(SIZE NUMBER);
attr_ass_list 
	:	attr_ass (',' attr_ass)* -> ^(ATTRIBUTES attr_ass+);
attr_ass 
	:	IDENTIFIER '=' expr -> ^(ASSIGN ^(IDENTIFIER) ^(VALUE expr));
block	:	anim_block | event_block;
anim_block 
	:	 'animation' IDENTIFIER '(' OBJ_TYPE IDENTIFIER ')' stmt_block -> ^(ANIMATION IDENTIFIER ^(OBJECT ^(TYPE OBJ_TYPE) IDENTIFIER) stmt_block);
event_block
	:	'on' KEYSTROKE stmt_block -> ^(EVENT KEYSTROKE ^(HANDLER stmt_block));
	
// Statement rules
stmt_block
	:	 '{' stmt* '}' -> ^(STATEMENTS stmt*);
stmt	:	if_stmt | for_stmt | ass_stmt ';'!;
if_stmt	:	'if' '(' expr ')' stmt_block ('else' stmt_block)? -> ^(IF ^(CONDITION expr) ^(CONSEQUENCE stmt_block) ^(ALTERNATIVE stmt_block)?);
for_stmt	:	'for' '(' ass_stmt ';' expr ';' ass_stmt ')' stmt_block -> ^(FOR ^(INIT ass_stmt) ^(LOOP_CONDITION expr) ^(LOOP_COUNTER ass_stmt) ^(LOOP_BODY stmt_block));
ass_stmt :	var '=' expr -> ^(ASSIGN var ^(VALUE expr));

var 	:	IDENTIFIER var_ext? -> ^(IDENTIFIER var_ext?);
var_ext :	'.' IDENTIFIER | '[' expr ']' var_ext_2? -> ^(INDEX expr) var_ext_2?;
var_ext_2
	:	'.' IDENTIFIER;

// Expression rules
expr	:	or_expr;
or_expr	:	and_expr ('||'^ and_expr)*;
and_expr:	rel_expr ('&&'^ rel_expr)*;
rel_expr:	add_expr (rel_op^ add_expr)*;
add_expr:	mult_expr (add_op^ mult_expr)*;
mult_expr
	:	unary_expr (mult_op^ unary_expr)*;
unary_expr	
	:	unary_op? atom_expr;
atom_expr 
	:	NUMBER | '('!expr')'! | var atom_expr_2?;
atom_expr_2
	: 	'touches' var;

// Operators (actually terminals but needed as parser rules)
rel_op	:	'==' | '<' |'<=';
add_op	:	'+' | '-';
mult_op	:	'*' | '/';
unary_op:	'!' | '-';

// terminals
KEYSTROKE:	'space' | 'leftarrow' | 'rightarrow' | 'uparrow' | 'downarrow';
OBJ_TYPE :	'rectangle' | 'triangle' | 'circle';

NUMBER 	: 	'0' | ('1'..'9') ('0'..'9')*;
IDENTIFIER
	:	('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;