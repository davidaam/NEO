# encoding: utf-8

class Token

  # Permito acceder a la linea y columna de un token desde fuera (es como hacerlos public)
  attr_reader :linea, :columna, :valor

  # Un token puede o no tener un valor, los token que tienen valores son TkId, TkCaracter, TkNum
  def initialize(linea,columna,valor=nil)
    @linea = linea
    @columna = columna
    @valor = valor
  end

  def to_s
    # Obtengo el nombre de la clase del token que estoy imprimiendo
    out = self.class.to_s
    # Si el token tiene un valor le agrego '' o "" dependiendo del caso
    if @valor
      if out == "TkCaracter"
        out += "('#{@valor}')"
      elsif out == "TkId"
        out += "(\"#{@valor}\")"
      elsif out == "TkNum"
        out += "(#{@valor})"
      end
    end
    # Agrego la posición del token
    out += " #{@linea} #{@columna}"
    return out
  end
end

class TokenError
  # Los errores pueden ser simplemente de caracter inesperado, o de caracter inesperado cuando se esperaba otra cosa
  # (por ahora lo segundo solo lo hacemos con los comentarios que no cierran)
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
