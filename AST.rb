#!/usr/bin/ruby
# encoding: utf-8

# CLASES:
# 		Object: Extencion, funcion _to_s para imprimir con identacion segun
#				el nivel de profundidad en el programa
# 		Array: 	Extencion, modificacion a _to_s
# 		Arboles pertinentes para el programa creados de manera general y extenciones especificas a:
# 			ArbolBloque
# 			ArbolBinario
# 			Arbol_Secuenciacion
# 			Arbol_Rep_Det
# 			Arbol_Expr_Aritm
# 			Arbol_Expr_Bool
# 			Arbol_Expr_Rel
# 			Arbol_Expr_Unaria_Aritm
# 			Arbol_Expr_Unaria_Bool
# 			Arbol_Expr_Char
# 			Arbol_Expr_Matr -------------(FALTA)
# 			Arbol_Expr_Unaria_Matr ------(FALTA)
# 			Arbol_Variable
# 			Arbol_Literal_Bool
# 			Arbol_Literal_Char
# 			Arbol_Literal_Num
# 			Arbol_Literal_Matr ----------(FALTA)

# Defino _to_s para todos los objetos, _to_s es básicamente un to_s que toma un parámetro,
# si la clase en cuestión no implementa _to_s, entonces simplemente se invoca to_s
class Object
	def _to_s (nivel=1)
		self.to_s
	end
end

# Se define _to_s para arreglos como un _to_s recursivo, de forma que se imprima la representación
# como string de cada elemento.
class Array
	def _to_s (nivel=1)
		if self.length == 0
			return "[]"
		end
		str = "[\n"
		self.each do |elem|
			str += ("\t" * (nivel)) + "#{elem._to_s(nivel+1)} \n"
		end
		str += ("\t" * (nivel-1)) + "]"
	end
end

# TODO: Las expresiones unarias son un caso particular, hay que interpretar "prefijo" y "posfijo"
ARBOLES = {
	'Expr_Aritm' => ["Operador", "Operando izquierdo", "Operando derecho"],
	'Expr_Bool' => ["Operador", "Operando izquierdo", "Operando derecho"],
	'Expr_Rel' => ["Operador", "Operando izquierdo", "Operando derecho"],
	'Expr_Matr' => ["Operador", "Operando izquierdo", "Operando derecho"],
	'Expr_Unaria_Bool' => [nil,"Operador", "Operando"],
	'Expr_Unaria_Aritm' => [nil,"Operador", "Operando"],
	'Expr_Unaria_Matr' => [nil,"Operador", "Operando"],
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

# Definimos una clase que representa un bloque de incorporación de alcance
class ArbolBloque
	def initialize (instr, tabla)
		@instr = instr
		@tabla = tabla
	end
	def set_tabla_padre (padre)
		@tabla.padre = padre
		padre.hijos << @tabla
	end
	def to_s
		str = @tabla.to_s + "\n"
		# str += "AST" + @instr.to_s
		str
	end
end

# Definimos la clase arbol binario para modelar árboles de derivación que a lo más tengan dos hijos
class ArbolBinario
	attr_reader :valor, :izq, :der
	@desc_valor = ""
	@desc_izq = ""
	@desc_der = ""
	def initialize (token = nil, izq = nil, der = nil)
		# Si es un token, entonces guardo como valor el valor, si no, guardo directamente lo pasado.
		@valor = token.class.superclass == Token ? token.valor : token
		@izq = izq
		@der = der
	end

	# Defino to_s como un alias de _to_s
	def to_s(nivel=1)
		self._to_s(nivel)
	end

	# Los árboles binarios deben implementar _to_s
	def _to_s(nivel=1) end

	def set_tabla_padre(padre) end
		
end

# Defino el arbol de una secuenciación como un árbol general
class Arbol_Secuenciacion
	def initialize (hijos = [], valor = nil)
		@valor = valor
		@hijos = hijos
	end

	# Defino to_s como un alias de _to_s
	def to_s(nivel=1)
		self._to_s(nivel)
	end

	def _to_s (nivel = 1)
		str = "SECUENCIACION \n"
		@hijos.each do |hijo|
			str += ("\t" * nivel) + hijo._to_s(nivel+1)
		end
		return str
	end
	
	def set_tabla_padre(padre)
		@hijos.each do |arbol|
			if arbol.class == ArbolBloque
				arbol.set_tabla_padre(padre)
			end
		end
	end
end

# Definimos la clase para modelar el árbol de una repetición determinada
class Arbol_Rep_Det
	def initialize (id, from, to, instruccion, step = 1)
		@from = from
		@to = to
		@step = step
		@instruccion = instruccion
		@id = id
	end
	
	# Defino to_s como un alias de _to_s
	def to_s(nivel=1)
		self._to_s(nivel)
	end

	def _to_s (nivel = 1)
		tabs = ("\t" * nivel)
		str = "REPETICION_DET\n"
		str += tabs + "Identificador: #{@id._to_s(nivel+1)}\n"
		str += tabs + "Valor inicial: #{@from._to_s(nivel+1)}\n"
		str += tabs + "Valor final: #{@to._to_s(nivel+1)}\n"
		str += tabs + "Paso: #{@step._to_s(nivel+1)}\n"
		str += tabs + "Instrucción: #{@instruccion._to_s(nivel+1)}\n"
		str
	end
end

# Creamos las clases de los árboles que se comportan como árboles binarios y se crea el
# método _to_s correspondiente
ARBOLES.each do |tipo_arbol,descripcion| 
	Object.const_set("Arbol_#{tipo_arbol}",
		Class.new(ArbolBinario) do
			def _to_s (nivel = 1)
				tipo_arbol = self.class.to_s.sub("Arbol_","")
				desc_valor = ARBOLES[tipo_arbol][0]
				desc_izq = ARBOLES[tipo_arbol][1]
				desc_der = ARBOLES[tipo_arbol][2]
				str = "#{tipo_arbol.upcase}\n"
				tabs = ("\t" * nivel)
				str += tabs + "#{desc_valor}: #{@valor._to_s(nivel+1)} \n" unless @valor == nil or desc_valor == nil
				str += tabs + "#{desc_izq}: #{@izq._to_s(nivel+1)} \n" unless @izq == nil or desc_izq == nil
				str += tabs + "#{desc_der}: #{@der._to_s(nivel+1)} \n" unless @der == nil or desc_der == nil
				return str
			end
		end
	)
end

# Creamos el metodo eval para cada clase

class Arbol_Expr_Aritm
	def eval (tipo, tabla_sim)
		op_izq = @izq.eval(tipo, tabla_sim)
		op_der = @der.eval(tipo, tabla_sim)
		case @valor
			when '+'
				valor = op_izq + op_der
			when '-'
				valor = op_izq - op_der
			when '/'
				valor = op_izq / op_der
			when '*'
				valor = op_izq * op_der
			when '%'
				valor = op_izq % op_der
		end
		return valor
	end
end

class Arbol_Expr_Bool
	def eval (tipo, tabla_sim)
		op_izq = @izq.eval(tipo, tabla_sim)
		op_der = @der.eval(tipo, tabla_sim)
		case @valor
			when '/\\'
				valor = op_izq and op_der
			when '\\/'
				valor = op_izq or op_der
		end
		return valor
	end
end

class Arbol_Expr_Rel
	def eval (tipo, tabla_sim)
		op_izq = @izq.eval(tipo, tabla_sim)
		op_der = @der.eval(tipo, tabla_sim)
		case @valor
			when '<'
				valor = op_izq < op_der
			when '<='
				valor = op_izq <= op_der
			when '>'
				valor = op_izq > op_der
			when '>='
				valor = op_izq >= op_der
			when '='
				valor = op_izq == op_der
		end
		return valor
	end
end

class Arbol_Expr_Unaria_Aritm
	def eval (tipo, tabla_sim)
		operando = @der.eval(tipo, tabla_sim)
		# El único operador unario es -
		return (-1) * operando
	end
end

class Arbol_Expr_Unaria_Bool
	def eval (tipo, tabla_sim)
		operando = @der.eval(tipo, tabla_sim)
		# El único operador unario es not
		return !operando
	end
end

class Arbol_Expr_Char
	def eval (tipo, tabla_sim)
		operador = @valor
		case operador
			when '++'
				operando = @der.eval(tipo, tabla_sim)
				operando_ascii = operando.codepoints.first
				valor = (operando_ascii + 1).chr
			when '--'
				operando = @der.eval(tipo, tabla_sim)
				operando_ascii = operando.codepoints.first
				valor = (operando_ascii - 1).chr
			when '#'
				operando = @der.eval('char',tabla_sim)
				valor = operando.codepoints.first
		end
		return valor		
	end
end

# PENDIENTE CON EL CHEQUEO DE TIPOS, Los literales se interpretan segun el contexto
class Arbol_Expr_Matr
	def eval (tipo, tabla_sim)
		# el unico operador es ::
		op_izq = @izq.eval(tipo, tabla_sim)
		op_der = @der.eval(tipo, tabla_sim)
		# para concatenar Matrix.build(4,2){|row,col| row<2?  m[row,col] : a[row-2,col]}


	end
end

class Arbol_Expr_Unaria_Matr
	def eval (tipo, tabla_sim)
		operando = @der.eval(tipo, tabla_sim)
		operador = @valor
		case operador
			when '$'
			when '?'
			when '[]'
		end
	end
end

class Arbol_Variable
	def eval (tipo, tabla_sim)
		if (e = tabla_sim.get(@valor))
			if (e.tipo == tipo)
				return e.valor
			end
			throw new ErrorTipo(tipo, e.tipo)
		end
		throw new VariableNoDeclarada(@valor) 
	end
end

class Arbol_Literal_Bool
	def eval (tipo, tabla_sim)
		if tipo == 'bool'
			return @valor
		end
		throw new ErrorTipo(tipo,'bool')
	end
end

class Arbol_Literal_Char
	def eval (tipo, tabla_sim)
		if tipo == 'char'
			return @valor
		end
		throw new ErrorTipo(tipo,'char')
	end
end

class Arbol_Literal_Num
	def eval (tipo, tabla_sim)
		if tipo.tipo == 'int'
			return Integer(@valor)
		end
		throw new ErrorTipo(tipo,'int')
	end
end

class Arbol_Literal_Matr
	def eval (tipo, tabla_sim)
		if tipo == 'int'
			return @valor
		end
		throw new ErrorTipo(tipo,'int')
	end
end