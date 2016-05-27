class Parser
	prechigh
		nonassoc MENOS_UNARIO
		left 'TkMult' 'TkDiv' 'TkMod'
		left 'TkSuma' 'TkResta'
		left 'TkNegacion'
		left 'TkConjuncion\' '\TkDisyuncion'
		left 'TkSiguienteCar' 'TkAnteriorCar'
		nonassoc 'TkValorAscii'
		left 'TkConcatenacion'
		right 'TkRotacion'
		left 'TkTrasposicion'
		nonassoc 'TkMenorIgual' 'TkMayorIgual' 'TkMenor' 'TkMayor'
		left 'TkIgual' 'TkDesigual'
		nonassoc 'TkAsignacion'
	preclow
	TkToken
		'TkConjuncion' 'TkConjuncion\'
		'TkDisyuncion' '\TkDisyuncion'
		'TkMenorIgual' 'TkMenorIgual'
		'TkMayorIgual' 'TkMayorIgual'
		'TkDesigual' 'TkDesigual'
		'TkSiguienteCar' 'TkSiguienteCar'
		'TkAnteriorCar' 'TkAnteriorCar'
		'TkConcatenacion' 'TkConcatenacion'
		'TkHacer' 'TkHacer'
		'TkAsignacion' 'TkAsignacion'
		'TkMenor' 'TkMenor'
		'TkMayor' 'TkMayor'
		'TkIgual' 'TkIgual'
		'TkValorAscii' 'TkValorAscii'
		'TkRotacion' 'TkRotacion'
		'TkTrasposicion' 'TkTrasposicion'
		'TkComa' 'TkComa'
		'TkPunTkTo' 'TkPunTkTo'
		'TkDosPunTkTos' 'TkDosPunTkTos'
		'TkParAbre' 'TkParAbre'
		'TkParCierra' 'TkParCierra'
		'TkCorcheteAbre' 'TkCorcheteAbre'
		'TkCorcheteCierra' 'TkCorcheteCierra'
		'TkLlaveAbre' 'TkLlaveAbre'
		'TkLlaveCierra' 'TkLlaveCierra'
		'TkSuma' 'TkSuma'
		'TkResta' 'TkResta'
		'TkMult' 'TkMult'
		'TkDiv' 'TkDiv'
		'TkMod' 'TkMod'
		'TkNegacion' 'TkNegacion'
		'TkCaracter' 'TkCaracter'
		'TkFalse' 'TkFalse'
		'TkTrue' 'TkTrue'
		'TkId' 'TkId'
		'TkNum' 'TkNum'
		'TkBegin' 'TkBegin'
		'TkEnd' 'TkEnd'
		'TkIf' 'TkIf'
		'TkWith' 'TkWith'
		'TkVar' 'TkVar'
		'TkChar' 'TkChar'
		'TkBool' 'TkBool'
		'TkMatrix' 'TkMatrix'
		'TkInt' 'TkInt'
		'TkPrTkInt' 'prTkInt'
		'TkOtherwise' 'TkOtherwise'
		'TkFor' 'TkFor'
		'TkRead' 'TkRead'
		'TkStep' 'TkStep'
		'TkFrom' 'TkFrom'
		'TkTo' 'TkTo'
		'TkOf' 'TkOf'
		'TkWhile' 'TkWhile'
	start bloque
	rule
		bloqueTkDosPunTkTos 'TkWith' declaraciones 'TkBegin' instruccion 'TkEnd' TkLlaveAbreresult TkIgual valTkCorcheteAbre3TkCorcheteCierraTkLlaveCierra
			  | 'TkBegin' instruccion 'TkEnd' TkLlaveAbreresult TkIgual valTkCorcheteAbre1TkCorcheteCierraTkLlaveCierra

		tipoTkDosPunTkTos 'TkChar' 
			| 'TkBool' 
			| 'TkInt'
			| 'TkMatrix' 'TkCorcheteAbre' valores 'TkCorcheteCierra' 'TkOf' tipo		

		declaracionTkDosPunTkTos 'TkVar' declarables 'TkDosPunTkTos' tipo

		declaracionesTkDosPunTkTos declaraciones declaracion
					 | declaracion

		declarableTkDosPunTkTos 'TkId' 'TkAsignacion' expresion
				  | 'TkId'

		declarablesTkDosPunTkTos declarables 'TkComa' declarable
				   | declarable

		valorTkDosPunTkTos contenedor TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
			 | literal TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra

		contenedorTkDosPunTkTos 'TkId' TkLlaveAbreresult TkIgual Arbol_VariableTkPunTkTonewTkParAbrevalTkCorcheteAbre0TkCorcheteCierraTkParCierraTkLlaveCierra
			 	  | 'TkId' 'TkCorcheteAbre' valores 'TkCorcheteCierra' TkLlaveAbreresult TkIgual Arbol_IndexacionTkPunTkTonewTkParAbrenilTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
		
		literalTkDosPunTkTos 'TkTrue' TkLlaveAbreresult TkIgual Arbol_Literal_BoolTkPunTkTonewTkParAbre'True'TkParCierraTkLlaveCierra
			   | 'TkFalse' TkLlaveAbreresult TkIgual Arbol_Literal_BoolTkPunTkTonewTkParAbre'False'TkParCierraTkLlaveCierra
			   | 'TkNum' TkLlaveAbreresult TkIgual Arbol_Literal_NumTkPunTkTonewTkParAbrevalTkCorcheteAbre0TkCorcheteCierraTkParCierraTkLlaveCierra
			   | 'TkCaracter' TkLlaveAbreresult TkIgual Arbol_Literal_BoolTkPunTkTonewTkParAbrevalTkCorcheteAbre0TkCorcheteCierraTkParCierraTkLlaveCierra
			   | matriz TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra

		matrizTkDosPunTkTos 'TkLlaveAbre' 'TkLlaveCierra' TkLlaveAbreresult TkIgual Arbol_Literal_MatrizTkPunTkTonewTkParAbreTkCorcheteAbreTkCorcheteCierraTkParCierraTkLlaveCierra
			  | 'TkLlaveAbre' valores 'TkLlaveCierra' TkLlaveAbreresult TkIgual Arbol_Literal_MatrizTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkParCierraTkLlaveCierra

		valoresTkDosPunTkTos valores 'TkComa' valor TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkPunTkToaddTkParAbrevalTkCorcheteAbre2TkCorcheteCierraTkParCierra TkLlaveCierra
			   | valor TkLlaveAbreresult TkIgual TkCorcheteAbrevalTkCorcheteAbre0TkCorcheteCierraTkCorcheteCierraTkLlaveCierra

		instruccionTkDosPunTkTos asignacion TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				   | secuenciacion TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				   | bloque TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				   | entrada_salTkIda TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				   | repeticion_det TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				   | repeticion_indet TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				   | condicional TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra

		asignacionTkDosPunTkTos 'TkId' 'TkAsignacion' expresion 'TkPunTkTo' TkLlaveAbreresult TkIgual Arbol_AsignacionTkPunTkTonewTkParAbrenilTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra

		entrada_salTkIdaTkDosPunTkTos 'TkRead' 'TkId' 'TkPunTkTo' TkLlaveAbreresult TkIgual Arbol_ReadTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkParCierraTkLlaveCierra
					  | 'prTkInt' expresion 'TkPunTkTo' TkLlaveAbreresult TkIgual Arbol_PrTkIntTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkParCierraTkLlaveCierra

		instruccionesTkDosPunTkTos instrucciones instruccion TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkPunTkToaddTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkParCierraTkLlaveCierra
					 | instruccion TkLlaveAbreresult TkIgual TkCorcheteAbrevalTkCorcheteAbre0TkCorcheteCierraTkCorcheteCierraTkLlaveCierra

		secuenciacionTkDosPunTkTos instrucciones instruccion TkLlaveAbreresult TkIgual Arbol_SecuenciacionTkPunTkTonewTkParAbrevalTkCorcheteAbre0TkCorcheteCierraTkPunTkToaddTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkParCierraTkParCierraTkLlaveCierra

		condicionalTkDosPunTkTos 'TkIf' expresion_TkBool 'TkHacer' instruccion 'TkEnd' TkLlaveAbreresult TkIgual Arbol_CondicionalTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre3TkCorcheteCierraTkParCierraTkLlaveCierra
				   | 'TkIf' expresion_TkBool 'TkHacer' instruccion 'TkOtherwise' instruccion 'TkEnd' TkLlaveAbreresult TkIgual Arbol_CondicionalTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre3TkCorcheteCierraTkComavalTkCorcheteAbre5TkCorcheteCierraTkParCierraTkLlaveCierra

		repeticion_detTkDosPunTkTos 'TkFor' 'TkId' 'TkFrom' expresion_aritm 'TkTo' expresion_aritm 'TkHacer' instruccion 'TkEnd' TkLlaveAbreresult TkIgual Arbol_Rep_DetTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre3TkCorcheteCierraTkComavalTkCorcheteAbre5TkCorcheteCierraTkComavalTkCorcheteAbre7TkCorcheteCierraTkComanilTkParCierraTkLlaveCierra
					  | 'TkFor' 'TkId' 'TkFrom' expresion_aritm 'TkTo' expresion_aritm 'TkStep' expresion_aritm 'TkHacer' instruccion 'TkEnd' TkLlaveAbreresult TkIgual Arbol_Rep_DetTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre3TkCorcheteCierraTkComavalTkCorcheteAbre5TkCorcheteCierraTkComavalTkCorcheteAbre9TkCorcheteCierraTkComavalTkCorcheteAbre7TkCorcheteCierraTkParCierraTkLlaveCierra

		repeticion_indetTkDosPunTkTos 'TkWhile' expresion_TkBool 'TkHacer' instruccion 'TkEnd' TkLlaveAbreresult TkIgual Arbol_Rep_IndetTkPunTkTonewTkParAbrenilTkComa valTkCorcheteAbre1TkCorcheteCierraTkComa valTkCorcheteAbre3TkCorcheteCierraTkParCierraTkLlaveCierra

		expresionTkDosPunTkTos expresion_aritm TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				 | expresion_TkBool TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				 | expresion_TkChar TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				 | expresion_rel TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				 | expresion_matr TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra
				 | 'TkParAbre' expresion 'TkParCierra' TkLlaveAbreresult TkIgual valTkCorcheteAbre1TkCorcheteCierraTkLlaveCierra
				 | valor TkLlaveAbreresult TkIgual valTkCorcheteAbre0TkCorcheteCierraTkLlaveCierra

		expresion_aritmTkDosPunTkTos expresion 'TkSuma' expresion TkLlaveAbreresult TkIgual Arbol_Expr_AritmTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					   | expresion 'TkResta' expresion TkLlaveAbreresult TkIgual Arbol_Expr_AritmTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					   | expresion 'TkMult' expresion TkLlaveAbreresult TkIgual Arbol_Expr_AritmTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					   | expresion 'TkDiv' expresion TkLlaveAbreresult TkIgual Arbol_Expr_AritmTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					   | expresion 'TkMod' expresion TkLlaveAbreresult TkIgual Arbol_Expr_AritmTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					   | 'TkResta' expresion TkIgualMENOS_UNARIO TkLlaveAbreresult TkIgual Arbol_Expr_UnariaATkPunTkTonewTkParAbre'prefijo'TkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre1TkCorcheteCierraTkParCierraTkLlaveCierra

		expresion_TkBoolTkDosPunTkTos expresion 'TkConjuncion\' expresion TkLlaveAbreresult TkIgual Arbol_Expr_BoolTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					  | expresion '\TkDisyuncion' expresion TkLlaveAbreresult TkIgual Arbol_Expr_BoolTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					  | 'TkNegacion' expresion TkLlaveAbreresult TkIgual Arbol_Expr_UnariaBTkPunTkTonewTkParAbre'prefijo'TkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre1TkCorcheteCierraTkParCierraTkLlaveCierra

		expresion_TkCharTkDosPunTkTos expresion 'TkSiguienteCar' TkLlaveAbreresult TkIgual Arbol_Expr_CharTkPunTkTonewTkParAbre'posfijo'TkComavalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkParCierraTkLlaveCierra
					  | expresion 'TkAnteriorCar' TkLlaveAbreresult TkIgual Arbol_Expr_CharTkPunTkTonewTkParAbre'posfijo'TkComavalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkParCierraTkLlaveCierra
					  | 'TkValorAscii' expresion TkLlaveAbreresult TkIgual Arbol_Expr_CharTkPunTkTonewTkParAbre'prefijo'TkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre1TkCorcheteCierraTkParCierraTkLlaveCierra

		expresion_matrTkDosPunTkTos expresion 'TkConcatenacion' expresion TkLlaveAbreresult TkIgual Arbol_Expr_MatriTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					  | 'TkRotacion' expresion TkLlaveAbreresult TkIgual Arbol_Expr_UnariaMTkPunTkTonewTkParAbre'prefijo'TkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre1TkCorcheteCierraTkParCierraTkLlaveCierra
					  | expresion 'TkTrasposicion' TkLlaveAbreresult TkIgual Arbol_Expr_UnariaMTkPunTkTonewTkParAbre'posfijo'TkComavalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkParCierraTkLlaveCierra

		expresion_relTkDosPunTkTos expresion 'TkIgual' expresion 	TkLlaveAbreresult TkIgual Arbol_Expr_RelTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					 | expresion 'TkDesigual' expresion TkLlaveAbreresult TkIgual Arbol_Expr_RelTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					 | expresion 'TkMenor' expresion 	TkLlaveAbreresult TkIgual Arbol_Expr_RelTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					 | expresion 'TkMayor' expresion 	TkLlaveAbreresult TkIgual Arbol_Expr_RelTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					 | expresion 'TkMenorIgual' expresion TkLlaveAbreresult TkIgual Arbol_Expr_RelTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra
					 | expresion 'TkMayorIgual' expresion TkLlaveAbreresult TkIgual Arbol_Expr_RelTkPunTkTonewTkParAbrevalTkCorcheteAbre1TkCorcheteCierraTkComavalTkCorcheteAbre0TkCorcheteCierraTkComavalTkCorcheteAbre2TkCorcheteCierraTkParCierraTkLlaveCierra

TkAnteriorCarTkAnteriorCar inner
	def initialize TkParAbreTkTokensTkParCierra
		@TkTokens TkIgual TkTokens
	TkEnd

	def parse
		do_parse
	TkEnd

	def next_TkToken
    	TkToken TkIgual @TkTokensTkPunTkToshTkIft
	    TkIf TkToken !TkIgual nil
	      tk_parser TkIgual TkCorcheteAbreTkTokenTkPunTkToclassTkPunTkToTkTo_sTkComa TkTokenTkPunTkTovalorTkCorcheteCierra
	    else
	      tk_parser TkIgual TkCorcheteAbreTkFalseTkComaTkFalseTkCorcheteCierra
	    TkEnd
    	return tk_parser
	TkEnd
