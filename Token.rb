class Token
  attr_accessor :valor

  def initialize(linea,columna,valor=nil)
    @linea = linea
    @columna = columna
    @valor = valor
  end

  def to_s
    if @valor
      "#{self.class}(#{@valor}): Linea #{@linea}, Columna #{@columna}"
    else
      "#{self.class}: Linea #{@linea}, Columna #{@columna}"
    end
  end
end

class TokenError
  def initialize(caracter,linea,columna)
    @linea = linea
    @columna = columna
    @caracter = caracter
  end

  def to_s
    "Caracter inesperado '#{@caracter}' en la linea #{@linea} columna #{@columna}"
  end
end
