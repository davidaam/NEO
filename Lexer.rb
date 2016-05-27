#!/usr/bin/ruby
# encoding: utf-8

require 'set'

load 'Token.rb'

class Lexer
  attr_accessor :tokens
  # Defino las expresiones regulares que reconocen cada tipo de Token
  REGLAS = {
      'TkCaracter' => /'([^'\\]|\\n|\\t|\\'|\\\\)'$/,
      'TkFalse' => /false$/,
      'TkTrue' => /true$/,
      'TkId' => /([a-zA-Z]\w*)$/,
      'TkNum' => /(\d+)$/
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

  def tokenizeWord(palabra,pos)

    conjuntoTokens = []
    finTk = pos

    # Por cada palabra chequeo en orden de precedencia si hace match con la regexp de algún token
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
          if laPalabra == "not" or (laPalabra.match(Regexp.escape(simbolo)) != nil and simbolo != "not")
            token = self.createToken("Tk#{nombre}",@nroLinea,inicioTk)
            break
          end
        end
        # Si no he detectado algun token hasta el momento,
        # chequeo coincide con alguna "regla" (TkId,TkCaracter,TkTrue,TkFalse,TkNum)
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
      # Si no detecté nada es un error
      if token == nil
        # Si hay más de un símbolo en la palabra que dio error, agrego los errores uno a uno
        if laPalabra.length > 1
          laPalabra.scan(/\W/) do
            posChar = $~.offset(0)
            @errores << TokenError.new($~,@nroLinea,inicioTk+posChar[0]+1)
          end
        else
          @errores << TokenError.new(laPalabra,@nroLinea,inicioTk+1)
        end
      else
        conjuntoTokens << token
      end

    end
    # Agrego todos los tokens detectados en @tokens

    @tokens += conjuntoTokens
  end

  def tokenizeLine(line)
    # Matcheamos todas las palabras separadas por espacios y el caso especial ' '
    line.scan(/'[ ]+'|\S+/) do |palabra|
      inicioTk = $~.offset(0)[0]
      # Separo todos los símbolos pegados con espacios
      palabra_s = palabra.gsub(/[^\w\s']/,' \0 ')
      # Agrego espacios a los lados de los char por si hay algo pegado que deba ser analizado
      palabra_s = palabra_s.gsub(/'([^']| \\ \\ | \\ n| \\ t| \\ ')'/,' \0 ')

      # Si la palabra contiene un char, borro los espacios innecesarios agregados anteriormente
      if palabra_s.match(/'([^']| \\ \\ | \\ n| \\ t| \\ ')' /)
        posChar = $~.offset(0)
        # Si la palabra no es ' ', borro los espacios dentro del comentario, si no lo dejo así porque está bien
        if $1 != " "
          palabra_s = palabra_s[0...posChar[0]] + "'" + $1.gsub(/\s+/,'') + "' " + palabra_s[posChar[1]...palabra_s.length]
        end
      end
      # Separo las palabras separadas por espacios y el caso especial ' ' para analizarlos por separado
      palabra = palabra_s.scan(/' '|\S+/)
      # Creo una copia del arreglo para no modificarlo
      arrTemp = Array.new(palabra)
      # Voy llevando la posición en el arreglo de la palabra que estoy preprocesando
      i = 0
      arrTemp.each do |palabraCandidata|
        # Si tengo numero e id pegados, los separo para analizarlos por separado
        if palabraCandidata.match(/^[0-9]+([a-zA-Z_]+[0-9]*)+/)
          # Separo las palabras y las agrego en el arreglo palabraArr
          palabraArr = palabraCandidata.sub(/^[0-9]+/,' \0 ').split
          palabra = palabra[0...i] + palabraArr + palabra[i+1...palabra.length]
          # Como agregué algunos elementos al arreglo de palabras, me salto tantas posiciones, le resto 1 porque al final
          # siempre le sumo 1
          i += palabraArr.length-1
        # Si no estoy al final de la palabra, es decir, tengo algo a la derecha, chequeo si es un símbolo de dos caracteres
        elsif i+1 < palabra.length
          # Obtengo los simbolos de tamaño 2
          simbolos_par = SIMBOLOS.keys.select { |s| s.length == 2 }

          simbolos_par.each do |simbolo|
            # Por cada símbolo chequeo si la palabra chequeada es el primer caracter del símbolo, y si la siguiente
            # palabra en el arreglo es el segundo caracter del símbolo
            if palabraCandidata.match Regexp.escape(simbolo[0])
              if palabra[i+1] == simbolo[1]
                # Si efectivamente pasa esto, entonces uno el primer caracter con el segundo,
                # y borro el segundo caracter del arreglo
                palabra[i] += simbolo[1]
                palabra.delete_at(i+1)
                # Le resto uno porque en realidad no debería moverme, pero como siempre le sumo 1 entonces se cancela
                i -= 1
              end
            end
          end
        end

        # En caso de que no sea un char pero tenga una comilla, esta no tendra espacios entre los caracteres
        # Por lo tanto hay que separarlos
        if (palabraCandidata.match(/'([^']|\\\\|\\n|\\t|\\')'/)==nil and palabraCandidata.match(/'/)!=nil)
          # Separo las palabras y las agrego en el arreglo palabraArr
          palabraArr = palabraCandidata.gsub(/'/,' \0 ').split
          palabra = palabra[0...i] + palabraArr + palabra[i+1...palabra.length]
          # Como agregué algunos elementos al arreglo de palabras, me salto tantas posiciones, le resto 1 porque al final
          # siempre le sumo 1
          i += palabraArr.length-1
        end

        # En cualquier caso avanzo una posición
        i += 1
      end
      # Mando a tokenizar el arreglo de palabras posiblemente tokenizables que detecté, tomando como posición base
      # el inicio de la palabra misma
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

load 'Parser.rb'

p = Parser.new(l.tokens)
x = p.parse
puts x