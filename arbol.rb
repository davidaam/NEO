ARBOLES = {
	'binarios' => {
		'Expr_Aritm' => ["Operador", "Operando izquierdo", "Operando derecho"]
	}
}

class ArbolNario
	def initialize (valor = nil, hijos = [])
		@valor = valor
		@hijos = hijos
	end
end

class ArbolBinario
	
	@desc_valor = ""
	@desc_izq = ""
	@desc_der = ""
	
	attr_accessor :nivel
	
	class <<self
	    attr_accessor :desc_valor, :desc_izq, :desc_der
	end

	def initialize (valor = nil, nivel = 1, izq = nil, der = nil)
		@valor = valor
		@izq = izq
		@der = der
		@nivel = nivel
	end

	def izq=(izq)
		izq.nivel = self.nivel + 1
		@izq = izq
	end

	def der=(der)
		der.nivel = self.nivel + 1
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
end

ARBOLES['binarios'].each do |tipo_arbol,descripcion| 

	Object.const_set("Arbol_#{tipo_arbol}",
		Class.new(ArbolBinario) do
			def to_s
				tipo_arbol = self.class.to_s.sub("Arbol_","")
				desc_valor = ARBOLES['binarios'][tipo_arbol][0]
				desc_izq = ARBOLES['binarios'][tipo_arbol][1]
				desc_der = ARBOLES['binarios'][tipo_arbol][2]
				str = tipo_arbol.upcase + " \n"
				str += ("\t" * @nivel) + "#{desc_valor}: #{@valor} \n"
				str += ("\t" * @nivel) + "#{desc_izq}: #{@izq.to_s} \n"
				str += ("\t" * @nivel) + "#{desc_der}: #{@der.to_s} \n"
				return str
			end
		end
	)
end

a4 = Arbol_Expr_Aritm.new("Mult",3,100,10)
a2 = Arbol_Expr_Aritm.new("Mult",2,a4,3)
a3 = Arbol_Expr_Aritm.new("Resta",2,2,1)
a1 = Arbol_Expr_Aritm.new("Suma",1,a2,a3)
print a1.to_s
