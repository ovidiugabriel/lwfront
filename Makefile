
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
	javac output/*.java
edit-lwfront:
	$(java) -jar $(antlrworks) Lwfront.g
update-grammar:
	$(shell wget $(LWFRONT_BLOB_MASTER)/Lwfront.g -O Lwfront.new.g ; if [ -e Lwfront.new.g ] ; then if [ -e Lwfront.g ] ; then rm Lwfront.g ; fi ; mv Lwfront.new.g Lwfront.g ; fi)
clean:
	rm output/*
	tree output
