package lwfront;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;

/* ANTLR imports */
import lwfront.antlr.generated.LwfrontParser;
import org.antlr.runtime.ANTLRInputStream;
import org.antlr.runtime.CharStream;
import org.antlr.runtime.CommonTokenStream;

import lwfront.antlr.generated.LwfrontLexer;


/*
 * Example from: http://tomassetti.me/parsing-any-language-in-java-in-5-minutes-using-antlr-for-example-python/
 */
class ParserFacade {

    private static String readFile(File file, Charset encoding) throws IOException {
        byte[] encoded = Files.readAllBytes(file.toPath());
        return new String(encoded, encoding);
    }

    public void parse(File file) throws IOException {
        String code = readFile(file, Charset.forName("UTF-8"));

        CharStream input = new ANTLRInputStream(new FileInputStream(file));
        LwfrontLexer lexer = new LwfrontLexer(input);

        CommonTokenStream tokens = new CommonTokenStream(lexer);
        LwfrontParser parser = new LwfrontParser(tokens);

        // return parser.file_input();
    }
}
