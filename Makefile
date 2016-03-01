
# Tooling for ANTLR v3

CLASSPATH=$(shell echo $$CLASSPATH)
java=$(shell which java)
antlr3=$(java) -Xmx500M -cp $(CLASSPATH) org.antlr.Tool
antlrworks=$(shell echo $$ANTLRWORKS)
LWFRONT_BLOB_MASTER=https://raw.githubusercontent.com/ovidiugabriel/lwfront/master

none:
	# nothing to be done
lwfront-java:
	$(antlr3) -o output -Dlanguage=java Lwfront.g4
	javac -cp $(CLASSPATH) output/*.java
	jar cvfe output/lwfront.jar Main output/*.class
	if [ -e output/lwfront.jar ] ; then java -jar output/lwfront.jar ; fi
edit-lwfront:
	$(java) -jar $(antlrworks) Lwfront.g4
update-grammar:
	$(shell wget $(LWFRONT_BLOB_MASTER)/Lwfront.g4 -O Lwfront.new.g ; \
	if [ -e Lwfront.new.g ] ; then if [ -e Lwfront.g4 ] ; then rm Lwfront.g4 ; fi ; mv Lwfront.new.g Lwfront.g4 ; fi)
clean:
	rm output/*
	tree output
