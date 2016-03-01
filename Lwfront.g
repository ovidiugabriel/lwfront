grammar Lwfront;

ID  :	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;

INT :	'0'..'9'+
    ;

FLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;

COMMENT
    :   '//' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;}
    |   '/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
    ;

WS  :   ( ' '
        | '\t'
        | '\r'
        | '\n'
        ) {$channel=HIDDEN;}
    ;

STRING
    :  '"' ( ESC_SEQ | ~('\\'|'"') )* '"'
    ;

CHAR:  '\'' ( ESC_SEQ | ~('\''|'\\') ) '\''
    ;

fragment
EXPONENT : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;

fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;

fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;

fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;

/* ************************************************************************
 *  Grammar Rules 
 **************************************************************************  */

compilation_unit
    :   class_specifier
    ;
    
class_specifier
    :   ( class_head | object_head ) 
        '{' 
            member_specification?
        '}'
    ;
   
class_head: 'class' type;

var_name: ID;

function_name: ID;

type: ID;

value: INT|FLOAT|STRING|CHAR;
	
object_head: 'object' ID;

static_tag: 'static' ;

const_tag: 'const';

// 'internal' visibility is added as improvement over traditional C++ mode
visibility: 'public' | 'private' | 'protected'|'internal';

member_specification
    : var_specification 
    | function_specification	
    ;

// Variations to the C++ mainstream dialect:
//	- visibility is required to be specified for each member variable
//	- the colon after visibility specifier is optional    
var_specification
    : static_tag? visibility ':'? const_tag? type var_name ('=' value )? ';'	
    ;

// Since this is a preprocessor
// everything that's inside a function body is matched
function_body: (.*);

// Variations to the C++ mainstream dialect:
//	- visibility is required to be specified for each method
//	- the colon after visibility specifier is optional
function_specification
    : static_tag? visibility ':'? type function_name '('  ')' const_tag? 
        '{'
	        function_body
        '}'
    ;
    
