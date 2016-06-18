#!/usr/bin/ruby
# encoding: utf-8


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
	attr_reader :tabla
	def initialize (instr, tabla)
		@instr = instr
		@tabla = tabla
	end
	def set_tabla_padre (padre)
		@tabla.padre = padre
		@instr.set_tabla_padre(self)
	end
	def tabla_to_s(nivel=0)
		if @tabla.tabla.length > 0
			tabs = ("\t" * nivel)
			str = tabs + "TABLA DE SIMBOLOS\n"
			@tabla.tabla.each do |id,simbolo|
				str += simbolo.to_s(nivel+1) + "\n"
			end
			str += @instr.tabla_to_s(nivel+1)
			str
		else
			""
		end
	end

	def to_s
		str = tabla_to_s + "\n\n"
		str += "AST\n" + @instr.to_s
		str
	end
	def eval(a=nil,b=nil)
		# Evalúo primero las asignaciones del with y luego el resto de instrucciones
		@tabla.asignaciones.each do |asignacion|
			asignacion.eval(nil,@tabla)
		end
		@instr.eval(nil,@tabla)
	end
end

# Definimos la clase arbol binario para modelar árboles de derivación que a lo más tengan dos hijos
class ArbolBinario
	attr_reader :valor, :izq, :der, :posicion
	@desc_valor = ""
	@desc_izq = ""
	@desc_der = ""
	def initialize (token = nil, izq = nil, der = nil)
		# Si es un token, entonces guardo como valor el valor, si no, guardo directamente lo pasado.
		@valor = token.class.superclass == Token ? token.valor : token
		@izq = izq
		@der = der
		@posicion = token.class.superclass == Token ? {"linea" => token.linea, "columna" => token.columna} : nil
	end

	# Defino to_s como un alias de _to_s
	def to_s(nivel=1)
		self._to_s(nivel)
	end

	# Los árboles binarios deben implementar _to_s
	def _to_s(nivel=1) end

	def set_tabla_padre(padre) end

	def tabla_to_s(nivel=0)
		""
	end
	def calcularDimensionalidad
		0
	end
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
	
	def tabla_to_s(nivel=0)
		str = ""
		@hijos.each do |arbol|
			if arbol.class == ArbolBloque
				str += arbol.tabla_to_s(nivel+1)
			end
		end
		str
	end
	def set_tabla_padre(padre)
		@hijos.each do |arbol|
			if arbol.class == ArbolBloque
				arbol.set_tabla_padre(padre)
			end
		end
	end
	# Evaluar una secuenciacion es evaluar cada una de sus instrucciones
	def eval(tipo, tabla)
		@hijos.each do |instr|
			instr.eval(nil,tabla)
		end
	end
end

# Definimos la clase para modelar el árbol de una repetición determinada
class Arbol_Rep_Det
	def initialize (tkid, from, to, instruccion, step = Arbol_Literal_Num.new(1))
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

	def set_tabla_padre(padre) end

	def tabla_to_s(nivel=0)
		""
	end

	def eval(tipo, tabla)
		# Evaluamos from, to, step a ver si son enteros, y la instruccion de la repetición
		@from.eval(INT, tabla)
		@to.eval(INT, tabla)
		@step.eval(INT, tabla) unless @step.nil?
		@instruccion.eval(nil, tabla)
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

# Creamos el metodo eval para cada clase que chequea los tipos
# NOTA: nil representa cualquier tipo

class Arbol_Expr_Aritm
	def eval (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea entero o nil
		if tipo and tipo != INT
			raise ErrorTipo.new(@izq.posicion, tipo, INT)
		end
		@izq.eval(INT, tabla_sim)
		@der.eval(INT, tabla_sim)

		return INT
	end
end

class Arbol_Expr_Bool
	def eval (tipo, tabla_sim)
		# Chequeo que el tipo esperado sea bool o nil
		if tipo and tipo != BOOL
			raise ErrorTipo.new(@izq.posicion,tipo,BOOL)
		end
		@izq.eval(BOOL, tabla_sim)
		@der.eval(BOOL, tabla_sim)
		return BOOL
	end
end

class Arbol_Expr_Rel
	def eval (tipo, tabla_sim)
		# Chequeo que el tipo esperado sea bool o nil
		if tipo and tipo != BOOL
			raise ErrorTipo.new(@izq.posicion,tipo,BOOL)
		end		
		
		# Obtenemos el tipo del op_izq
		tipo_op_izq = @izq.eval(nil, tabla_sim)
		# Chequeamos que el op_der sea del mismo tipo que el izq
		tipo_op_der = @der.eval(tipo_op_der, tabla_sim)

		# Si estamos comparando matrices con un operador que no sea ni "=" ni "!=", error.
		if tipo_op_izq.tipo == "matrix" and @valor != "=" and @valor != "!="
			raise ErrorTipo.new(@izq.posicion,tipo_op_izq,INT,BOOL,CHAR)
		end
		return BOOL
	end
end

class Arbol_Expr_Unaria_Aritm
	def eval (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea int o nil
		if tipo and tipo != INT
			raise ErrorTipo.new(@posicion, tipo, INT)
		end
		@der.eval(INT, tabla_sim)
		return INT
	end
end

class Arbol_Expr_Unaria_Bool
	def eval (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea bool o nil
		if tipo and tipo != BOOL
			raise ErrorTipo.new(@posicion, tipo, BOOL)
		end
		@der.eval(BOOL, tabla_sim)
		return BOOL
	end
end

class Arbol_Expr_Char
	def eval (tipo, tabla_sim)
		operador = @izq
		# Chequeamos que el operando sea char
		@der.eval(CHAR, tabla_sim)
		# Chequeamos que el tipo esperado sea char si el operador es ++ o --
		if (operador == "++" or operador == "--") and tipo != CHAR
			raise ErrorTipo.new(@der.posicion,CHAR,tipo)
		end
		# Chequeamos que el tipo esperado sea int si el operador es #
		if operador == "#" and tipo != INT
			raise ErrorTipo.new(@der.posicion,INT,tipo)
		end
	end
end

class Arbol_Expr_Matr
	def eval (tipo, tabla_sim)
		# Si espero algo que no es matriz, error
		if tipo.tipo != "matrix"
			raise ErrorTipo.new(@posicion,tipo_op_izq,tipo)
		end
		tipo_op_izq = @izq.eval(tipo, tabla_sim)
		tipo_op_der = @der.eval(tipo, tabla_sim)
		# Si alguno de los dos es un literal (no tiene forma de indexacion), o si la forma de ambos es igual
		# entonces retorno el tipo del izq que es igual a der y a tipo porque llegamos hasta aqui
		if tipo_op_izq.forma.empty? or tipo_op_der.forma.empty? or tipo_op_izq.forma == tipo_op_der.forma
			return tipo_op_izq
		# Si la forma no cuadra, error de forma
		else
			return ErrorFormaIndexacion.new(@der.posicion,tipo_op_der.forma,tipo_op_izq.forma)
		end
	end
end

class Arbol_Expr_Unaria_Matr
	def eval (tipo, tabla_sim)
		# Chequeamos que se esté esperando una matriz
		if tipo.tipo != "matrix"
			raise ErrorTipo.new(@posicion,tipo_operando,tipo)
		end
		# Chequeamos que el operando concuerde con el tipo matriz esperado
		tipo_operando = @der.eval(tipo, tabla_sim)
		return tipo_operando
	end
end

class Arbol_Variable
	# @valor lleva el identificador
	def eval (tipo, tabla_sim)
		e = buscar(tabla_sim)
		# Si el tipo esperado es nil, o el tipo esperado concuerda con el tipo de la variable, retorna su tipo
		if !tipo or e.tipo == tipo
			return e.tipo
		end
		raise ErrorTipo.new(@posicion, tipo, e.tipo)
	end
	# Devuelve el simbolo que corresponde a la variable en la tabla de simbolos mas cercana
	def buscar (tabla_sim)
		if (e = tabla_sim.get(@valor))
			return e
		end
		# Si no encuentra la variable en ninguna tabla, la variable no está declarada
		raise ErrorVariableNoDeclarada.new(@posicion,@valor)
	end
end

class Arbol_Literal_Bool
	def eval (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea bool o nil
		if !tipo or tipo == BOOL
			return BOOL
		end
		raise ErrorTipo.new(@posicion,BOOL,tipo)
	end
end

class Arbol_Literal_Char
	def eval (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea char o nil
		if !tipo or tipo == CHAR
			return CHAR
		end
		raise ErrorTipo.new(@posicion,CHAR,tipo)
	end
end

class Arbol_Literal_Num
	def eval (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea int o nil
		if !tipo or tipo == INT
			return INT
		end
		raise ErrorTipo.new(@posicion,INT,tipo)
	end
end

class Arbol_Literal_Matr
	# Redefinimos el constructor de literal matriz para ajustarse a las necesidades
	def initialize (lista, tkInicio)
		# Si es un token, entonces guardo como valor el valor, si no, guardo directamente lo pasado.
		@valor = lista
		@izq = nil
		@der = nil
		@posicion = {"linea" => tkInicio.linea, "columna" => tkInicio.columna}
	end
	def calcularDimensionalidad
		dim = 1
		chequeo = true
		dim_ant = 0
		@valor.each do |elem|
			# Chequear que los tipos de los valores sean iguales
			dim_elem = elem.calcularDimensionalidad
			if dim_ant
				if dim_ant != dim_elem
					raise ErrorDimensiones.new(@posicion,dim_ant,dim_elem)
				end
			end
			dim_ant = dim_elem
		end
		return dim + dim_ant
	end
	def eval (tipo, tabla_sim)
		# Sacamaos la dimensionalidad del tipo esperado
		dim = tipo.dimensionalidad
		# El tipo esperado de los elementos de la matriz es una matriz con una dim menos, o si es de una dimension, el tipo de sus elementos
		if dim > 1
			tipo_esperado_elems = Tipo.new("matrix",tipo.dimensiones,tipo.tipo_param,dim-1,[],true)
		elsif dim == 1
			tipo_esperado_elems = tipo.tipo_param
		else
			# Se esperaba algo que no es una matriz
			d = calcularDimensionalidad()
			tipo_matr = Tipo.new("matrix",[],tipo,1,[],true)
			raise ErrorTipo.new(@posicion,tipo_matr,tipo)
		end
		tipo_esperado_param = tipo.tipo_param

		@valor.each do |elem|
			# Chequear que los tipos de los valores sean iguales
			tipo_elem = elem.eval(tipo_esperado_elems,tabla_sim)
			
			tipo_elem.tipo_param = tipo_esperado_param
			if tipo_elem != tipo_esperado_elems	
				raise ErrorTipo.new(@posicion, tipo_elem, tipo_esperado_elems)
			end
			if tipo_elem.dimensionalidad != tipo_esperado_elems.dimensionalidad
				raise ErrorDimensiones.new(@posicion,tipo_elem.dimensionalidad,tipo_esperado_elems.dimensionalidad)
			end
		end
		return Tipo.new("matrix",[],tipo_esperado_param,dim,[],true)
	end
end

class Arbol_Indexacion
	def eval (tipo, tabla_sim)
		index_dim = @der.length # Cuantas dimensiones se estan indexando
		tipo_esperado_param = tipo.dimensionalidad > 0 ? tipo.tipo_param : tipo
		# Se espera que el operando sea una matriz de dimension del tipo esperado + dim indexacion,
		# con elementos del mismo tipo
		tipo_esperado_operando = Tipo.new("matrix",[],tipo_esperado_param,tipo.dimensionalidad+index_dim,[],true)
		tipo_operando = @izq.eval(tipo_esperado_operando, tabla_sim)
		
		if tipo_operando.tipo != "matrix"
			raise ErrorTipo.new(@posicion,tipo_operando,tipo)
		end
		# Si la matriz no tiene forma (literal matr) o si la forma de indexacion coincide
		# con la forma que espera este tipo matriz ser indexada, pasa
		if tipo_operando.forma.empty? or index_dim == tipo_operando.forma[0]
			# El tipo resultante tendra tantas dimensiones menos como las que se indexen
			dimensionalidad = tipo_operando.dimensionalidad - index_dim
			forma = !tipo_operando.forma.empty? ? tipo_operando.forma.drop(1) : []
			dimensiones = !tipo_operando.dimensiones.empty? ? tipo_operando.dimensiones.drop(1) : []
			# Si la dimensionalidad resultante es >= 1, es una matriz, si no es el tipo de los elementos
			if dimensionalidad >= 1
				tipo_resultante = Tipo.new("matrix",dimensiones,tipo_operando.tipo_param,dimensionalidad,forma,true)
			else
				tipo_resultante = tipo_operando.tipo_param
			end
			# Si el tipo resultante es distinto al esperado, error
			if tipo_resultante != tipo
				raise ErrorTipo.new(@posicion,tipo_resultante,tipo)
			else
				return tipo_resultante
			end
		end
	end
end

class Arbol_Read
	def eval (tipo, tabla_sim)
		pos = @valor.posicion
		variable = @valor.valor
		if (e = tabla_sim.get(variable))
			if e.protegida
				raise ErrorModificacionVariableProtegida.new(pos,variable)
			end
			if e.tipo.tipo != "matrix"
				return e.tipo
			else
				raise ErrorTipo.new(pos,tipo,INT,BOOL,CHAR)
			end
		end
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

class Arbol_Asignacion
	def eval(tipo, tabla_sim)
		pos = @der.posicion # Posición del valor asignado
		identificador = @izq.valor
		tipo_var = @izq.eval(nil, tabla_sim)
		sim_var = @izq.buscar(tabla_sim)
		if (sim_var.protegida)
			raise ErrorModificacionVariableProtegida.new(pos,identificador)
		end
		rval_tipo = @der.eval(tipo_var,tabla_sim)
		# Si pasa todo esto, cambiamos el tipo del literal (dimensiones y forma)
		rval_tipo = tipo_var
	end
end