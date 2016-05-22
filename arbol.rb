# Para permitir hacer un to_s que reciba un parámetro, hacemos override del to_s normal
class Object
	def _to_s (x=nil)
		to_s
	end
end
ARBOLES = {
	'Expr_Aritm' => ["Operador", "Operando izquierdo", "Operando derecho"],
	'Expr_Bool' => ["Operador", "Operando izquierdo", "Operando derecho"],
	'Expr_Rel' => ["Operador", "Operando izquierdo", "Operando derecho"],
	'Expr_Matr' => ["Operador", "Operando izquierdo", "Operando derecho"],
	'Expr_UnariaA' => [nil,"Operador", "Operando"],
	'Expr_UnariaB' => [nil,"Operador", "Operando"],
	'Expr_UnariaM' => [nil,"Operador", "Operando"],
	'Expr_Char' => [nil,"Operador", "Operando"],
	'Indexacion' => [nil,"Matriz", "Índice"],
	'Asignacion' => [nil,"Contenedor", "Expresión"],
	'Condicional' => ["Guardia","Éxito","Fracaso"],
	'Rep_Indet' => [nil,"Guardia","Instrucción"],
	'Variable' => ["Identificador",nil,nil],
	'Literal_Bool' => ["Valor",nil,nil],
	'Literal_Char' => ["Valor",nil,nil],
	'Literal_Num' => ["Valor",nil,nil],
	'Literal_Matr' => ["Valor",nil,nil],
	'Read' => ["Identificador",nil,nil],
	'Print' => ["Expresión",nil,nil],
}

class ArbolGeneral
	def initialize (valor = nil, hijos = [])
		@valor = valor
		@hijos = hijos
	end
end

class Arbol_Secuenciacion < ArbolGeneral
	def to_s (nivel = 0)
		str = ("\t" * nivel) + "SECUENCIACION \n"
		@hijos.each do |hijo|
			str += ("\t" * (nivel+1)) + hijo._to_s(nivel+2)
		end
		return str
	end
end

class ArbolBinario
	
	@desc_valor = ""
	@desc_izq = ""
	@desc_der = ""

	def initialize (valor = nil, izq = nil, der = nil)
		@valor = valor
		@izq = izq
		@der = der
	end

end

class Arbol_Rep_Det
	def initialize (id, from, to, instruccion, step = nil)
		@from = from
		@to = to
		@step = step
		@instruccion = instruccion
		@id = id
	end
	# TODO: to_s
end

ARBOLES.each do |tipo_arbol,descripcion| 

	Object.const_set("Arbol_#{tipo_arbol}",
		Class.new(ArbolBinario) do
			def _to_s (nivel = 2)
				tipo_arbol = self.class.to_s.sub("Arbol_","")
				desc_valor = ARBOLES[tipo_arbol][0]
				desc_izq = ARBOLES[tipo_arbol][1]
				desc_der = ARBOLES[tipo_arbol][2]
				str = tipo_arbol.upcase + " \n"
				str += ("\t" * (nivel)) + "#{desc_valor}: #{@valor._to_s} \n" unless @valor == nil
				str += ("\t" * (nivel)) + "#{desc_izq}: #{@izq._to_s(nivel+1)} \n" unless @izq == nil
				str += ("\t" * (nivel)) + "#{desc_der}: #{@der._to_s(nivel+1)} \n" unless @der == nil
				return str
			end
		end
	)
end