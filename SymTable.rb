#!/usr/bin/ruby
# encoding: utf-8

# CLASES:
# 		TablaSimbolors
# 		Simbolo
# 		Tipo
# 		ErrorDimensiones

class TablaSimbolos
	attr_reader :tabla
	attr_accessor :padre, :hijos
	def initialize (lista_sim, padre = nil)
		@padre = padre
		@hijos = []
		@tabla = {}
		lista_sim.each do |s|
			if @tabla.has_key?(s.id)
				raise ErrorRedeclaracion.new(s.id, s.ultima_Posicion)
			else
				add(s)
			end
		end
	end
	def add (simbolo)
		simbolo.eval(@tabla)
		@tabla[simbolo.id] = simbolo 
	end
	def get (id)
		e = self
		while e != nil
			if e.tabla.has_key?(id)
				return e.tabla[id]
			end
			e = e.padre
		end
		return nil
	end
	def update(lvalue, arbol_expr, posicion)
		simbolo = get(lvalue)
		if simbolo != nil
			rvalue = arbol_expr.eval(simbolo.tipo,self)['valor']
			simbolo.valor = rvalue
		else
			raise ErrorVariableNoDeclarada.new(id, posicion)
		end
	end
	def to_s(nivel=0)
		tabs = ("\t" * nivel)
		str = tabs + "TABLA DE SIMBOLOS\n"
		@tabla.each do |id,simbolo|
			str += simbolo.to_s(nivel+1) + "\n"
		end
		@hijos.each do |tabla_h|
			str += "\n" + tabla_h.to_s(nivel+1)
		end
		str
	end
end

class Simbolo
	attr_reader :id , :tipo, :protegida
	attr_accessor :valor, :ultima_Posicion
	def initialize (tkid, tipo=nil,valor = nil,protegida=false)
		@id = tkid.valor
		@tipo = tipo
		@valor = valor
		@protegida = protegida
		@ultima_Posicion = {"linea" => tkid.linea, "columna" => tkid.columna}
	end
	def set_type(tipo)
		@tipo = tipo
		self
	end
	def eval(tabla)
		@tipo.eval(tabla)
		@valor = @valor.eval(@tipo,tabla)['valor'] if @valor != nil
	end
	def to_s(nivel = 0)
		tabs = "\t" * nivel
		str = tabs + "Identificador: #{@id} \n\t" + tabs + "Tipo: #{@tipo.to_s}\n"
		str += tabs + "\tValor: #{@valor}\n" unless valor == nil
		str
	end
end

class Tipo
	attr_reader :tipo, :dimensiones
	def initialize(tipo,dimensiones=nil,tipo_param=nil)
		@tipo = tipo
		@dimensiones = dimensiones
		@tipo_param = tipo_param
	end
	def eval(tabla)
		@dimensiones.map! {|dim| dim.eval(Tipo.new('int'),tabla)} unless @dimensiones == nil
		@tipo_param.eval(tabla) unless !(@tipo_param)
	end
	def ==(x)
		eq = @tipo == x.tipo
		# Si los dos son distintos de nil
		if @dimensiones and x.dimensiones
			if @dimensiones.length == x.dimensiones.length
				for i in 0...@dimensiones.length
					eq = eq and x.dimensiones[i] == @dimensiones[i]
				end
			end
		# Si al menos uno es distinto de nil
		elsif @dimensiones != x.dimensiones
			raise ErrorDimensiones.new(@dimensiones,x.dimensiones)
		end
		eq
	end
	def to_s
		str = @tipo
		str += " " + @dimensiones if @dimensiones
		str += " of " + @tipo_param.to_s if @tipo_param
		str
	end
end

# Errores

class ErrorEstatico < RuntimeError
end

class ErrorDimensiones < ErrorEstatico
	def initialize(dim1,dim2)
		@dim1 = dim1
		@dim2 = dim2
		#@linea = posicion["linea"]
		#@columna = posicion["columna"]
	end
	def to_s
		#"En la linea: #{@linea} y columna: #{@columna}, Las dimensiones no cuadran: #{@dim1} != #{@dim2}"
		"Las dimensiones no cuadran: #{@dim1} != #{@dim2}"
	end
end

class ErrorTipo < ErrorEstatico
	def initialize(tipo_dado, posicion, *tipos_esperados)
		@tipos_esperados = tipos_esperados
		@tipo_dado = tipo_dado
		@linea = posicion["linea"]
		@columna = posicion["columna"]
	end
	def to_s
		if @tipos_esperados.length == 1
			"En la linea: #{@linea} y columna: #{@columna}, Se esperaba el tipo #{@tipos_esperados[0]} pero se encontró #{@tipo_dado}"
		else
			"En la linea: #{@linea} y columna: #{@columna}, Se esperaba o #{@tipos_esperados.join(" o ")}pero se encontró #{@tipo_dado}"
		end
	end
end

class ErrorRedeclaracion < ErrorEstatico
	def initialize(id, posicion)
		@id = id
		@linea = posicion["linea"]
		@columna = posicion["columna"]
	end
	def to_s
		"En la linea: #{@linea} y columna: #{@columna}, Se intentó redeclarar la variable #{@id}"
	end
end

class ErrorVariableNoDeclarada < ErrorEstatico
	def initialize(id, posicion)
		@id = id
		@linea = posicion["linea"]
		@columna = posicion["columna"]
	end
	def to_s
		"En la linea: #{@linea} y columna: #{@columna}, Se intentó utilizar la variable #{@id} no declarada"
	end
end

class ErrorModificacionVariableProtegida < ErrorEstatico
	def initialize(id, posicion)
		@id = id
		@linea = posicion["linea"]
		@columna = posicion["columna"]
	end
	def to_s
		"En la linea: #{@linea} y columna: #{@columna}, Se intentó modificar la variable de control #{@id}"
	end
end
# Tipos básicos
BOOL = Tipo.new('bool')
CHAR = Tipo.new('char')
INT = Tipo.new('int')
