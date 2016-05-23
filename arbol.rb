# Defino un wrapper de to_s que:
# - Cuando es llamado por árboles, manda a llamar el método to_s con el nivel correspondiente
# - Cuando es llamado por un arreglo, imprimo "[" _to_s de cada elemento "]", con el nivel correspondiente
# - En el resto de los casos, simplemente hace la llamada a to_s
class Object
	def _to_s (nivel=0)
		str = "[\n"
		if self.class == Array
			self.each do |elem|
				str += ("\t" * (nivel)) + "#{elem._to_s(nivel+1)} \n"
			end
			str += ("\t" * (nivel-1)) + "]"
		elsif self.class.superclass == ArbolBinario || self.class.superclass == ArbolGeneral
			to_s(nivel)
		else
			to_s
		end
	end
end
# TODO: Las expresiones unarias son un caso particular, hay que interpretar "prefijo" y "posfijo"
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
			def to_s (nivel = 1)
				tipo_arbol = self.class.to_s.sub("Arbol_","")
				desc_valor = ARBOLES[tipo_arbol][0]
				desc_izq = ARBOLES[tipo_arbol][1]
				desc_der = ARBOLES[tipo_arbol][2]
				str = "#{tipo_arbol.upcase}\n"
				str += ("\t" * (nivel)) + "#{desc_valor}: #{@valor._to_s(nivel+1)} \n" unless @valor == nil or desc_valor == nil
				str += ("\t" * (nivel)) + "#{desc_izq}: #{@izq._to_s(nivel+1)} \n" unless @izq == nil or desc_izq == nil
				str += ("\t" * (nivel)) + "#{desc_der}: #{@der._to_s(nivel+1)} \n" unless @der == nil or desc_der == nil
				return str
			end
		end
	)
end