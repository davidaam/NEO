class TablaSimbolos
	attr_reader :padre, :tabla
	def initialize (lista_sim, padre = nil)
		@padre = padre
		@tabla = {}
		lista_sim.each do |s|
			tabla[s.id] = s
		end
	end
	def add (simbolo)
		tabla[simbolo.id] = simbolo
	end
	def get (id)
		e = self
		while e != nil
			if e.tabla.has_key?(id)
				return e[id]
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
			throw new VariableNoDeclarada(id)
		end
	end
end

class Simbolo
	attr_reader :id , :tipo
	attr_accessor :valor
	def initialize (id, tipo=nil, valor = nil)
		@id = id
		@tipo = tipo
		@valor = valor
	end
	def set_type(tipo)
		@tipo = tipo
	end
end

class Tipo
	def initialize(tipo,dimensiones=0,tipo_param=nil)
		@tipo = tipo
		@dimensiones = dimensiones
		@tipo_param = tipo_param
	end
	
	def ==(x)
		eq = @tipo == x.tipo and @dimensiones.length == x.dimensiones.length
		for i in 0...@dimensiones.length
			eq = eq and x.dimensiones[i] == @dimensiones[i]
		end
	end
end