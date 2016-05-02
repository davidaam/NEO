require 'set'

load 'Token.rb'

class Lexer
  # attr_reader :tokens, :errores
  # Defino las expresiones regulares que reconocen cada tipo de Token
  REGLAS = {
      'TkFalse' => /False/,
      'TkTrue' => /True/,
      'TkId' => /([a-zA-Z]\w*)/,
      'TkNum' => /(\d+)/
  }

  PALABRAS_RESERVADAS = Set.new ["begin","end","if","with","var","char","bool","matrix","int","var"]

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

  def tokenizeWord(palabra,pos)

    conjuntoTokens = []
    finTk = pos
    palabra.each do |laPalabra|
      token = nil
      inicioTk = finTk
      finTk = inicioTk + laPalabra.length
      # Primero chequeamos si es una palabra reservada
      if PALABRAS_RESERVADAS.include? laPalabra
        token = self.createToken("Tk#{laPalabra.capitalize}",@nroLinea,inicioTk)
      else
        # Luego chequeo si es un simbolo
        SIMBOLOS.each do |simbolo,nombre|
            if (laPalabra.match(/not\z/) != nil and simbolo == "not") or (laPalabra.match(Regexp.escape(simbolo)) != nil and simbolo != "not")
              token = self.createToken("Tk#{nombre}",@nroLinea,inicioTk)
              break
            end
          end
        # Si no he detectado algun token hasta el momento, chequeo coincide con alguna regla (numero o variable)
        if token == nil
          REGLAS.each do |tk,regex|
            if laPalabra.match(regex) != nil
              # De haber un valor, se guarda en $1
              token = self.createToken(tk,@nroLinea,inicioTk,$1)
              break
            end
          end
        end
      end
      # Si no detecto nada es un error
      if token == nil
        @errores << TokenError.new(laPalabra,@nroLinea,inicioTk+1)
      else
        conjuntoTokens << token
      end

    end
    conjuntoTokens.each do |token|
      @tokens << token
    end
  end

  def tokenizeLine(line)
    # Matcheamos todo lo que no sean espacios
    line.scan(/\S+/) do |palabra|
      inicioTk = $~.offset(0)[0]
      palabra = palabra.gsub(/\W/,' \0 ').split
      arrTemp = Array.new(palabra)
      arrTemp.each do |verificando|
        i = palabra.index(verificando)
        if verificando.match(/^[0-9]+([a-zA-Z_]+[0-9]*)+/)
          verArr = verificando.sub(/^[0-9]+/,' \0 ').split
          palabra = palabra[0...i] + verArr + palabra[i+1...palabra.length]
        else
          simbolos_par = ["/\\","\\/","<=",">=","++","::","->","<-"]
          simbolos_par.each do |simbolo|
            if verificando.match Regexp.escape(simbolo[0])
              if palabra[i+1] == simbolo[1]
                palabra[i] = simbolo[1]
                palabra.delete_at(i+1)
              end
            end
          end
        end
      end
      self.tokenizeWord(palabra,inicioTk)
    end
    @nroLinea += 1
  end

  def tokenize
    @text.lines do |linea|
      linea.gsub!(/\x00/,'')
      self.tokenizeLine(linea)
    end
  end

  def printOutput
    if @errores.length > 0
      puts @errores
    else
      puts @tokens
    end
  end

end

filename = ARGV[0]
l = Lexer.new(filename)
l.tokenize
l.printOutput