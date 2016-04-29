require 'set'

load 'Token.rb'

class Lexer
  attr_reader :tokens, :errores
  # Defino las expresiones regulares que reconocen cada tipo de Token
  REGLAS = {
      'TkId' => /([a-zA-Z][a-zA-Z_]*)/,
      'TkNum' => /(\d+)/
  }

  PALABRAS_RESERVADAS = Set.new ["begin","with","end","int","var"]

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
      #"/" => "Div",
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
    puts @text
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
    #print "\n ================ \n Linea #{@nroLinea} \n ================ \n" 
    if palabra == nil
      #puts "\n 1)la parabra era nula\n" # ESTO NO ES AUTO EXPLICATIVO, porque aparece tanto?
      return nil
    end
    conjuntoTokens = []
    finTk = pos
    palabra.each do |laPalabra|
      puts "\nPase con #{palabra}, especificamente #{laPalabra}"
      token = nil
      inicioTk = finTk
      finTk = inicioTk + laPalabra.length
      # Primero chequeamos si es una palabra reservada
      print "2) EL POS ES: #{pos} LA PALABRA ES #{laPalabra}: "
      if PALABRAS_RESERVADAS.include? laPalabra
        token = self.createToken("Tk#{laPalabra.capitalize}",@nroLinea,inicioTk)
        puts "es reservada\n"
      else
        # Luego chequeo si es un simbolo
        SIMBOLOS.each do |simbolo,nombre|
            if laPalabra.match(Regexp.escape(simbolo)) != nil
              puts "Es el simbolo <#{simbolo}>\n"
              #inicioTk = $~.offset(0)[0]
              #finTk = $~.offset(0)[1]
              token = self.createToken("Tk#{nombre}",@nroLinea,pos+inicioTk)
              break
            end
          end
        # Si no he detectado algun token hasta el momento, chequeo coincide con alguna regla (numero o variable)
        if token == nil
          REGLAS.each do |tk,regex|
            if laPalabra.match(regex) != nil
              puts "Es regla de tipo #{tk}\n"
              #inicioTk = $~.offset(0)[0]
              #finTk = $~.offset(0)[1]
              # De haber un valor, se guarda en $1
              token = self.createToken(tk,@nroLinea,inicioTk,$1)
              break
            end
          end
        end
      end
      # Si no detecto nada es un error
      if token == nil
        @errores << "Error en linea #{@nroLinea} columna #{inicioTk} el simbolo #{laPalabra}"
        puts "\n3) EROOR LA palabra era <#{palabra}> en la linea #{@nroLinea}"
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
      simbolo_par = false
      arrTemp.each do |verificando|
        if simbolo_par
          simbolo_par = false
        else
          i = palabra.index(verificando)
          if verificando.match(/[0-9]+[[a-zA-Z_]+[0-9]*]+/)
            verArr = verificando.sub(/[0-9]+/,' \0 ').split
            palabra = palabra[0...i] + verArr + palabra[i+1...palabra.length]

          elsif verificando.match(/\//)
            if palabra[i+1] == '\\'
              simbolo_par = true
              palabra[i] = '/\\'
              palabra.delete_at(i+1)
            end

          elsif verificando.match(/\\/)
            if palabra[i+1] == '/'
              simbolo_par = true
              palabra[i] = '\\/'
              palabra.delete_at(i+1)
            end

          elsif verificando.match(/</)
            if (palabra[i+1] == '=') or (palabra[i+1] == '-')
              simbolo_par = true
              palabra[i] = '<'+palabra[i+1]
              palabra.delete_at(i+1)
            end

          elsif verificando.match(/>/)
            if palabra[i+1] == '='
              simbolo_par = true
              palabra[i] = '>='
              palabra.delete_at(i+1)
            end

          elsif verificando.match(/\+/)
            if palabra[i+1] == '+'
              simbolo_par = true
              palabra[i] = '++'
              palabra.delete_at(i+1)
            end

          elsif verificando.match(/\-/)
            if (palabra[i+1] == '-') or (palabra[i+1] == '>')
              simbolo_par = true
              palabra[i] = '-' + palabra[i+1] 
              palabra.delete_at(i+1)
            end

          elsif verificando.match(/:/)
            if palabra[i+1] == ':'
              simbolo_par = true
              palabra[i] = '::'
              palabra.delete_at(i+1)
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
      self.tokenizeLine(linea)
    end
    puts @tokens

    puts "\n\n\n=======\n PROBANDO \n==========\n"
    self.tokenizeLine("!hola!")
  end
end

l = Lexer.new("ejemplo.neo")
l.tokenize

l.tokens