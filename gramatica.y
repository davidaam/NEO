class Parser
	prechigh
		nonassoc MENOS_UNARIO
		left '*' '/' '%'
		left '+' '-'
		left 'not'
		left '/\\' '\\/'
		left '++' '--'
		nonassoc '#'
		left '::'
		right '$'
		left '?'
		nonassoc '<=' '>=' '<' '>'
		left '=' '/='
		nonassoc '<-'
	preclow
	token
	
		TkConjuncion TkDisyuncion TkNegacion

		TkMenorIgual TkMayorIgual TkDesigual TkMenor TkMayor TkIgual

		TkSiguienteCar TkAnteriorCar TkValorAscii

		TkConcatenacion TkRotacion TkTrasposicion

		TkHacer TkAsignacion TkComa TkPunto TkDosPuntos
		
		TkParAbre TkParCierra TkCorcheteAbre TkCorcheteCierra TkLlaveAbre TkLlaveCierra

		TkSuma TkResta TkMult TkDiv TkMod 
		
		TkId TkCaracter TkFalse TkTrue TkNum 

		TkWith TkBegin TkEnd TkIf TkOtherwise TkFor TkWhile

		TkStep TkFrom TkTo 

		TkVar TkChar TkBool TkMatrix TkInt TkOf

		TkPrint TkRead 

	convert
		'/\\' TkConjuncion
		'\\/' TkDisyuncion
		'<=' TkMenorIgual
		'>=' TkMayorIgual
		'/=' TkDesigual
		'++' TkSiguienteCar
		'--' TkAnteriorCar
		'::' TkConcatenacion
		'->' TkHacer
		'<-' TkAsignacion
		'<' TkMenor
		'>' TkMayor
		'=' TkIgual
		'#' TkValorAscii
		'$' TkRotacion
		'?' TkTrasposicion
		',' TkComa
		'.' TkPunto
		':' TkDosPuntos
		'(' TkParAbre
		')' TkParCierra
		'[' TkCorcheteAbre
		']' TkCorcheteCierra
		'{' TkLlaveAbre
		'}' TkLlaveCierra
		'+' TkSuma
		'-' TkResta
		'*' TkMult
		'/' TkDiv
		'%' TkMod
		'not' TkNegacion
		'caracter' TkCaracter
		'false' TkFalse
		'true' TkTrue
		'id' TkId
		'numero' TkNum
		'begin' TkBegin
		'end' TkEnd
		'if' TkIf
		'with' TkWith
		'var' TkVar
		'char' TkChar
		'bool' TkBool
		'matrix' TkMatrix
		'int' TkInt
		'print' TkPrint
		'otherwise' TkOtherwise
		'for' TkFor
		'read' TkRead
		'step' TkStep
		'from' TkFrom
		'to' TkTo
		'of' TkOf
		'while' TkWhile
	end
	start bloque
	rule
		bloque: 'with' declaraciones 'begin' instruccion 'end' {result = val[3]}
			  | 'begin' instruccion 'end' {result = val[1]}

		tipo: 'char' 
			| 'bool' 
			| 'int'
			| 'matrix' '[' valores ']' 'of' tipo		

		declaracion: 'var' declarables ':' tipo

		declaraciones: declaraciones declaracion
					 | declaracion

		declarable: 'id' '<-' expresion
				  | 'id'

		declarables: declarables ',' declarable
				   | declarable

		valor: contenedor {result = val[0]}
			 | literal {result = val[0]}

		contenedor: 'id' {result = Arbol_Variable.new(val[0])}
			 	  | 'id' '[' valores ']' {result = Arbol_Indexacion.new(nil,val[0],val[2])}
		
		literal: 'true' {result = Arbol_Literal_Bool.new('True')}
			   | 'false' {result = Arbol_Literal_Bool.new('False')}
			   | 'numero' {result = Arbol_Literal_Num.new(val[0])}
			   | 'caracter' {result = Arbol_Literal_Bool.new(val[0])}
			   | matriz {result = val[0]}

		matriz: '{' '}' {result = Arbol_Literal_Matriz.new([])}
			  | '{' valores '}' {result = Arbol_Literal_Matriz.new(val[1])}

		valores: valores ',' valor {result = val[0].add(val[2]) }
			   | valor {result = [val[0]]}

		instruccion: asignacion {result = val[0]}
				   | secuenciacion {result = val[0]}
				   | bloque {result = val[0]}
				   | entrada_salida {result = val[0]}
				   | repeticion_det {result = val[0]}
				   | repeticion_indet {result = val[0]}
				   | condicional {result = val[0]}

		asignacion: 'id' '<-' expresion '.' {result = Arbol_Asignacion.new(nil,val[0],val[2])}

		entrada_salida: 'read' 'id' '.' {result = Arbol_Read.new(val[1])}
					  | 'print' expresion '.' {result = Arbol_Print.new(val[1])}

		instrucciones: instrucciones instruccion {result = val[0].add(val[1])}
					 | instruccion {result = [val[0]]}

		secuenciacion: instrucciones instruccion {result = Arbol_Secuenciacion.new(val[0].add(val[1]))}

		condicional: 'if' expresion_bool '->' instruccion 'end' {result = Arbol_If.new(val[1],val[3])}
				   | 'if' expresion_bool '->' instruccion 'otherwise' instruccion 'end' {result = Arbol_If.new(val[1],val[3],val[5])}

		repeticion_det: 'for' 'id' 'from' expresion_aritm 'to' expresion_aritm '->' instruccion 'end' {result = Arbol_Rep_Det.new(val[1],val[3],val[5],val[7],nil)}
					  | 'for' 'id' 'from' expresion_aritm 'to' expresion_aritm 'step' expresion_aritm '->' instruccion 'end' {result = Arbol_Rep_Det.new(val[1],val[3],val[5],val[9],val[7])}

		repeticion_indet: 'while' expresion_bool '->' instruccion 'end' {result = Arbol_Rep_Indet.new(nil, val[1], val[3])}

		expresion: expresion_aritm {result = val[0]}
				 | expresion_bool {result = val[0]}
				 | expresion_char {result = val[0]}
				 | expresion_rel {result = val[0]}
				 | '(' expresion ')' {result = val[1]}

		expresion_aritm: expresion_aritm '+' expresion_aritm
					   | expresion_aritm '-' expresion_aritm
					   | expresion_aritm '*' expresion_aritm
					   | expresion_aritm '/' expresion_aritm
					   | expresion_aritm '%' expresion_aritm
					   | '-' expresion_aritm =MENOS_UNARIO
					   | valor

		expresion_bool: expresion_bool '/\\' expresion_bool
					  | expresion_bool '\\/' expresion_bool
					  | 'not' expresion_bool 
					  | expresion_rel
					  | valor

		expresion_char: expresion_char '++'
					  | expresion_char '--'
					  | '#' expresion_char
					  | valor

		expresion_matr: '(' expresion_matr ')'
					  | expresion_matr '::' expresion_matr
					  | '$' expresion_matr
					  | expresion_matr '?'
					  | matriz

		expresion_rel: expresion_matr '=' expresion_matr
					 | expresion_matr '/=' expresion_matr
					 | expresion '=' expresion
					 | expresion '/=' expresion
					 | expresion '<' expresion
					 | expresion '>' expresion
					 | expresion '<=' expresion
					 | expresion '>=' expresion

