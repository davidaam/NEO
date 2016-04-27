require 'set'

load 'Token.rb'

class Lexer
  attr_reader :tokens, :errores
  # Defino las expresiones regulares que reconocen cada tipo de Token
  REGLAS = {
      'TkId' => /$([a-zA-Z][a-zA-Z_]*)$/,
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
    @lastOffset = 0

    # Leer archuivo y eliminar comentarios antes de procesarlo (preservando las lineas)
    text = File.read(archivo)
    text.scan /(%\{.*?\}%)/m do
      puts $1
      iniComentario = $~.offset(1)[0]
      finComentario = $~.offset(1)[1]
      text = text[0...iniComentario] << $1.gsub(/[^\n]/, ' ') << text[finComentario...text.length]
    end
    puts text
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

  def addToken(tk,linea,columna,valor=nil)
    tkClass = Object.const_get(tk)
    @tokens << tkClass.new(linea,columna,valor)
  end

  def tokenizeWord(palabra,pos)
    # Primero chequeamos si es una palabra reservada
    if PALABRAS_RESERVADAS.include? palabra

    end
  end


  def tokenizeLine(line)
    # Matcheamos todo lo que no sean espacios
    line.scan(/\S+/) do |palabra|
      pos = $~.offset(0)[0]
      self.tokenizeWord(palabra,pos)
    end
    @nroLinea += 1
  end

  def tokenizeAll(text)
    text.split("\n") do |linea|
      self.tokenizeLine(linea)
      @linea += 1
    end
  end
end

l = Lexer.new("ejemplo.neo")

