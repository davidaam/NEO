require 'set'

load 'Token.rb'

class Lexer
  attr_accessor :tokens
# Defino las expresiones regulares que reconocen cada tipo de Token
  REGLAS = {
      'TkCaracter' => /'([^'\\]|\\n|\\t|\\'|\\\\)'/,
      'TkFalse' => /false/,
      'TkTrue' => /true/,
      'TkId' => /([a-zA-Z]\w*)/,
      'TkNum' => /(\d+)/
  }
  # Defino las palabras reservadas del lenguaje
  PALABRAS_RESERVADAS = Set.new [
                                    "begin",
                                    "end",
                                    "if",
                                    "with",
                                    "var",
                                    "char",
                                    "bool",
                                    "matrix",
                                    "int",
                                    "print",
                                    "otherwise",
                                    "for",
                                    "read",
                                    "step",
                                    "from",
                                    "to",
                                    "of",
                                    "while"
                                ]
  # Defino los símbolos del lenguaje, pongo de primeros los simbolos dobles para que hagan match primero
  SIMBOLOS = {
      "/\\" => "Conjuncion",
      "\\/" => "Disyuncion",
      "<=" => "MenorIgual",
      ">=" => "MayorIgual",
      "/=" => "Desigual",
      "++" => "SiguienteCar",
      "--" => "AnteriorCar",
      "::" => "Concatenacion",
      "->" => "Hacer",
      "<-" => "Asignacion",
      "<" => "Menor",
      ">" => "Mayor",
      "=" => "Igual",
      "#" => "ValorAscii",
      "$" => "Rotacion",
      "?" => "Trasposicion",
      "," => "Coma",
      "." => "Punto",
      ":" => "DosPuntos",
      "(" => "ParAbre",
      ")" => "ParCierra",
      "[" => "CorcheteAbre",
      "]" => "CorcheteCierra",
      "{" => "LlaveAbre",
      "}" => "LlaveCierra",
      "+" => "Suma",
      "-" => "Resta",
      "*" => "Mult",
      "/" => "Div",
      "%" => "Mod",
      "not" => "Negacion",
  }

  def initialize(archivo)
    @tokens = []
    @errores = []
    @nroLinea = 1

    # Leer archivo y eliminar comentarios antes de procesarlo (preservando las lineas y columnas)
    text = File.read(archivo)

    # Elimino los comentarios de linea
    @text = text.gsub(/%%.*$/,'')

    text.scan (/(%\{.*?\}%)/m) do
      # Obtengo la posición de inicio y fin del comentario
      iniComentario = $~.offset(1)[0]
      finComentario = $~.offset(1)[1]
      # Por cada comentario, modifico el codigo a analizar, primero lo que está antes del comentario, luego sustituyo
      # todos los caracteres del comentario (incluyendo las llaves y porcentajes) menos los saltos de línea por espacios
      # (para preservar la posición de los tokens) y luego el resto del código después del comentario
      text = text[0...iniComentario] << $1.gsub(/[^\n]/, ' ') << text[finComentario...text.length]
    end

    # Si luego de eliminar los comentarios, me queda un %{, significa que hay un comentario que no cierra
    if @text.match(/%\{/) != nil
      # Obtengo la posición y linea final del archivo y agrego el error de falta cierre de comentario
      posInicio = $~.offset(0)[0]
      text_arr = text.split(/\r?\n/)
      columnaFinal = text_arr[-1].length+1
      lineaFinal = text_arr.length
      @text = @text[0...posInicio]
      @errores << TokenError.new("EOF",lineaFinal,columnaFinal,"}%")
    end

    # Crear las subclases de token a partir de las reglas
    REGLAS.each do |nombreToken,regex|
      Object.const_set(nombreToken,Class.new(Token))
    end
    # Crear las subclases de token a partir de las palabras reservadas
    PALABRAS_RESERVADAS.each do |palabra|
      Object.const_set("Tk#{palabra.capitalize}",Class.new(Token))
    end
    # Crear las subclases de token a partir de los símbolos
    SIMBOLOS.values.each do |nombre|
      Object.const_set("Tk#{nombre}",Class.new(Token))
    end
  end

  # Crea y devuelve un token con los datos suministrados
  def createToken(tk,linea,posicion,valor=nil)
    # Le sumamos 1 a la posición ya que la columna está indexada desde 1 y la posición pasada es desde 0
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
      @errores << "Caracter inesperado '#{palabra}' en linea #{@nroLinea} columna #{inicioTk+1}"
    else
      # Obtengo lo que me queda a los lados del token matcheado
      palabraIzq = palabra[0...inicioTk] if inicioTk != pos
      palabraDer = palabra[finTk...palabra.length]


    	puts "palabra: #{palabra}"
    	puts "palabra izq: #{palabraIzq}"
    	puts "palabra: #{palabraDer}"
      # Obtengo la lista de tokens a la izquierda y derecha de la palabra dada
      tokensIzq = self.tokenizeWord(palabraIzq,pos,true)
      tokensDer = self.tokenizeWord(palabraDer,pos+finTk,true)

      # En cada llamada construimos un arreglo ordenado de los tokens que hay en la palabra dada
      tokens = []
      tokens + tokensIzq if tokensIzq != nil
      tokens << token
      tokens + tokensDer if tokensDer != nil

      # Cuando salimos del caso recursivo tengo en tokens todos los tokens que hay en la palabra, ordenados
      if not rec
        tokens.each do |tk|
          @tokens << tk
        end
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
    # Si hay errores entonces los imprimo en el formato dado
    if @errores.empty?
      if !@tokens.empty?
        linea = nil
        @tokens.each do |tk|
          lineaAnt = linea
          linea = tk.linea
          # Si cambié de linea desde el último token, imprimo un salto de línea
          if lineaAnt != linea and lineaAnt != nil
            print "\n"
            # Si no cambié de linea y no estoy comenzando a imprimir, entonces imprimo una ,
          elsif lineaAnt != nil
            print ", "
          end
          # Imprimo la representación del token
          print "#{tk}"
        end
      end
      # Si hay errores, entonces solo imprimo los errores
    else
      puts @errores
    end
  end

end

# Obtengo el nombre del archivo pasado como parámetro
filename = ARGV[0]
# Si no le pasé nada, entonces lanzo un error
if !filename
  raise 'Debe pasarle un archivo al lexer'
end

# Creo el objeto lexer, lo mando a que tokenice e imprima los errores
l = Lexer.new(filename)
l.tokenize
l.printOutput

load 'Parser.rb'

p = Parser.new(l.tokens)
x = p.parse
puts x