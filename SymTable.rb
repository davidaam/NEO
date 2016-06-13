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
				throw ErrorRedeclaracion.new(s.id)
			else
				@tabla[s.id] = s
			end
		end
	end
	def add (simbolo)
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
	def update(lvalue, arbol_expr)
		simbolo = get(lvalue)
		if simbolo != nil
			rvalue = arbol_expr.eval(simbolo.tipo,self)
			simbolo.update(rvalue)
		else
			throw ErrorVariableNoDeclarada.new(id)
		end
	end
	def to_s(nivel=0)
		tabs = ("\t" * nivel)
		str = tabs + "TABLA DE SIMBOLOS\n"
		@tabla.each do |id,simbolo|
			simbolo.eval(self)
			str += simbolo.to_s(nivel+1) + "\n"
		end
		@hijos.each do |tabla_h|
			str += "\n" + tabla_h.to_s(nivel+1)
		end
		str
	end
end

class Simbolo
	attr_reader :id , :tipo
	attr_accessor :valor
	def initialize (tkid, tipo=nil, valor = nil)
		@id = tkid.valor
		@tipo = tipo
		@valor = valor
	end
	def set_type(tipo)
		@tipo = tipo
		self
	end
	def eval(tabla)
		@tipo.eval(tabla)
		@valor = @valor.eval(@tipo,tabla) if @valor != nil
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
		@tipo_param.eval(tabla) unless @tipo_param == nil
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
			throw ErrorDimensiones.new(@dimensiones,x.dimensiones)
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
class ErrorDimensiones < RuntimeError
	def initialize(dim1,dim2)
		@dim1 = dim1
		@dim2 = dim2
	end
	def to_s
		"Las dimensiones no cuadran: #{@dim1} != #{@dim2}"
	end
end

class ErrorTipo < RuntimeError
	def initialize(tipo_esperado, tipo_dado)
		@tipo_esperado = tipo_esperado
		@tipo_dado = tipo_dado
	end
	def to_s
		"Se esperaba el tipo #{@tipo_esperado} pero se encontró #{@tipo_dado}"
	end
end

class ErrorRedeclaracion < RuntimeError
	def initialize(id)
		@id = id
	end
	def to_s
		"Se intentó redeclarar la variable #{@id}"
	end
end

class ErrorVariableNoDeclarada < RuntimeError
	def initialize(id)
		@id = id
	end
	def to_s
		"Se intentó utilizar la variable #{@id} no declarada"
	end
end
# Tipos básicos
BOOL = Tipo.new('bool')
CHAR = Tipo.new('char')
INT = Tipo.new('int')
