grammar MGPL;

options { backtrack = false; k=1; output = AST;}
start: prog;

// comment skipper
COMMENT :	'//' ~('\r' | '\n')* '\r'? '\n'{skip();};

// general rules
prog 	: 'game' IDENTIFIER '(' attr_ass_list? ')' decl* stmt_block block*;
decl 	:  var_decl ';' | obj_decl ';';
var_decl
	:	'int' IDENTIFIER var_decl_ext;
var_decl_ext
	:	init? | '[' NUMBER ']';
init 	:	 '=' expr;
obj_decl 
	:	 OBJ_TYPE IDENTIFIER obj_decl_ext;
obj_decl_ext
	:	 '(' attr_ass_list? ')' | '[' NUMBER ']';
attr_ass_list 
	:	attr_ass (',' attr_ass)*;
attr_ass 
	:	IDENTIFIER '=' expr;
block	:	anim_block | event_block;
anim_block 
	:	 'animation' IDENTIFIER '(' OBJ_TYPE IDENTIFIER ')' stmt_block;
event_block
	:	'on' KEYSTROKE stmt_block;
	
// Statement rules
stmt_block
	:	 '{' stmt* '}';
stmt	:	if_stmt | for_stmt | ass_stmt ';';
if_stmt	:	'if' '(' expr ')' stmt_block ('else' stmt_block)?;
for_stmt	:	'for' '(' ass_stmt ';' expr ';' ass_stmt ')' stmt_block;
ass_stmt :	var '=' expr;

var 	:	IDENTIFIER var_ext?;
var_ext :	'.' IDENTIFIER | '[' expr ']' var_ext_2?;
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
	:	NUMBER | '('expr')' | var atom_expr_2?;
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