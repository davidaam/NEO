class Token
  attr_accessor :valor

  def initialize(linea,columna,valor=nil)
    @linea = linea
    @columna = columna
    @valor = valor
  end

  def to_s
    if @valor
      "#{self.class}(#{@valor}) #{@linea}:#{@columna}"
    else
      "#{self.class} #{@linea}:#{@columna}"
    end
  end
  def hola

  end
end