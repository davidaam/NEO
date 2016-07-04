echo "ruby Lexer.rb \$1" > LexNeo
echo "ruby Parser.rb \$1" > SintNeo
echo "ruby Parser.rb \$1" > ContNeo
echo "ruby Parser.rb \$1" > neo
chmod +x LexNeo
chmod +x SintNeo
chmod +x ContNeo
chmod +x neo