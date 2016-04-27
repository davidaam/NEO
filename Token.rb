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
  def hola

  end
end