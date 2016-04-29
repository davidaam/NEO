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
      ":" => "DosPuntos",
      "<-" => "Asignacion",
      "." => "Punto",
      "," => "Coma",
      "{" => "AbreLlave",
      "}" => "CierraLlave",
      "%" => "Mod"
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
    print "\n ================ \n Linea #{@nroLinea} \n ================ \n" 
    if palabra == nil
      puts "\n 1)la parabra era nula\n" # ESTO NO ES AUTO EXPLICATIVO, porque aparece tanto?
      return nil
    end
    token = nil
    inicioTk = pos
    finTk = inicioTk + palabra.length
    # Primero chequeamos si es una palabra reservada
    print "2) EL POS ES: #{pos} LA PALABRA ES #{palabra}: "
    if PALABRAS_RESERVADAS.include? palabra
      token = self.createToken("Tk#{palabra.capitalize}",@nroLinea,inicioTk)
      puts "es reservada\n"
    else
      # Luego chequeo si coincide con alguna regla
      REGLAS.each do |tk,regex|
        if palabra.match(regex) != nil
          puts "Es regla\n"
          inicioTk = $~.offset(0)[0]  ####################################PORQUE NO LO TENEMOS YA? ESTO SIEMPRE ES 0
          puts "EL NUEVO INICIO QUE AL PARECER ES DISTINTO DEL POST ES #{inicioTk}"
          finTk = $~.offset(0)[1]
          # De haber un valor, se guarda en $1
          token = self.createToken(tk,@nroLinea,pos+inicioTk,$1)
          break
        end
      end

      # Si no he detectado algun token hasta el momento, chequeo si hay un simbolo
      if token == nil
        SIMBOLOS.each do |simbolo,nombre|
          if palabra.match(Regexp.escape(simbolo)) != nil
            puts "Es simbolo\n"
            inicioTk = $~.offset(0)[0]
            finTk = $~.offset(0)[1]
            token = self.createToken("Tk#{nombre}",@nroLinea,pos+inicioTk)
            break
          end
        end
      end
    end
    # Si hasta este punto no detecté ningún token, hay un error
    if token == nil
      @errores << "Error en linea #{@nroLinea} columna #{inicioTk}"
      puts "\n3) EROOR LA palabra era <#{palabra}> en la linea #{@nroLinea}"
    else
      # Si detecté un token, veo si tengo algo tokenizable a los lados recursivamente
      palabraIzq = palabra[pos...inicioTk] if inicioTk > 0
      palabraDer = palabra[finTk...palabra.length]

      tkIzq = self.tokenizeWord(palabraIzq,pos,true)
      tkDer = self.tokenizeWord(palabraDer,finTk,true)

      @tokens << tkIzq if rec and tkIzq != nil
      @tokens << token
      @tokens << tkDer if rec and tkDer != nil
    end
    return token
  end

  def tokenizeLine(line)
    # Matcheamos todo lo que no sean espacios
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
    puts @tokens
  end
end

l = Lexer.new("ejemplo.neo")
l.tokenize

l.tokens