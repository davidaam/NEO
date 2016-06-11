class TablaSimbolos
	attr_reader :padre, :tabla
	def initialize (padre)
		@padre = padre
		@tabla = {}
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
			throw new VariableNoDeclarada(id,valor)
		end
	end
end

class Simbolo
	attr_reader :id
	attr_accessor :valor
	def initialize (id, tipo, valor = nil)
		@id = id
		@tipo = tipo
		@valor = valor
	end
end