
# Tooling for ANTLR v3

CLASSPATH=$(shell echo $$CLASSPATH)
java=$(shell which java)
antlr3=$(java) -Xmx500M -cp $(CLASSPATH) org.antlr.Tool
LANGUAGE=java
antlrworks=$(shell echo $$ANTLRWORKS)
LWFRONT_BLOB_MASTER=https://github.com/ovidiugabriel/lwfront/blob/master/Lwfront.g

none:
	# nothing to be done
lwfront:
	$(antlr3) -o output -Dlanguage=$(LANGUAGE) Lwfront.g
edit-lwfront:
	$(java) -jar $(antlrworks) Lwfront.g
update-grammar:
	$(shell if [ -e Lwfront.g ] ; then mv Lwfront.g Lwfront.backup.g ; fi && wget $(LWFRONT_BLOB_MASTER) )
clean:
	rm output/*
	tree output
