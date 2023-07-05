package org.javacs;

import java.util.Arrays;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.javacs.lsp.*;

public class Main {
    private static final Logger LOG = Logger.getLogger("main");

    public static void setRootFormat() {
        var root = Logger.getLogger("");

        for (var h : root.getHandlers()) {
            h.setFormatter(new LogFormat());
        }
    }

    private static void handleLogFileArg(String[] args) throws java.io.IOException {
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("--logFile") && i + 1 < args.length) {
                String logFile = args[i + 1];
                Logger.getLogger("").addHandler(new FileHandler(logFile, false));
            }
            
        }
    }

    public static void main(String[] args) {
        boolean quiet = Arrays.stream(args).anyMatch("--quiet"::equals);

        if (quiet) {
            LOG.setLevel(Level.OFF);
        }

        try {
            handleLogFileArg(args);
            setRootFormat();

            LSP.connect(JavaLanguageServer::new, System.in, System.out);
        } catch (Throwable t) {
            LOG.log(Level.SEVERE, t.getMessage(), t);

            System.exit(1);
        }
    }
}
