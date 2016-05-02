require 'set'

load 'Token.rb'

class Lexer

  PALABRAS_RESERVADAS = Set.new ["begin","end","if","with","var","char","bool","matrix","int","var"]

  # Defino las expresiones regulares que reconocen cada tipo de Token
  REGLAS = {
      'TkFalse' => /False/,
      'TkTrue' => /True/,
      'TkId' => /([a-zA-Z]\w*)/,
      'TkNum' => /(\d+)/
  }

  SIMBOLOS = {
      "," => "Coma",
      "." => "Punto",
      ":" => "DosPuntos",
      "(" => "ParAbre",
      ")" => "ParCierra",
      "[" => "CorcheteAbre",
      "]" => "CorcheteCierra",
      "{" => "LlaveAbre",
      "}" => "LlaveCierra",
      "->" => "Hacer",
      "<-" => "Asignacion",
      "+" => "Suma",
      "-" => "Resta",
      "*" => "Mult",
      "/" => "Div",
      "%" => "Mod",
      "/\\" => "Conjuncion",
      "\\/" => "Disyuncion",
      "not" => "Negacion",
      "<" => "Menor",
      "<=" => "MenorIgual",
      ">" => "Mayor",
      ">=" => "MayorIgual",
      "=" => "Igual",
      "++" => "SiguienteCar",
      "--" => "AnteriorCar",
      "#" => "ValorAscii",
      "::" => "Concatenacion",
      "$" => "Rotacion",
      "?" => "Trasposicion"
  }


  def initialize(archivo)
    @tokens = []
    @errores = []
    @nroLinea = 1

    # Leer archuivo y eliminar comentarios antes de procesarlo (preservando las lineas)
    text = File.read(archivo)
    text.scan /(%\{.*?\}%)/m do
      iniComentario = $~.offset(1)[0]
      finComentario = $~.offset(1)[1]
      text = text[0...iniComentario] << $1.gsub(/[^\n]/, ' ') << text[finComentario...text.length]
    end
    @text = text
    # Crear las subclases de token a partir de las reglas
    REGLAS.each do |nombreToken,regex|
      Object.const_set(nombreToken,Class.new(Token))
    end
    # Crear las subclases de token a partir de las palabras reservadas
    PALABRAS_RESERVADAS.each do |palabra|
      Object.const_set("Tk#{palabra.capitalize}",Class.new(Token))
    end
    SIMBOLOS.values.each do |nombre|
      Object.const_set("Tk#{nombre}",Class.new(Token))
    end
  end

  def createToken(tk,linea,posicion,valor=nil)
    Object.const_get(tk).new(linea,posicion+1,valor)
  end

  def tokenizeWord(palabra,pos,rec=false)
    # Condición de parada de la recursión
    if palabra == nil or palabra.empty?
      return nil
    end
    token = nil
    inicioTk = pos
    finTk = inicioTk + palabra.length

    # Luego chequeo si coincide con alguna "regla"
    REGLAS.each do |tk,regex|
      if palabra.match(regex) != nil
        inicioTk = $~.offset(0)[0]
        finTk = $~.offset(0)[1]
        if tk == 'TkId'
          # Primero chequeamos si es una palabra reservada
          if PALABRAS_RESERVADAS.include? $1
            token = self.createToken("Tk#{$1.capitalize}",@nroLinea,pos+inicioTk)
            break
          end
        end
        # Si no es una palabra reservada, entonces es un id, cuyo nombre está en $1
        token = self.createToken(tk,@nroLinea,pos+inicioTk,$1)
        break
      end
    end

    # Si no he detectado algun token hasta el momento, chequeo si hay un simbolo
    if not token
      SIMBOLOS.each do |simbolo,nombre|
        if palabra.match(Regexp.escape(simbolo)) != nil
          inicioTk = $~.offset(0)[0]
          finTk = $~.offset(0)[1]
          token = self.createToken("Tk#{nombre}",@nroLinea,pos+inicioTk)
          break
        end
      end
    end
    # Si hasta este punto no detecté ningún token, hay un error
    if not token
      @errores << "Caracter inesperado '#{palabra}' en linea #{@nroLinea} columna #{inicioTk}"
    else
      # Obtengo lo que me queda a los lados del token matcheado
      palabraIzq = palabra[0...inicioTk] if inicioTk != pos
      palabraDer = palabra[finTk...palabra.length]

      # Obtengo la lista de tokens a la izquierda y derecha de la palabra dada
      tokensIzq = self.tokenizeWord(palabraIzq,pos,true)
      tokensDer = self.tokenizeWord(palabraDer,pos+finTk,true)

      # En cada llamada construimos un arreglo ordenado de los tokens que hay en la palabra dada
      tokens = []
      tokens << tokensIzq if tokensIzq != nil
      tokens << token
      tokens << tokensDer if tokensDer != nil

      # Cuando salimos del caso recursivo tengo en tokens todos los tokens que hay en la palabra, ordenados
      if not rec
        @tokens << tokens
      end
    end
    return tokens
  end

  def tokenizeLine(line)
    # Matcheamos todo lo que no sean espacios
    line.gsub!(/\x00/,'')
    line.scan(/\S+/) do |palabra|
      inicioTk = $~.offset(0)[0]
      self.tokenizeWord(palabra,inicioTk)
    end
    @nroLinea += 1
  end

  def tokenize
    @text.lines do |linea|
      self.tokenizeLine(linea)
    end
  end

  def printOutput
    if @errores.empty?
      puts @tokens
    else
      puts @tokens
      puts @errores
    end
  end
end

l = Lexer.new("ejemplo.neo")
l.tokenize
l.printOutput