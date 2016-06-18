echo "ruby Lexer.rb \$1" > LexNeo
echo "ruby Parser.rb \$1" > SintNeo
echo "ruby Parser.rb \$1" > ContNeo
chmod +x LexNeo
chmod +x SintNeo
chmod +x ContNeo