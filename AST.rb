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
	'Expr_Matr' => ["Operador", "Operando izquierdo", "Operando derecho"],	#Falta
	'Expr_Unaria_Bool' => [nil,"Operador", "Operando"],
	'Expr_Unaria_Aritm' => [nil,"Operador", "Operando"],
	'Expr_Unaria_Matr' => [nil,"Operador", "Operando"],						#Falta
	'Expr_Char' => [nil,"Operador", "Operando"],
	'Indexacion' => [nil,"Matriz", "Índice"],
	'Asignacion' => [nil,"Contenedor", "Expresión"],
	'Condicional' => ["Guardia","Éxito","Fracaso"],
	'Rep_Indet' => [nil,"Guardia","Instrucción"],
	'Variable' => ["Identificador",nil,nil],
	'Literal_Bool' => ["Valor",nil,nil],
	'Literal_Char' => ["Valor",nil,nil],
	'Literal_Num' => ["Valor",nil,nil],
	'Literal_Matr' => ["Valor",nil,nil],									#Falta
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
		#str = "IMPRESION\n"
		str = @tabla.to_s + "\n"
		#str += "AST\n" + @instr.to_s
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
	def initialize (tkid, from, to, instruccion, step = 1)
		@from = from
		@to = to
		@step = step
		@instruccion = instruccion
		@id = tkid.valor
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
		if tipo != INT or tipo != nil
			throw ErrorTipo.new(INT,tipo)
		end
		op_izq = @izq.eval(INT, tabla_sim)['valor']
		op_der = @der.eval(INT, tabla_sim)['valor']
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
		return {"tipo" => INT, "valor" => valor}
	end
end

class Arbol_Expr_Bool
	def eval (tipo, tabla_sim)
		if tipo != BOOL or tipo != nil
			throw ErrorTipo.new(BOOL,tipo)
		end
		op_izq = @izq.eval(BOOL, tabla_sim)['valor']
		op_der = @der.eval(BOOL, tabla_sim)['valor']
		case @valor
			when '/\\'
				valor = op_izq and op_der
			when '\\/'
				valor = op_izq or op_der
		end
		return {"tipo" => BOOL, "valor" => valor}
	end
end

class Arbol_Expr_Rel
	def eval (tipo, tabla_sim)
		if tipo != BOOL or tipo != nil
			throw ErrorTipo.new(BOOL,tipo)
		end		
		op_izq = @izq.eval(tipo, tabla_sim)
		op_der = @der.eval(op_izq.tipo, tabla_sim)
		if op_izq.tipo == op_der.tipo
			throw ErrorTipo.new(op_izq.tipo,op_der.tipo)
		else
			op_izq = op_izq['valor']
			op_der = op_der['valor']
		end
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
		return {"tipo" => BOOL, "valor" => valor}
	end
end

class Arbol_Expr_Unaria_Aritm
	def eval (tipo, tabla_sim)
		if tipo != INT or tipo != nil
			throw ErrorTipo.new(INT,tipo)
		end
		operando = @der.eval(INT, tabla_sim)['valor']
		# El único operador unario es -
		return {"tipo" => INT, "valor" => (-1) * operando}
	end
end

class Arbol_Expr_Unaria_Bool
	def eval (tipo, tabla_sim)
		if tipo != BOOL or tipo != nil
			throw ErrorTipo.new(BOOL,tipo)
		end
		operando = @der.eval(BOOL, tabla_sim)['valor']
		# El único operador unario es not
		return {"tipo" => BOOL, "valor" => !operando}
	end
end

class Arbol_Expr_Char
	def eval (tipo, tabla_sim)
		operador = @izq
		tipo_retornado = CHAR
		case operador
			when '++'
				if tipo == CHAR or !tipo
					operando = @der.eval(CHAR, tabla_sim)['valor']
					operando_ascii = operando.codepoints.first
					return {"tipo" => CHAR, "valor" => (operando_ascii + 1).chr}
				end
			when '--'
				if tipo == CHAR or !tipo
					operando = @der.eval(CHAR, tabla_sim)['valor']
					operando_ascii = operando.codepoints.first
					return {"tipo" => CHAR, "valor" => (operando_ascii - 1).chr}
				end
			when '#'
				tipo_retornado = INT
				if tipo == INT or !tipo
					puts "HEYYY : #{tipo}"
					operando = @der.eval(CHAR, tabla_sim)['valor']
					return {"tipo" => INT, "valor" => operando.codepoints.first}
				end
		end
		throw ErrorTipo.new(tipo,tipo_retornado)
	end
end

# PENDIENTE CON EL CHEQUEO DE TIPOS, Los literales se interpretan segun el contexto
class Arbol_Expr_Matr
	def eval (tipo, tabla_sim)
		# el unico operador es ::
		if !tipo or tipo.tipo == "matrix"
			op_izq = @izq.eval(tipo, tabla_sim)
			op_der = @der.eval(tipo, tabla_sim)
		end
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
			if (e.tipo == tipo or !tipo)
				return {"tipo" => e.tipo, "valor" => e.valor}
			end
			throw ErrorTipo.new(tipo, e.tipo)
		end
		throw VariableNoDeclarada.new(@valor) 
	end
end

class Arbol_Literal_Bool
	def eval (tipo, tabla_sim)
		if tipo == BOOL or !tipo
			return {"tipo" => BOOL, "valor" => @valor}
		end
		throw ErrorTipo.new(tipo,BOOL)
	end
end

class Arbol_Literal_Char
	def eval (tipo, tabla_sim)
		if tipo == CHAR or !tipo
			return {"tipo" => CHAR, "valor" => @valor}
		end
		throw ErrorTipo.new(tipo,CHAR)
	end
end

class Arbol_Literal_Num
	def eval (tipo, tabla_sim)
		if tipo == INT or !tipo
			return {"tipo" => INT, "valor" => Integer(@valor)}
		end
		throw ErrorTipo.new(tipo,INT)
	end
end

class Arbol_Literal_Matr
	def eval (tipo, tabla_sim)
		if tipo == 'int'
			return @valor
		end
		throw ErrorTipo.new(tipo,'int')
	end
end

class Arbol_Read
	def eval (tipo, tabla_sim)
		e = @valor.eval(nil, tabla_sim)
		return {"tipo" => e.tipo, "valor" => e.valor}
	end
end
class Arbol_Print
	def eval (tipo, tabla_sim)
		@valor.eval(nil,tabla_sim)
	end
end

class Arbol_Rep_Indet
	def eval(tipo, tabla_sim)
		@izq.eval(BOOL, tabla_sim)
		@der.eval(nil, tabla_sim)
	end
end

class Arbol_Condicional
	def eval(tipo, tabla_sim)
		@valor.eval(BOOL, tabla_sim)
		@izq.eval(nil,tabla_sim)
		@der.eval(nil,tabla_sim)
	end
end
