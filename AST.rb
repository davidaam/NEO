#!/usr/bin/ruby
# encoding: utf-8


# Defino _to_s para todos los objetos, _to_s es básicamente un to_s que toma un parámetro,
# si la clase en cuestión no implementa _to_s, entonces simplemente se invoca to_s
class Object
	def _to_s (nivel=1)
		self.to_s
	end
	def eval (tabla_sim)
		return self
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
	def calcularTamano
		if self.length == 0
			return [0]
		end
		tamanos = [self.length]
		tam_ant = nil
		tam_h = []
		self.each do |l|
			if l.class == Array
				tam_h = l.calcularTamano
				if !tam_ant.nil?
					if tam_ant != tam_h
						return nil
					end
				end
				tam_ant = tam_h
			end
		end
		if tam_h.nil?
			return nil
		end
		return tamanos + tam_h
	end
	def eval (tabla_sim)
		i = 0
		l = Array.new(self)
		while i < l.length
			l[i] = l[i].eval(tabla_sim)
			i += 1
		end
		return l
	end
	def nest (k)
		if k == 0
			return self
		end
		return [self.nest(k-1)]
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
	def set_tabla_padre (padre=nil)
		@tabla.padre = padre
		@instr.set_tabla_padre(self.tabla)
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
	def check(a=nil,b=nil)
		# chequeo primero las asignaciones del with y luego el resto de instrucciones
		@tabla.asignaciones.each do |asignacion|
			asignacion.check(nil,@tabla)
		end
		@instr.check(nil,@tabla)
	end
	def eval(tabla_sim=nil)
		# evaluó los tamaños de las matrices
		@tabla.tabla.each do |id,simbolo|
			if !simbolo.tipo.dimensiones.nil?
				l = simbolo.tipo.dimensiones
				i = 0
				while i < l.length
					j = 0
					while j < l[i].length
						l[i][j].check(INT, @tabla)
						l[i][j] = l[i][j].eval(@tabla)
						j += 1
					end
					i += 1
				end	
			end
		end
		# evalúo primero las asignaciones del with y luego el resto de instrucciones
		@tabla.asignaciones.each do |asignacion|
			asignacion.eval(@tabla)
		end
		@instr.eval(@tabla)
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
	# chequear una secuenciacion es checkuar cada una de sus instrucciones
	def check(tipo, tabla)
		@hijos.each do |instr|
			instr.check(nil,tabla)
		end
	end
	def eval(tabla_sim)
		@hijos.each do |instr|
			instr.eval(tabla_sim)
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

	def set_tabla_padre(padre)
		@instruccion.set_tabla_padre(padre)
	end

	def tabla_to_s(nivel=0)
		""
	end

	def check(tipo, tabla)
		# chequeamos from, to, step a ver si son enteros, y la instruccion de la repetición
		@from.check(INT, tabla)
		@to.check(INT, tabla)
		@step.check(INT, tabla) unless @step.nil?
		@instruccion.check(nil, tabla)
	end
	
	def eval(tabla_sim)
		step = @step.eval(tabla_sim)

		if step == 0
			raise ErrorPasoCero.new(@posicion)
		end

		from = @from.eval(tabla_sim)
		to = @to.eval(tabla_sim)
		
		pasos = [(to - from + 1)/step, 0].max
		
		identificador = tabla_sim.get(@id)
		identificador.valor = from
		
		(0...pasos).each do |i|
			@instruccion.eval(tabla_sim)
			identificador.valor += step
		end
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

# Creamos el metodo check para cada clase que chequea los tipos
# NOTA: nil representa cualquier tipo

class Arbol_Expr_Aritm
	def check (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea entero o nil
		if tipo and tipo != INT
			raise ErrorTipo.new(@izq.posicion, tipo, INT)
		end
		@izq.check(INT, tabla_sim)
		@der.check(INT, tabla_sim)
		return INT
	end
	def eval (tabla_sim)
		op_izq = @izq.eval(tabla_sim)
		op_der = @der.eval(tabla_sim)
		operador = @valor
		case operador
			when '+'
				return op_izq + op_der
			when '-'
				return op_izq - op_der
			when '*'
				return op_izq * op_der
			when '/'
				if op_der == 0
					raise ErrorDivisionEntreCero.new(@der.posicion)
				else
					return op_izq / op_der
				end
			when '%'
				if op_der == 0
					raise ErrorDivisionEntreCero.new(@der.posicion)
				else
					return op_izq % op_der
				end
		end
	end
end

class Arbol_Expr_Bool
	def check (tipo, tabla_sim)
		# Chequeo que el tipo esperado sea bool o nil
		if tipo and tipo != BOOL
			raise ErrorTipo.new(@izq.posicion,tipo,BOOL)
		end
		@izq.check(BOOL, tabla_sim)
		@der.check(BOOL, tabla_sim)
		return BOOL
	end
	def eval (tabla_sim)
		op_izq = @izq.eval(tabla_sim)
		op_der = @der.eval(tabla_sim)
		operador = @valor
		case operador
			when "/\\"
				op_izq and op_der
			when "\\/"
				op_izq or op_der
		end
	end
end

class Arbol_Expr_Rel
	def check (tipo, tabla_sim)
		# Chequeo que el tipo esperado sea bool o nil
		if tipo and tipo != BOOL
			raise ErrorTipo.new(@izq.posicion,tipo,BOOL)
		end		
		
		# Obtenemos el tipo del op_izq
		tipo_op_izq = @izq.check(nil, tabla_sim)
		# Chequeamos que el op_der sea del mismo tipo que el izq
		tipo_op_der = @der.check(tipo_op_der, tabla_sim)

		# Si estamos comparando matrices con un operador que no sea ni "=" ni "!=", error.
		if tipo_op_izq.tipo == "matrix" and @valor != "=" and @valor != "!="
			raise ErrorTipo.new(@izq.posicion,tipo_op_izq,INT,BOOL,CHAR)
		end
		return BOOL
	end
	def eval (tabla_sim)
		op_izq = @izq.eval(tabla_sim)
		op_der = @der.eval(tabla_sim)
		operador = @valor
		case operador
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
	end
end

class Arbol_Expr_Unaria_Aritm
	def check (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea int o nil
		if tipo and tipo != INT
			raise ErrorTipo.new(@posicion, tipo, INT)
		end
		@der.check(INT, tabla_sim)
		return INT
	end
	def eval (tabla_sim)
		return (-1) * @der.valor
	end
end

class Arbol_Expr_Unaria_Bool
	def check (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea bool o nil
		if tipo and tipo != BOOL
			raise ErrorTipo.new(@posicion, tipo, BOOL)
		end
		@der.check(BOOL, tabla_sim)
		return BOOL
	end
	def eval (tabla_sim)
		return !@der.valor
	end 
end

class Arbol_Expr_Char
	def check (tipo, tabla_sim)
		operador = @izq
		# Chequeamos que el operando sea char
		@der.check(CHAR, tabla_sim)
		# Chequeamos que el tipo esperado sea char si el operador es ++ o --
		if (operador == "++" or operador == "--") and tipo and tipo != CHAR
			raise ErrorTipo.new(@der.posicion,CHAR,tipo)
		end
		# Chequeamos que el tipo esperado sea int si el operador es #
		if operador == "#" and tipo and tipo != INT
			raise ErrorTipo.new(@der.posicion,INT,tipo)
		end
	end
	def eval (tabla_sim)
		operador = @izq
		operando = @der.eval(tabla_sim)
		valor_ascii = operando.codepoints.first
		case operador
			when '++'
				return (valor_ascii+1).chr
			when '--'
				return (valor_ascii-1).chr
			when '#'
				return valor_ascii
		end
	end
end

class Arbol_Expr_Matr
	def check (tipo, tabla_sim)
		# Si espero algo que no es matriz, error
		if tipo and tipo.tipo != "matrix"
			raise ErrorTipo.new(@posicion,tipo_op_izq,tipo)
		end
		tipo_op_izq = @izq.check(tipo, tabla_sim)
		tipo_op_der = @der.check(tipo, tabla_sim)
		# Si alguno de los dos es un literal (no tiene forma de indexacion), o si la forma de ambos es igual
		# entonces retorno el tipo del izq que es igual a der y a tipo porque llegamos hasta aqui
		if tipo_op_izq.forma.empty? or tipo_op_der.forma.empty? or tipo_op_izq.forma == tipo_op_der.forma
			return tipo_op_izq
		# Si la forma no cuadra, error de forma
		else
			return ErrorFormaIndexacion.new(@der.posicion,tipo_op_der.forma,tipo_op_izq.forma)
		end
	end
	def eval(tabla_sim)
		# El único operador binario de matrices es concatenación
		tipo_izq = @izq.check(nil,tabla_sim)
		tipo_der = @izq.check(nil,tabla_sim)
		op_izq = @izq.eval(tabla_sim)
		op_der = @der.eval(tabla_sim)
		if !tipo_izq.dimensiones.empty?
			tipo_izq.dimensiones[-1][-1] += tipo_der.dimensiones[-1][-1]  
		end
		tipo_res = tipo_izq
		if tipo_izq.dimensionalidad > 1
			res = []
			i = 0
			izq_flat = []
			der_flat = []
			while i < op_izq.length
				izq_flat << op_izq[i].flatten
				der_flat << op_der[i].flatten
				i += 1
			end
			i = 0
			while i < op_izq.length
				res << (izq_flat[i] + der_flat[i]).nest(tipo_izq.dimensionalidad-2)
				i += 1
			end
		else
			res = op_izq + op_der
		end
		return res
	end
end

class Arbol_Expr_Unaria_Matr
	def check (tipo, tabla_sim)
		# Chequeamos que se esté esperando una matriz
		if tipo and tipo.tipo != "matrix"
			raise ErrorTipo.new(@posicion,tipo_operando,tipo)
		end
		# Chequeamos que el operando concuerde con el tipo matriz esperado
		tipo_operando = @der.check(tipo, tabla_sim)
		return tipo_operando
	end
	def eval (tabla_sim)
		operador = @izq
		operando = @der.eval(tabla_sim)
		case operador
			when "?"
				return operando.transpose
			when "$"
				last = operando.pop
				return operando.unshift(last)
		end
	end
end

class Arbol_Variable
	# @valor lleva el identificador
	def check (tipo, tabla_sim)
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
	def eval (tabla_sim)
		simbolo = buscar(tabla_sim)
		if simbolo.valor.nil?
			raise ErrorVariableNoInstanciada.new(@posicion, @valor)
		else
			return simbolo.valor
		end
	end
end

class Arbol_Literal_Bool
	def check (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea bool o nil
		if !tipo or tipo == BOOL
			return BOOL
		end
		raise ErrorTipo.new(@posicion,BOOL,tipo)
	end
	def eval (tabla_sim)
		return @valor == 'true' ? true : false
	end
end

class Arbol_Literal_Char
	def check (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea char o nil
		if !tipo or tipo == CHAR
			return CHAR
		end
		raise ErrorTipo.new(@posicion,CHAR,tipo)
	end
	def eval (tabla_sim)
		return @valor
	end
end

class Arbol_Literal_Num
	def check (tipo, tabla_sim)
		# Chequeamos que el tipo esperado sea int o nil
		if !tipo or tipo == INT
			return INT
		end
		raise ErrorTipo.new(@posicion,INT,tipo)
	end
	def eval (tabla_sim)
		Integer(@valor)
	end
end

class Arbol_Literal_Matr
	attr_accessor :valor
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
		dim_ant = nil
		@valor.each do |elem|
			# Chequear que los tipos de los valores sean iguales	
			dim_elem = elem.calcularDimensionalidad
			if !dim_ant.nil?
				if dim_ant != dim_elem
					raise ErrorDimensiones.new(@posicion,dim_ant,dim_elem)
				end
			end
			dim_ant = dim_elem
		end
		return dim + dim_ant
	end
	def calcularTamano
		tam = @valor.calcularTamano
		if tam.nil?
			raise ErrorTamanoMatriz.new(@posicion)
		end
		return tam
	end
	def check (tipo, tabla_sim)
		# Sacamaos la dimensionalidad del tipo esperado
		dim = tipo ? tipo.dimensionalidad : self.calcularDimensionalidad
		if tipo.nil?
			if !@valor.empty?
				tipo_hijos = @valor[0].check(tipo, tabla_sim)
				@valor.each do |e|
					e.check(tipo_hijos, tabla_sim)
				end				
				if dim == 1
					tipo_elems = tipo_hijos
				elsif dim > 1
					tipo_elems = tipo_hijos.tipo_param
				end
				tipo_elems.tipo_param = nil
				return Tipo.new("matrix",[],tipo_elems,dim,[],true)
			else
				# Caso lista vacia
			end
		end
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
			tipo_elem = elem.check(tipo_esperado_elems,tabla_sim)
			
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
	def eval (tabla_sim)
		tam = self.calcularTamano # Si falla el metodo lanza error
		lelems = @valor.eval(tabla_sim)
		self.valor = lelems
	end

end

class Arbol_Indexacion
	def check (tipo, tabla_sim)
		tipo_izq = @izq.check(nil, tabla_sim)
		forma = @izq.class == Arbol_Variable ? @izq.buscar(tabla_sim).tipo.forma : []
		index_dim = @der.length # Cuantas dimensiones se estan indexando
		if !forma.empty? and @der.length != forma[0]
			raise ErrorFormaIndexacion.new(@izq.posicion,@der.length,forma.length)
		end
		if tipo.nil?
			if tipo_izq.dimensionalidad - index_dim >= 1
				return Tipo.new("matrix",[],tipo_izq.tipo_param,tipo_izq.dimensionalidad-1,[],true)
			else
				return tipo_izq.tipo_param
			end
		end

		index_dim = @der.length # Cuantas dimensiones se estan indexando
		tipo_esperado_param = tipo.dimensionalidad > 0 ? tipo.tipo_param : tipo
		# Se espera que el operando sea una matriz de dimension del tipo esperado + dim indexacion,
		# con elementos del mismo tipo
		tipo_esperado_operando = Tipo.new("matrix",[],tipo_esperado_param,tipo.dimensionalidad+index_dim,[],true)
		tipo_operando = @izq.check(tipo_esperado_operando, tabla_sim)
		
		# Si la matriz no tiene forma (literal matr) o si la forma de indexacion coincide
		# con la forma que espera este tipo matriz ser indexada, pasa

		if tipo_operando.forma.empty? or index_dim == tipo_operando.forma[0]
			# El tipo resultante tendra tantas dimensiones menos como las que se indexen
			dimensionalidad = tipo_operando.dimensionalidad - index_dim
			forma = !tipo_operando.forma.empty? ? tipo_operando.forma.drop(1) : []
			if tipo.forma != forma
				return ErrorFormaIndexacion.new(@der.posicion,tipo_op_der.forma,tipo_op_izq.forma)
			end
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
	def eval (tabla_sim)
		indices = @der.eval(tabla_sim)
		# Sacamos los tamaños de las dimensiones indexadas
		tam = @izq.eval(tabla_sim).calcularTamano[0...indices.length]
		
		tam.each_with_index do |tam_i, i| 
			if tam_i <= indices[i]
				raise ErrorIndexacionFueraLimites.new(@izq.posicion,indices,tam)
			end
		end
		matr = @izq.eval(tabla_sim)
		indices.each do |i|
			matr = matr[i]
		end
		return matr
	end
end

class Arbol_Read
	def check (tipo, tabla_sim)
		pos = @valor.posicion
		variable = @valor.valor
		if (e = tabla_sim.get(variable))
			if e.protegida
				raise ErrorModificacionVariableProtegida.new(pos,variable)
			end
			return e.tipo
		end
	end
	def eval (tabla_sim)
		valor = $stdin.gets.chomp
		if @valor.class == Arbol_Variable
			simbolo = @valor.buscar(tabla_sim)
		else
			simbolo = @valor.izq.buscar(tabla_sim)
		end
		tipo = simbolo.tipo
		if tipo.tipo == "matrix"
			if valor[0] == "{" and valor[-1] == "}"
				literal_str = valor.gsub!('{','[').gsub!('}',']')
				begin 
					rval = Kernel::eval(literal_str)	
				rescue SyntaxError
					raise ErrorLectura.new(@posicion,"matrix")
				end
			else
				raise ErrorLectura.new(@posicion,"matrix")
			end
		end

		case tipo
			when INT
				begin
					rval = Integer(valor)
				rescue ArgumentError
					raise ErrorLectura.new(@posicion, "int")
				end
			when BOOL
				if valor == "true"
					rval = true
				elsif valor == "false"
					rval = false
				else
					raise ErrorLectura.new(@posicion, "bool")
				end
			when CHAR
				if valor.match (/([^'\\]|\\n|\\t|\\'|\\\\)$/)
					rval = $1
				else
					raise ErrorLectura.new(@posicion, "char")
				end	
		end	

		if @valor.class == Arbol_Variable
			simbolo.valor = rval
		else
			indices = @valor.der.eval(tabla_sim)
			matr = simbolo.valor
			i = 0
			while i < indices.length
				matr = matr[indices[i]]
				i += 1
			end
			if matr.class == Array
				i = 0
				while i < indices.length
					matr[i] = rval[i]
					i += 1
				end
			else
				i = 0
				while i < indices.length-1
					matr = matr[indices[i]]
					i += 1
				end
				matr[indices[-1]] = rval
			end
		end
	end
end
class Arbol_Print
	def check (tipo, tabla_sim)
		v = @valor.check(nil,tabla_sim)
	end
	def eval (tabla_sim)
		puts @valor.eval(tabla_sim).to_s
	end
end

class Arbol_Rep_Indet
	def check(tipo, tabla_sim)
		@izq.check(BOOL, tabla_sim)
		@der.check(nil, tabla_sim)
	end
	def eval(tabla_sim)
		while (@izq.eval(tabla_sim))
			@der.eval(tabla_sim)
		end
	end
end

class Arbol_Condicional
	def check(tipo, tabla_sim)
		@valor.check(BOOL, tabla_sim)
		@izq.check(nil,tabla_sim)
		if !@der.nil?
			@der.check(nil,tabla_sim)
		end
	end
	def eval (tabla_sim)
		if (@valor.eval(tabla_sim))
			@izq.eval(tabla_sim)
		elsif (!@der.nil?)
			@der.eval(tabla_sim)	
		end
	end
end

class Arbol_Asignacion
	def check(tipo, tabla_sim)
		if @izq.class == Arbol_Variable
			pos = @der.posicion # Posición del valor asignado
			identificador = @izq.valor
			tipo_var = @izq.check(nil, tabla_sim)
			sim_var = @izq.buscar(tabla_sim)
			if (sim_var.protegida)
				raise ErrorModificacionVariableProtegida.new(pos,identificador)
			end
			rval_tipo = @der.check(tipo_var,tabla_sim)
			# Si pasa todo esto, cambiamos el tipo del literal (dimensiones y forma)
			rval_tipo = tipo_var
		# Indexacion
		else
			pos = @der.posicion # Posición del valor asignado
			identificador = @izq.valor
			tipo_var = @izq.izq.check(nil, tabla_sim)
			sim_var = @izq.izq.buscar(tabla_sim)
			if (sim_var.protegida)
				raise ErrorModificacionVariableProtegida.new(pos,identificador)
			end
			rval_tipo = tipo_var.dup
			rval_tipo.dimensiones = rval_tipo.dimensiones[1...(rval_tipo.dimensiones.length)]
			binding.pry
			rval_tipo.dimensionalidad -= @izq.der.length
			if rval_tipo.dimensionalidad == 0
				rval_tipo = rval_tipo.tipo_param
			end
			rval_tipo = @der.check(rval_tipo,tabla_sim)
			# Si pasa todo esto, cambiamos el tipo del literal (dimensiones y forma)
		end
	end
	def eval (tabla_sim)
		rval = @der.eval(tabla_sim)
		if @izq.class == Arbol_Variable
			sim_var = @izq.buscar(tabla_sim)
			if sim_var.tipo.tipo == "matrix"
				if rval.calcularTamano != sim_var.tipo.dimensiones.flatten
					raise ErrorTamanoMatriz.new(@der.posicion) # tentativo
				end
			end
			sim_var.valor = rval
		# Indexacion
		else
			sim_var = @izq.izq.buscar(tabla_sim)
			indices = @izq.der.eval(tabla_sim)
			matr = sim_var.valor
			i = 0
			while i < indices.length
				matr = matr[indices[i]]
				i += 1
			end
			if matr.class == Array
				i = 0
				while i < matr.length
					matr[i] = rval[i]
					i += 1
				end
			else
				i = 0
				matr = sim_var.valor 
				while i < indices.length-1
					matr = matr[indices[i]]
					i += 1
				end
				matr[indices[-1]] = rval
			end
		end
	end
end