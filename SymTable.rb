#!/usr/bin/ruby
# encoding: utf-8

# CLASES:
# 		TablaSimbolors
# 		Simbolo
# 		Tipo
# 		ErrorDimensiones

class TablaSimbolos
	attr_reader :tabla, :asignaciones
	attr_accessor :padre
	def initialize (lista_sim_asig=[], padre = nil)
		@padre = padre
		@tabla = {}
		@asignaciones = []
		lista_sim_asig.each do |tupla|
			
			simbolo = tupla[0]
			asignacion = tupla[1]
			if @tabla.has_key?(simbolo.id)
				raise ErrorRedeclaracion.new(simbolo.id, simbolo.ultima_posicion)
			else
				@tabla[simbolo.id] = simbolo 
			end
			if asignacion != nil
				@asignaciones << asignacion
			end
		end
	end

	def get (id)
		e = self
		while e != nil
			#
			if e.tabla.has_key?(id) and (e.tabla[id].valor == nil or e.tabla[id].valor.class.superclass != ArbolBinario)
				return e.tabla[id]
			end
			e = e.padre
		end
		return nil
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
	def to_s(nivel=0)
		tabs = "\t" * nivel
		str = tabs + "Identificador: #{@id} \n\t" + tabs + "Tipo: #{@tipo.to_s}\n"
		str += tabs + "\tValor: #{@valor}\n" unless valor == nil
		str
	end
end

class Tipo
	attr_reader :tipo, :dimensiones, :tipo_param, :forma, :dimensionalidad
	def initialize(tipo,dimensiones=nil,tipo_param=nil)
		@tipo = tipo
		@dimensiones = dimensiones
		@tipo_param = tipo_param
		aplanar() # Aplano la definición recursiva del tipo
		@forma = @dimensiones ? @dimensiones.map { |d| d.length } : []
		@dimensionalidad = @forma ? @forma.reduce(0, :+) : 0
	end
	
	def aplanar
		if @tipo == "matrix"
			e = self
			dimensiones = [@dimensiones]
			while !(e = e.tipo_param).tipo_param.nil?
				dimensiones << e.dimensiones
			end
			@tipo_param = e
			@dimensiones = dimensiones
		end
	end

	def ==(x)
		eq = @tipo == x.tipo
		if eq and @tipo == "matrix"
			if @forma != x.forma
				eq = false # Error de forma
			end
		end
		eq
	end
	def to_s
		str = @tipo
		str += " " + @dimensiones._to_s if @dimensiones
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
	def initialize(posicion, tipo_dado, *tipos_esperados)
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
	def initialize(posicion, id)
		@id = id
		@linea = posicion["linea"]
		@columna = posicion["columna"]
	end
	def to_s
		"En la linea: #{@linea} y columna: #{@columna}, Se intentó redeclarar la variable #{@id}"
	end
end

class ErrorVariableNoDeclarada < ErrorEstatico
	def initialize(posicion, id)
		@id = id
		@linea = posicion["linea"]
		@columna = posicion["columna"]
	end
	def to_s
		"En la linea: #{@linea} y columna: #{@columna}, Se intentó utilizar la variable #{@id} no declarada"
	end
end

class ErrorModificacionVariableProtegida < ErrorEstatico
	def initialize(posicion, id)
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
