
# Tooling for ANTLR v3

CLASSPATH=$(shell echo $$CLASSPATH)
java=$(shell which java)
antlr3=$(java) -Xmx500M -cp $(CLASSPATH) org.antlr.Tool
antlrworks=$(shell echo $$ANTLRWORKS)
LWFRONT_BLOB_MASTER=https://raw.githubusercontent.com/ovidiugabriel/lwfront/master

none:
	# nothing to be done
lwfront-java:
	$(antlr3) -o output -Dlanguage=java Lwfront.g
	javac -cp $(CLASSPATH) output/*.java src/lwfront/*.java -d output/
	# jar cvfe output/lwfront.jar lwfront.Main output/*.class output/lwfront/*.class
	# if [ -e output/lwfront.jar ] ; then java -jar output/lwfront.jar ; fi
	java -cp ./output/ lwfront.Main
update-grammar:
	$(shell wget $(LWFRONT_BLOB_MASTER)/Lwfront.g4 -O Lwfront.new.g ; \
	if [ -e Lwfront.new.g ] ; then if [ -e Lwfront.g ] ; then rm Lwfront.g ; fi ; mv Lwfront.new.g Lwfront.g ; fi)
clean:
	if [ -e output/lwfront ] ; then rm -r output/lwfront ; fi
	rm output/*
	tree output
