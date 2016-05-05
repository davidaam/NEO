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
  def initialize(caracter_recibido,linea,columna,caracter_esperado=nil)
    @linea = linea
    @columna = columna
    @caracter_recibido = caracter_recibido
    @caracter_esperado = caracter_esperado
  end

  def to_s
    if @caracter_esperado
      "Error: Esperaba \"#{@caracter_esperado}\" en la fila #{@linea}, columna #{@columna}, pero leí #{@caracter_recibido}"
    else
      "Error: Caracter inesperado \"#{@caracter_recibido}\" en la fila #{@linea}, columna #{@columna}"
    end
  end
end
