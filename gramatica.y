class Parser

	token '/\\' '\\/' '<=' '>=' '/=' '++' '--' '::' '->' '<-' '<' '>' '='
		  '#' '$' '?' ',' '.' ':' '(' ')' '[' ']' '{' '}' '+' '-' '*' '/'
		  '%' 'not' 'caracter' 'false' 'true' 'id' 'numero' 'begin' 'end'
		  'if' 'with' 'var' 'char' 'bool' 'matrix' 'int' 'print' 'otherwise'
		  'for' 'read' 'step' 'from' 'to' 'of' 'while'

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

	convert
		'/\\' 'TkConjuncion'
		'\\/' 'TkDisyuncion'
		'<=' 'TkMenorIgual'
		'>=' 'TkMayorIgual'
		'/=' 'TkDesigual'
		'++' 'TkSiguienteCar'
		'--' 'TkAnteriorCar'
		'::' 'TkConcatenacion'
		'->' 'TkHacer'
		'<-' 'TkAsignacion'
		'<' 'TkMenor'
		'>' 'TkMayor'
		'=' 'TkIgual'
		'#' 'TkValorAscii'
		'$' 'TkRotacion'
		'?' 'TkTrasposicion'
		',' 'TkComa'
		'.' 'TkPunto'
		':' 'TkDosPuntos'
		'(' 'TkParAbre'
		')' 'TkParCierra'
		'[' 'TkCorcheteAbre'
		']' 'TkCorcheteCierra'
		'{' 'TkLlaveAbre'
		'}' 'TkLlaveCierra'
		'+' 'TkSuma'
		'-' 'TkResta'
		'*' 'TkMult'
		'/' 'TkDiv'
		'%' 'TkMod'
		'not' 'TkNegacion'
		'caracter' 'TkCaracter'
		'false' 'TkFalse'
		'true' 'TkTrue'
		'id' 'TkId'
		'numero' 'TkNum'
		'begin' 'TkBegin'
		'end' 'TkEnd'
		'if' 'TkIf'
		'with' 'TkWith'
		'var' 'TkVar'
		'char' 'TkChar'
		'bool' 'TkBool'
		'matrix' 'TkMatrix'
		'int' 'TkInt'
		'print' 'TkPrint'
		'otherwise' 'TkOtherwise'
		'for' 'TkFor'
		'read' 'TkRead'
		'step' 'TkStep'
		'from' 'TkFrom'
		'to' 'TkTo'
		'of' 'TkOf'
		'while' 'TkWhile'
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

		valores: valores ',' valor {result = val[0] << val[2] }
			   | valor {result = [val[0]]}

		instruccion: asignacion {result = val[0]}
				   | secuenciacion {result = val[0]}
				   | bloque {result = val[0]}
				   | entrada_salida {result = val[0]}
				   | repeticion_det {result = val[0]}
				   | repeticion_indet {result = val[0]}
				   | condicional {result = val[0]}

		asignacion: contenedor '<-' expresion '.' {result = Arbol_Asignacion.new(nil,val[0],val[2])}

		entrada_salida: 'read' contenedor '.' {result = Arbol_Read.new(val[1])}
					  | 'print' expresion '.' {result = Arbol_Print.new(val[1])}

		instrucciones: instrucciones instruccion {result = val[0] << val[1]}
					 | instruccion {result = [val[0]]}

		secuenciacion: instrucciones instruccion {result = Arbol_Secuenciacion.new(nil,val[0] << val[1])}

		condicional: 'if' expresion '->' instruccion 'end' {result = Arbol_Condicional.new(val[1],val[3])}
				   | 'if' expresion '->' instruccion 'otherwise' instruccion 'end' {result = Arbol_Condicional.new(val[1],val[3],val[5])}

		repeticion_det: 'for' 'id' 'from' expresion_aritm 'to' expresion_aritm '->' instruccion 'end' {result = Arbol_Rep_Det.new(val[1],val[3],val[5],val[7],nil)}
					  | 'for' 'id' 'from' expresion_aritm 'to' expresion_aritm 'step' expresion_aritm '->' instruccion 'end' {result = Arbol_Rep_Det.new(val[1],val[3],val[5],val[9],val[7])}

		repeticion_indet: 'while' expresion '->' instruccion 'end' {result = Arbol_Rep_Indet.new(nil, val[1], val[3])}

		expresion: expresion_aritm {result = val[0]}
				 | expresion_bool {result = val[0]}
				 | expresion_char {result = val[0]}
				 | expresion_rel {result = val[0]}
				 | expresion_matr {result = val[0]}
				 | '(' expresion ')' {result = val[1]}
				 | valor {result = val[0]}

		expresion_aritm: expresion '+' expresion {result = Arbol_Expr_Aritm.new(val[1],val[0],val[2])}
					   | expresion '-' expresion {result = Arbol_Expr_Aritm.new(val[1],val[0],val[2])}
					   | expresion '*' expresion {result = Arbol_Expr_Aritm.new(val[1],val[0],val[2])}
					   | expresion '/' expresion {result = Arbol_Expr_Aritm.new(val[1],val[0],val[2])}
					   | expresion '%' expresion {result = Arbol_Expr_Aritm.new(val[1],val[0],val[2])}
					   | '-' expresion =MENOS_UNARIO {result = Arbol_Expr_UnariaA.new('prefijo',val[0],val[1])}

		expresion_bool: expresion '/\\' expresion {result = Arbol_Expr_Bool.new(val[1],val[0],val[2])}
					  | expresion '\\/' expresion {result = Arbol_Expr_Bool.new(val[1],val[0],val[2])}
					  | 'not' expresion {result = Arbol_Expr_UnariaB.new('prefijo',val[0],val[1])}

		expresion_char: expresion '++' {result = Arbol_Expr_Char.new('posfijo',val[1],val[0])}
					  | expresion '--' {result = Arbol_Expr_Char.new('posfijo',val[1],val[0])}
					  | '#' expresion {result = Arbol_Expr_Char.new('prefijo',val[0],val[1])}

		expresion_matr: expresion '::' expresion {result = Arbol_Expr_Matri.new(val[1],val[0],val[2])}
					  | '$' expresion {result = Arbol_Expr_UnariaM.new('prefijo',val[0],val[1])}
					  | expresion '?' {result = Arbol_Expr_UnariaM.new('posfijo',val[1],val[0])}

		expresion_rel: expresion '=' expresion 	{result = Arbol_Expr_Rel.new(val[1],val[0],val[2])}
					 | expresion '/=' expresion {result = Arbol_Expr_Rel.new(val[1],val[0],val[2])}
					 | expresion '<' expresion 	{result = Arbol_Expr_Rel.new(val[1],val[0],val[2])}
					 | expresion '>' expresion 	{result = Arbol_Expr_Rel.new(val[1],val[0],val[2])}
					 | expresion '<=' expresion {result = Arbol_Expr_Rel.new(val[1],val[0],val[2])}
					 | expresion '>=' expresion {result = Arbol_Expr_Rel.new(val[1],val[0],val[2])}

---- inner
	load 'arbol.rb'

	def initialize (tokens)
		@tokens = tokens
	end

	def parse
		do_parse
	end

	def next_token
    	token = @tokens.shift
	    if token != nil
	      tk_parser = [token.class, token.valor]
	    else
	      tk_parser = [false,false]
	    end
    	return tk_parser
	end