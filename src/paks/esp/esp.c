/**
    esp.c -- ESP command program

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************* Includes ***********************************/

#include    "esp.h"

#if ME_COM_ESP || ME_ESP_PRODUCT
/********************************** Locals ************************************/
/*
    Global application object. Provides the top level roots of all data objects for the GC.
 */
typedef struct App {
    Mpr         *mpr;
    MaAppweb    *appweb;
    MaServer    *server;

    cchar       *appName;               /* Application name */
    cchar       *appwebConfig;          /* Arg to --config */
    cchar       *currentDir;            /* Initial starting current directory */
    cchar       *database;              /* Database provider "mdb" | "sdb" */

    cchar       *binDir;                /* Bin directory */
    cchar       *home;                  /* Home directory */
    cchar       *paksCacheDir;          /* Paks cache directory */
    cchar       *paksDir;               /* Local paks directory */
    cchar       *listen;                /* Listen endpoint for "esp run" */
    cchar       *platform;              /* Target platform os-arch-profile (lower) */

    int         combined;               /* Combine all inputs into one, combined output */ 
    cchar       *combinedPath;          /* Output filename for combined compilations */
    MprFile     *combinedFile;          /* Output file for combined compilations */
    MprList     *combinedItems;         /* Items to invoke from Init */

    MprList     *routes;                /* Routes to process */
    EspRoute    *eroute;                /* Selected ESP route to build */
    MprJson     *config;                /* Package.json configuration */
    HttpRoute   *route;                 /* Selected route to build */
    MprList     *files;                 /* List of files to process */
    MprList     *build;                 /* Items to build */
    MprList     *slink;                 /* List of items for static link */
    MprHash     *targets;               /* Command line targets */
    EdiGrid     *migrations;            /* Migrations table */

    cchar       *command;               /* Compilation or link command */
    cchar       *cacheName;             /* Cached MD5 name */
    cchar       *csource;               /* Name of "C" source for page or controller */
    cchar       *genlink;               /* Static link resolution file */
    cchar       *filterRouteName;       /* Name of route to use for ESP configuration */
    cchar       *filterRoutePrefix;     /* Prefix of route to use for ESP configuration */
    cchar       *log;                   /* Arg for --log */
    cchar       *routeSet;              /* Desired route set package */
    cchar       *mode;                  /* New esp.mode to use */
    cchar       *module;                /* Compiled module name */
    cchar       *base;                  /* Base filename */
    cchar       *entry;                 /* Module entry point */
    cchar       *controller;            /* Controller name for generated entities (lower case) */
    cchar       *title;                 /* Title name for generated entities */
    cchar       *table;                 /* Override table name for migrations, tables */

    int         compileMode;            /* Debug or release compilation */
    int         error;                  /* Any processing error */
    int         keep;                   /* Keep source */ 
    //  MOB - remove
    int         generateApp;            /* Generating a new app */
    int         force;                  /* Force the requested action, ignoring unfullfilled dependencies */
    int         overwrite;              /* Overwrite existing files if required */
    int         priorInstall;           /* Generating into an existing application directory */
    int         quiet;                  /* Don't trace progress */
    int         require;                /* Initialization requirement flags */
    int         rebuild;                /* Force a rebuild */
    int         reverse;                /* Reverse migrations */
    int         show;                   /* Show compilation commands */
    int         silent;                 /* Totall silent */
    int         singleton;              /* Generate a singleton resource controller */
    int         staticLink;             /* Use static linking */
    int         upgrade;                /* Upgrade */
    int         verbose;                /* Verbose mode */
    int         why;                    /* Why rebuild */
} App;

static App       *app;                  /* Top level application object */
static Esp       *esp;                  /* ESP control object */
static Http      *http;                 /* HTTP service object */
static MaAppweb  *appweb;               /* Appweb service object */
static int       nextMigration;         /* Sequence number for next migration */

/*
    Initialization requirement flags
 */
    //MOB - remove REQ_CONFIG
#define REQ_CONFIG      0x1             /* Require appweb.conf, otherwise load if present */
#define REQ_TARGETS     0x2             /* Require targets list */
#define REQ_ROUTES      0x4             /* Require esp routes */
#define REQ_PACKAGE     0x8             /* Require package.json, otherwise load if present */
#define REQ_NO_CONFIG   0x10            /* Never load appweb.conf */
#define REQ_SERVE       0x20            /* Will be running as a server */
#define REQ_NAME        0x40            /* Set appName */

/*
    CompileFile flags
 */
#define ESP_CONTROlLER  0x1             /* Compile a controller */
#define ESP_VIEW        0x2             /* Compile a view */
#define ESP_PAGE        0x4             /* Compile a stand-alone ESP page */
#define ESP_MIGRATION   0x8             /* Compile a database migration */
#define ESP_SRC         0x10            /* Files in src */

#define ESP_FOUND_TARGET 1

#define MAX_VER         1000000000
#define VER_FACTOR      1000
#define VER_FACTOR_MAX  "999"

#define ESP_MIGRATIONS  "_EspMigrations"
#define ESP_PAKS_DIR    "client/paks"   /* Local paks dir under client */

/***************************** Forward Declarations ***************************/

static int64 asNumber(cchar *version);
static bool blendPak(cchar *name, cchar *criteria, bool topLevel);
static bool blendSpec(cchar *name, cchar *version, MprJson *spec);
static void clean(int argc, char **argv);
static void config();
static void compile(int argc, char **argv);
static void compileFile(HttpRoute *route, cchar *source, int kind);
static void copyEspFiles(cchar *name, cchar *version, cchar *fromDir, cchar *toDir);
static void compileCombined(HttpRoute *route);
static void compileItems(HttpRoute *route);
static App *createApp(Mpr *mpr);
static void createMigration(cchar *name, cchar *table, cchar *comment, int fieldCount, char **fields);
static void exportCache();
static void fail(cchar *fmt, ...);
static void fatal(cchar *fmt, ...);
static cchar *findAcceptableVersion(cchar *name, cchar *criteria);
static void generate(int argc, char **argv);
static void generateController(int argc, char **argv);
static void generateItem(cchar *item);
static void genKey(cchar *key, cchar *path, MprHash *tokens);
static void generateMigration(int argc, char **argv);
static void generateScaffold(int argc, char **argv);
static void generateTable(int argc, char **argv);
static cchar *getConfigValue(cchar *key, cchar *defaultValue);
static MprList *getRoutes();
static MprHash *getTargets(int argc, char **argv);
static cchar *getTemplate(cchar *key, MprHash *tokens);
static cchar *getPakVersion(cchar *name, cchar *version);
static void getPackageValue(int argc, char **argv);
static bool identifier(cchar *name);
static MprJson *createPackage();
static void initialize(int argc, char **argv);
static bool inRange(cchar *expr, cchar *version);
static void init(int argc, char **argv);
static void install(int argc, char **argv);
static bool installPak(cchar *name, cchar *criteria, bool topLevel);
static bool installPakFiles(cchar *name, cchar *version, bool topLevel);
static void list(int argc, char **argv);
static cchar *findAppwebConfig();
static MprJson *loadPackage(cchar *path);
static void makeEspDir(cchar *dir);
static void makeEspFile(cchar *path, cchar *data, ssize len);
static MprHash *makeTokens(cchar *path, MprHash *other);
static void manageApp(App *app, int flags);
static void migrate(int argc, char **argv);
static int parseArgs(int argc, char **argv);
static void parseCommand(int argc, char **argv);
static void process(int argc, char **argv);
static cchar *readTemplate(cchar *path, MprHash *tokens, ssize *len);
static bool requiredRoute(HttpRoute *route);
static int reverseSortFiles(MprDirEntry **d1, MprDirEntry **d2);
static void run(int argc, char **argv);
static void savePackage();
static bool selectResource(cchar *path, cchar *kind);
static void setMode(cchar *mode);
static void setPackageKey(cchar *key, cchar *value);
static void setPackageValue(int argc, char **argv);
static int sortFiles(MprDirEntry **d1, MprDirEntry **d2);
static void qtrace(cchar *tag, cchar *fmt, ...);
static void trace(cchar *tag, cchar *fmt, ...);
static void uninstall(int argc, char **argv);
static void uninstallPak(cchar *name);
static void upgrade(int argc, char **argv);
static bool upgradePak(cchar *name);
static void usageError();
static void vtrace(cchar *tag, cchar *fmt, ...);
static void why(cchar *path, cchar *fmt, ...);

/*********************************** Code *************************************/

PUBLIC int main(int argc, char **argv)
{
    Mpr     *mpr;
    int     options, rc;

    if ((mpr = mprCreate(argc, argv, MPR_USER_EVENTS_THREAD)) == 0) {
        exit(1);
    }
    if ((app = createApp(mpr)) == 0) {
        exit(2); 
    }
    options = parseArgs(argc, argv);
    process(argc - options, &argv[options]);
    rc = app->error;
    mprDestroy();
    return rc;
}


/*
    Create a master App object for esp. This provids a common root for all esp data
 */
static App *createApp(Mpr *mpr)
{
    if ((app = mprAllocObj(App, manageApp)) == 0) {
        return 0;
    }
    mprAddRoot(app);
    mprAddStandardSignals();

    app->mpr = mpr;
    app->appwebConfig = 0;
    app->listen = sclone(ESP_LISTEN);
    app->paksDir = sclone(ESP_PAKS_DIR);
#if ME_COM_SQLITE
    app->database = sclone("sdb");
#elif ME_COM_MDB
    app->database = sclone("mdb");
#else
    mprError("No database provider defined");
#endif
    return app;
}


static void manageApp(App *app, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(app->appName);
        mprMark(app->appweb);
        mprMark(app->cacheName);
        mprMark(app->command);
        mprMark(app->appwebConfig);
        mprMark(app->config);
        mprMark(app->csource);
        mprMark(app->currentDir);
        mprMark(app->database);
        mprMark(app->files);
        mprMark(app->filterRouteName);
        mprMark(app->filterRoutePrefix);
        mprMark(app->combinedFile);
        mprMark(app->combinedItems);
        mprMark(app->combinedPath);
        mprMark(app->genlink);
        mprMark(app->binDir);
        mprMark(app->paksCacheDir);
        mprMark(app->paksDir);
        mprMark(app->listen);
        mprMark(app->log);
        mprMark(app->module);
        mprMark(app->mpr);
        mprMark(app->base);
        mprMark(app->migrations);
        mprMark(app->controller);
        mprMark(app->platform);
        mprMark(app->title);
        mprMark(app->build);
        mprMark(app->slink);
        mprMark(app->mode);
        mprMark(app->route);
        mprMark(app->routes);
        mprMark(app->routeSet);
        mprMark(app->server);
        mprMark(app->targets);
        mprMark(app->table);
    }
}


static int parseArgs(int argc, char **argv)
{
    cchar   *argp;
    int     argind;

   for (argind = 1; argind < argc && !app->error; argind++) {
        argp = argv[argind];
        if (*argp++ != '-') {
            break;
        }
        if (*argp == '-') {
            argp++;
        }
        if (smatch(argp, "chdir") || smatch(argp, "home")) {
            if (argind >= argc) {
                usageError();
            } else {
                argp = argv[++argind];
                if (chdir((char*) argp) < 0) {
                    fail("Cannot change directory to %s", argp);
                }
                app->home = sclone(argv[++argind]);
            }

        //  MOB - should this be --appweb?
        } else if (smatch(argp, "config") || smatch(argp, "conf")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->appwebConfig = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "database")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->database = sclone(argv[++argind]);
                if (!smatch(app->database, "mdb") && !smatch(app->database, "sdb")) {
                    fail("Unknown database \"%s\"", app->database);
                    usageError();
                }
            }

        } else if (smatch(argp, "debugger") || smatch(argp, "D")) {
            mprSetDebugMode(1);

        } else if (smatch(argp, "force") || smatch(argp, "f")) {
            app->force = 1;

        } else if (smatch(argp, "genlink") || smatch(argp, "g")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->genlink = sclone(argv[++argind]);
            }


        } else if (smatch(argp, "keep") || smatch(argp, "k")) {
            app->keep = 1;

        } else if (smatch(argp, "listen") || smatch(argp, "l")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->listen = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "log") || smatch(argp, "l")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->log = sclone(argv[++argind]);
            }

#if UNUSED
        } else if (smatch(argp, "name")) {
            if (argind >= argc) {
                usageError();
            }
            mprSetAppName(argv[++argind], 0, 0);
#endif
        } else if (smatch(argp, "name")) {
            //  MOB - is this needed?
            if (argind >= argc) {
                usageError();
            } else {
                if (!identifier(argv[++argind])) {
                    fail("Application name must be a valid C identifier");
                } else {
                    app->appName = argv[argind];
                    app->title = stitle(app->appName);
                }
            }

        } else if (smatch(argp, "optimized")) {
            app->compileMode = ESP_COMPILE_OPTIMIZED;

        } else if (smatch(argp, "overwrite")) {
            app->overwrite = 1;

        } else if (smatch(argp, "platform")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->platform = slower(argv[++argind]);
            }

        } else if (smatch(argp, "quiet") || smatch(argp, "q")) {
            app->quiet = 1;

        } else if (smatch(argp, "rebuild") || smatch(argp, "r")) {
            app->rebuild = 1;

        } else if (smatch(argp, "routeName")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->filterRouteName = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "routePrefix")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->filterRoutePrefix = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "show") || smatch(argp, "s")) {
            app->show = 1;

        } else if (smatch(argp, "silent")) {
            app->silent = 1;
            app->quiet = 1;

        } else if (smatch(argp, "singleton") || smatch(argp, "single")) {
            app->singleton = 1;

        } else if (smatch(argp, "static")) {
            app->staticLink = 1;

        } else if (smatch(argp, "symbols")) {
            app->compileMode = ESP_COMPILE_SYMBOLS;

        } else if (smatch(argp, "table")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->table = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "verbose") || smatch(argp, "v")) {
            app->verbose++;

        } else if (smatch(argp, "version") || smatch(argp, "V")) {
            mprPrintf("%s\n", ME_VERSION);
            exit(0);

        } else if (isdigit((uchar) *argp)) {
            app->log = sfmt("stdout:%d", (int) stoi(argp));

        } else if (smatch(argp, "why") || smatch(argp, "w")) {
            app->why = 1;

        } else {
            if (!smatch(argp, "?") && !smatch(argp, "help")) {
                fail("Unknown switch \"%s\"", argp);
            }
            usageError();
        }
    }
    parseCommand(argc - argind, &argv[argind]);
    return argind;
}


static void parseCommand(int argc, char **argv)
{
    cchar       *cmd;

    if (app->error) {
        return;
    }
    cmd = argv[0];
    
    if (argc == 0) {
        /* Run */
        app->require = REQ_SERVE;

    } else if (smatch(cmd, "config")) {
        app->require = 0;

    } else if (smatch(cmd, "clean")) {
        app->require = REQ_TARGETS | REQ_ROUTES;

    } else if (smatch(cmd, "compile")) {
        app->require = REQ_TARGETS | REQ_ROUTES;

    } else if (smatch(cmd, "generate")) {
        app->require = REQ_PACKAGE;

    } else if (smatch(cmd, "get")) {
        app->require = REQ_PACKAGE;

    } else if (smatch(cmd, "init")) {
        if (!app->appName) {
            app->appName = (argc >= 1) ? argv[0] : mprGetPathBase(mprGetCurrentPath());
        }
        app->require = REQ_NAME;

    } else if (smatch(cmd, "install")) {
        app->require = 0;
        if (!app->appName && !mprPathExists("package.json", R_OK)) {
            app->appName = mprGetPathBase(mprGetCurrentPath());
            app->require = REQ_NAME;
        }

    } else if (smatch(cmd, "list")) {
        app->require = REQ_PACKAGE;

    } else if (smatch(cmd, "migrate")) {
        app->require = REQ_ROUTES;

    } else if (smatch(cmd, "mode")) {
        /* Need config and routes because it does a clean */
        app->require = REQ_PACKAGE | REQ_ROUTES;

    } else if (smatch(cmd, "run")) {
        app->require = REQ_SERVE;
        if (argc > 1) {
            app->require = REQ_NO_CONFIG;
        }

    } else if (smatch(cmd, "set")) {
        app->require = REQ_PACKAGE;

    } else if (smatch(cmd, "uninstall")) {
        app->require = 0;

    } else if (smatch(cmd, "upgrade")) {
        app->require = REQ_PACKAGE;

    } else if (isdigit((uchar) *cmd)) {
        app->require = REQ_NO_CONFIG;

    } else if (cmd && *cmd) {
        fail("Unknown command \"%s\"", cmd);
    }
}


static void setupRequirements(int argc, char **argv)
{
    if (app->error) {
        return;
    }
    if (app->require & REQ_NAME) {
        if (!identifier(app->appName)) {
            if (argc >= 1) {
                fail("Application name must be a valid C identifier");
            } else {
                fail("Directory name is used as application name and must be a valid C identifier");
            }
            return;
        }
    }
    if ((app->appwebConfig = findAppwebConfig()) == 0) {
        if (app->require & REQ_CONFIG) {
            fail("Cannot find appweb.conf");
            return;
        }
    }
    if (mprPathExists(ME_ESP_PACKAGE, R_OK)) {
        if ((app->config = loadPackage(ME_ESP_PACKAGE)) == 0) {
            return;
        }
        app->appName = getConfigValue("name", app->appName);

    } else {
        if (app->require & REQ_PACKAGE) {
            fail("Cannot find %s", ME_ESP_PACKAGE);
            return;
        }
        app->appName = mprGetPathBase(mprGetCurrentPath());
        app->title = stitle(app->appName);
        app->config = createPackage();
    }
    if (app->require & REQ_TARGETS) {
        app->targets = getTargets(argc - 1, &argv[1]);
    }
}


static void initRuntime()
{
    cchar       *home;

    if (app->error) {
        return;
    }
    mprStartLogging(app->log, 0);
    mprSetCmdlineLogging(1);
    
    app->currentDir = mprGetCurrentPath();
    app->binDir = mprGetAppDir();

    if ((home = getenv("HOME")) != 0) {
        app->paksCacheDir = mprJoinPath(home, ".paks");
    } else {
        app->paksCacheDir = mprJoinPath(mprGetAppDir(), "../" ME_ESP_PAKS);
    }
    if (mprStart() < 0) {
        mprError("Cannot start MPR for %s", mprGetAppName());
        mprDestroy();
        app->error = 1;
        return;
    }
    httpCreate(HTTP_SERVER_SIDE | HTTP_UTILITY);

    //  MOB maCreateAppweb API is ugly requiring a probe. Why not just use bin + ME_NAME
    if ((app->appweb = maCreateAppweb("bin/esp" ME_EXE)) == 0) {
        fail("Cannot create HTTP service for %s", mprGetAppName());
        return;
    }
    appweb = MPR->appwebService = app->appweb;
    appweb->skipModules = 1;
    http = app->appweb->http;
    appweb->staticLink = app->staticLink;
    
    if (app->error) {
        return;
    }
    if ((app->server = maCreateServer(appweb, "default")) == 0) {
        fail("Cannot create HTTP server for %s", mprGetAppName());
        return;
    }
    maLoadModule(appweb, "espHandler", "libmod_esp");
}


static void initialize(int argc, char **argv)
{
    HttpStage   *stage;
    int         flags;

    if (app->error) {
        return;
    }
    initRuntime();
    if (app->error) {
        return;
    }
    exportCache();
    setupRequirements(argc, argv);
    app->route = httpGetDefaultRoute(0);
    
    if (app->appwebConfig) {
        /*
            Parse appweb.conf
         */
        flags = (app->require & REQ_SERVE) ? 0 : MA_PARSE_NON_SERVER;
        if (maParseConfig(app->server, app->appwebConfig, flags) < 0) {
            fail("Cannot configure the server, exiting.");
            return;
        }
    } else {
        if (mprPathExists("package.json", R_OK) && mprGetJsonObj(app->config, "esp", 0) != 0) {
            
            if (espApp(app->route, ".", app->appName, 0, 0) < 0) {
                fail("Cannot create ESP app");
                return;
            }
        } else {
            /*
                Either no package.json or no "esp" definition
             */
            app->eroute = mprAllocObj(EspRoute, espManageEspRoute);
            app->route->eroute = app->eroute;
            app->eroute->update = 1;
            httpSetRouteShowErrors(app->route, 1);
            espSetDefaultDirs(app->route);
            httpAddRouteIndex(app->route, "index.esp");
        }
        httpAddRouteHandler(app->route, "espHandler", "esp");
        httpAddRouteHandler(app->route, "fileHandler", "html gif jpeg jpg png pdf ico css js txt \"\"");
        httpAddRouteIndex(app->route, "index.html");
        
        /*
            Load ESP compiler rules
         */
        if (maParseFile(NULL, mprJoinPath(mprGetAppDir(), "esp.conf")) < 0) {
            fail("Cannot parse esp.conf");
            return;
        }
        httpFinalizeRoute(app->route);
#if KEEP
        httpLogRoutes(app->server->defaultHost, 0);
#endif
    }
    app->routes = getRoutes();
    if ((stage = httpLookupStage(http, "espHandler")) == 0) {
        fail("Cannot find ESP handler in %s", app->appwebConfig);
        return;
    }
    esp = stage->stageData;
    esp->compileMode = app->compileMode;
    mprGC(MPR_GC_FORCE | MPR_GC_COMPLETE);
}


static void process(int argc, char **argv)
{
    cchar       *cmd;

    initialize(argc, argv);
    if (app->error) {
        return;
    }
    cmd = argv[0];

    if (argc == 0) {
        run(argc, argv);

    } else if (smatch(cmd, "config")) {
        config();

    } else if (smatch(cmd, "clean")) {
        clean(argc -1, &argv[1]);

    } else if (smatch(cmd, "compile")) {
        compile(argc -1, &argv[1]);

    } else if (smatch(cmd, "generate")) {
        generate(argc - 1, &argv[1]);

    } else if (smatch(cmd, "get")) {
        getPackageValue(argc - 1, &argv[1]);

    } else if (smatch(cmd, "init")) {
        init(argc - 1, &argv[1]);

    } else if (smatch(cmd, "install")) {
        install(argc - 1, &argv[1]);

    } else if (smatch(cmd, "list")) {
        list(argc - 1, &argv[1]);

    } else if (smatch(cmd, "migrate")) {
        migrate(argc - 1, &argv[1]);

    } else if (smatch(cmd, "mode")) {
        if (argc < 2) {
            char *args[1] = { "esp.mode" };
            getPackageValue(1, args);
        } else {
            setMode(argv[1]);
        }

    } else if (smatch(cmd, "run")) {
        run(argc - 1, &argv[1]);

    } else if (smatch(cmd, "set")) {
        setPackageValue(argc - 1, &argv[1]);

    } else if (smatch(cmd, "uninstall")) {
        uninstall(argc - 1, &argv[1]);

    } else if (smatch(cmd, "upgrade")) {
        upgrade(argc - 1, &argv[1]);
        
    } else if (isdigit((uchar) *cmd)) {
        run(0, NULL);
    }
}


static void config() 
{
    printf("ESP configuration:\n");
    printf("Pak cache dir \"%s\"\n", app->paksCacheDir);
    printf("Paks dir      \"%s\"\n", app->paksDir);
    printf("Binaries dir  \"%s\"\n", app->binDir);
}


static void clean(int argc, char **argv)
{
    MprList         *files;
    MprDirEntry     *dp;
    EspRoute        *eroute;
    HttpRoute       *route;
    char            *path;
    int             next, nextFile;

    if (app->error) {
        return;
    }
    for (ITERATE_ITEMS(app->routes, route, next)) {
        eroute = route->eroute;
        if (eroute->cacheDir) {
            trace("clean", "Route \"%s\" at %s", route->name, route->documents);
            files = mprGetPathFiles(eroute->cacheDir, MPR_PATH_RELATIVE);
            for (nextFile = 0; (dp = mprGetNextItem(files, &nextFile)) != 0; ) {
                path = mprJoinPath(eroute->cacheDir, dp->name);
                if (mprPathExists(path, R_OK)) {
                    trace("clean", "%s", path);
                    mprDeletePath(path);
                }
            }
        }
    }
    qtrace("Clean", "Complete");
}


static void generate(int argc, char **argv)
{
    char    *kind;

    if (app->error) {
        return;
    }
    if (argc < 1) {
        usageError();
        return;
    }
    kind = argv[0];

    if (smatch(kind, "appweb") || smatch(kind, "appweb.conf")) {
        generateItem("appweb");

    } else if (smatch(kind, "controller")) {
        generateController(argc - 1, &argv[1]);

    } else if (smatch(kind, "migration")) {
        generateMigration(argc - 1, &argv[1]);

    } else if (smatch(kind, "module")) {
        generateItem(kind);

    } else if (smatch(kind, "scaffold")) {
        generateScaffold(argc - 1, &argv[1]);

    } else if (smatch(kind, "table")) {
        generateTable(argc - 1, &argv[1]);

    } else {
        fatal("Unknown generation kind \"%s\"", kind);
    }
    if (!app->error) {
        qtrace("Generate", "Complete");
    }
}


static cchar *getConfigValue(cchar *key, cchar *defaultValue)
{
    cchar       *value;

    if ((value = mprGetJson(app->config, key, 0)) != 0) {
        return value;
    }
    return defaultValue;
}


static void getPackageValue(int argc, char **argv)
{
    cchar   *key, *value;

    if (argc < 1) {
        usageError();
        return;
    }
    key = argv[0];
    value = getConfigValue(key, 0);
    if (value) { 
        printf("%s\n", value);
    } else {
        printf("undefined\n");
    }
}


static void init(int argc, char **argv)
{
    savePackage();
}


static void install(int argc, char **argv)
{
    int     i;

    if (argc < 1) {
        usageError();
        return;
    }
    if (!mprPathExists("package.json", R_OK)) {
        app->appName = mprGetPathBase(mprGetCurrentPath());
        if (!identifier(app->appName)) {
            fail("Directory name is used as application name and must be a valid C identifier");
            return;
        }
    }
    for (i = 0; i < argc; i++) {
        installPak(argv[i], 0, 1);
    }
}


static void list(int argc, char **argv)
{
    MprDirEntry     *dp;
    MprList         *files;
    MprJson         *spec;
    cchar           *path;
    int             next;

    files = mprGetPathFiles(app->paksDir, MPR_PATH_RELATIVE);
    for (ITERATE_ITEMS(files, dp, next)) {
        if (app->quiet) {
            printf("%s\n", dp->name);
        } else {
            path = mprJoinPaths(app->route->documents, app->paksDir, dp->name, ME_ESP_PACKAGE, NULL);
            if ((spec = loadPackage(path)) == 0) {
                fail("Cannot load package.json \"%s\"", path);
            }
            printf("%s %s\n", dp->name, mprGetJson(spec, "version", 0));
        }
    }
}


/*
    esp migrate [forward|backward|NNN]
 */
static void migrate(int argc, char **argv)
{
    MprModule   *mp;
    MprDirEntry *dp;
    Edi         *edi;
    EdiRec      *mig;
    HttpRoute   *route;
    cchar       *command, *file;
    uint64      seq, targetSeq, lastMigration, v;
    int         next, onlyOne, backward, found, i, rc;

    if (app->error) {
        return;
    }
    route = app->route;
    onlyOne = backward = 0;
    targetSeq = 0;
    lastMigration = 0;
    command = 0;

    if ((edi = app->eroute->edi) == 0) {
        fail("Database not open. Check appweb.conf");
        return;
    }
    if (app->rebuild) {
        ediClose(edi);
        mprDeletePath(edi->path);
        if ((app->eroute->edi = ediOpen(edi->path, edi->provider->name, edi->flags | EDI_CREATE)) == 0) {
            fail("Cannot open database %s", edi->path);
            return;
        }
    }
    /*
        Each database has a _EspMigrations table which has a record for each migration applied
     */
    if ((app->migrations = ediReadTable(edi, ESP_MIGRATIONS)) == 0) {
        rc = ediAddTable(edi, ESP_MIGRATIONS);
        rc += ediAddColumn(edi, ESP_MIGRATIONS, "id", EDI_TYPE_INT, EDI_AUTO_INC | EDI_INDEX | EDI_KEY);
        rc += ediAddColumn(edi, ESP_MIGRATIONS, "version", EDI_TYPE_STRING, 0);
        if (rc < 0) {
            fail("Cannot add migration");
            return;
        }
        app->migrations = ediReadTable(edi, ESP_MIGRATIONS);
    }
    if (app->migrations->nrecords > 0) {
        mig = app->migrations->records[app->migrations->nrecords - 1];
        lastMigration = stoi(ediGetFieldValue(mig, "version"));
    }
    app->files = mprGetPathFiles("db/migrations", MPR_PATH_NODIRS);
    mprSortList(app->files, (MprSortProc) (backward ? reverseSortFiles : sortFiles), 0);

    if (argc > 0) {
        command = argv[0];
        if (sstarts(command, "forw")) {
            onlyOne = 1;
        } else if (sstarts(command, "back")) {
            onlyOne = 1;
            backward = 1;
        } else if (*command) {
            /* Find the specified migration, may be a pure sequence number or a filename */
            for (ITERATE_ITEMS(app->files, dp, next)) {
                file = dp->name;
                app->base = mprGetPathBase(file);
                if (smatch(app->base, command)) {
                    targetSeq = stoi(app->base);
                    break;
                } else {
                    if (stoi(app->base) == stoi(command)) {
                        targetSeq = stoi(app->base);
                        break;
                    }
                }
            }
            if (! targetSeq) {
                fail("Cannot find target migration: %s", command);
                return;
            }
            if (lastMigration && targetSeq < lastMigration) {
                backward = 1;
            }
        }
    }

    found = 0;
    for (ITERATE_ITEMS(app->files, dp, next)) {
        file = dp->name;
        app->base = mprGetPathBase(file);
        if (!smatch(mprGetPathExt(app->base), "c") || !isdigit((uchar) *app->base)) {
            continue;
        }
        seq = stoi(app->base);
        if (seq <= 0) {
            continue;
        }
        found = 0;
        mig = 0;
        for (i = 0; i < app->migrations->nrecords; i++) {
            mig = app->migrations->records[i];
            v = stoi(ediGetFieldValue(mig, "version"));
            if (v == seq) {
                found = 1;
                break;
            }
        }
        if (backward) {
            found = !found;
        }
        if (!found) {
            /*
                WARNING: GC may occur while compiling
             */
            compileFile(route, file, ESP_MIGRATION);
            if (app->error) {
                return;
            }
            if ((app->entry = scontains(app->base, "_")) != 0) {
                app->entry = mprTrimPathExt(&app->entry[1]);
            } else {
                app->entry = mprTrimPathExt(app->base);
            }
            app->entry = sfmt("esp_migration_%s", app->entry);
            if ((mp = mprCreateModule(file, app->module, app->entry, edi)) == 0) {
                return;
            }
            if (mprLoadModule(mp) < 0) {
                return;
            }
            if (backward) {
                qtrace("Migrate", "Reverse %s", app->base);
                if (edi->back(edi) < 0) {
                    fail("Cannot reverse migration");
                    return;
                }
            } else {
                qtrace("Migrate", "Apply %s ", app->base);
                if (edi->forw(edi) < 0) {
                    fail("Cannot apply migration");
                    return;
                }
            }
            if (backward) {
                assert(mig);
                ediRemoveRec(edi, ESP_MIGRATIONS, ediGetFieldValue(mig, "id"));
            } else {
                mig = ediCreateRec(edi, ESP_MIGRATIONS);
                ediSetField(mig, "version", itos(seq));
                if (ediUpdateRec(edi, mig) < 0) {
                    fail("Cannot update migrations table");
                    return;
                }
            }
            mprUnloadModule(mp);
            if (onlyOne) {
                return;
            }
        }
        if (targetSeq == seq) {
            return;
        }
    }
    if (!onlyOne) {
        trace("Migrate", "All migrations %s", backward ? "reversed" : "applied");
    }
    app->migrations = 0;
}


static void setMode(cchar *mode)
{
    int     quiet;

    setPackageKey("esp.mode", mode);
    quiet = app->quiet;
    app->quiet = 1;
    clean(0, NULL);
    app->quiet = quiet;
}


static void setPackageValue(int argc, char **argv)
{
    cchar   *key, *value;

    if (argc < 2) {
        usageError();
        return;
    }
    key = argv[0];
    value = argv[1];
    setPackageKey(key, value);
}


/*
    Edit a key value in the package.json
 */
static void setPackageKey(cchar *key, cchar *value)
{
    qtrace("Set", sfmt("%s to %s", key, value));
    if (mprSetJson(app->config, key, value, 0) < 0) {
        fail("Cannot update %s with %s", key, value);
        return;
    }
    savePackage();
}


/*
    esp run [ip]:[port] ...
 */
static void run(int argc, char **argv)
{
    cchar   *endpoint;
    char    *ip;
    int     i, port;

    if (app->error) {
        return;
    }
    if (!app->log) {
        if (app->verbose) {
            mprSetLogLevel(app->verbose + 1);
        } else if (!app->quiet) {
            mprSetLogLevel(2);
        }
    }
    if (smatch(espGetConfig(app->route, "esp.logRoutes", 0), "true")) {
        httpLogRoutes(app->route->host, 0);
    }
    if (!app->appwebConfig) {
        if (argc == 0) {
            if (maConfigureServer(app->server, NULL, app->home, ".", "127.0.0.1", 4000, MA_NO_MODULES) < 0) {
                fail("Cannot configure the server to listen on port 127.0.0.1:%d", 4000);
                return;
            }
        } else for (i = 0; i < argc; i++) {
            endpoint = argv[i++];
            mprParseSocketAddress(endpoint, &ip, &port, NULL, 80);
            if (maConfigureServer(app->server, NULL, app->home, ".", ip, port, MA_NO_MODULES) < 0) {
                fail("Cannot configure the server to listen at %s", endpoint);
                return;
            }
        }
    }
    if (maStartAppweb(app->appweb) < 0) {
        mprError("Cannot start HTTP service, exiting.");
        return;
    }
    mprServiceEvents(-1, 0);
    mprLog(1, "Stopping esp ...");
}


static void uninstall(int argc, char **argv)
{
    int     i;

    if (argc < 1) {
        usageError();
        return;
    }
    for (i = 0; i < argc; i++) {
        uninstallPak(argv[i]);
    }
    savePackage();
}


static void upgrade(int argc, char **argv)
{
    MprDirEntry     *dp;
    MprList         *files;
    int             i, next;

    app->overwrite = 1;
    app->upgrade = 1;

    if (argc == 0) {
        files = mprGetPathFiles(app->paksDir, MPR_PATH_RELATIVE);
        for (ITERATE_ITEMS(files, dp, next)) {
            upgradePak(dp->name);
        }
    } else {
        for (i = 0; i < argc; i++) {
            upgradePak(argv[i]);
        }
    }
}


/*
    Export the ESP paks from /usr/local/lib/NAME/esp contents to ~/.paks (one time only)
 */
static void exportCache()
{
    MprDirEntry *dp;
    MprList     *paks;
    MprPath     info, sinfo, dinfo;
    cchar       *espPaks, *src, *dest, *path, *dpath;
    int         i;

    if (getenv("HOME") == 0) {
        return;
    }
    /*
        Look in bin/../esp for paks published with the ESP binary
     */
    espPaks = mprJoinPath(mprGetAppDir(), "../" ME_ESP_PAKS);
    if (!mprPathExists(app->paksCacheDir, R_OK)) {
        if (mprMakeDir(app->paksCacheDir, 0775, -1, -1, 0) < 0) {
            fail("Cannot make directory %s", app->paksCacheDir);
            return;
        }
    }
    /*
        Verify the modified time of the esp-server pak
     */
    paks = mprGetPathFiles(mprJoinPath(espPaks, "esp-server"), MPR_PATH_RELATIVE);
    if ((dp = mprGetFirstItem(paks)) == 0) {
        fail("Cannot locate esp-server in esp paks directory: %s", app->paksCacheDir);
        return;
    }
    path = mprJoinPath("esp-server", dp->name);
    mprGetPathInfo(mprJoinPath(espPaks, path), &sinfo);
    dpath = mprJoinPath(app->paksCacheDir, path);
    mprGetPathInfo(dpath, &dinfo);
    if (dinfo.valid && sinfo.mtime < dinfo.mtime) {
        return;
    }

    /* Touch paks/esp-server/VERSION */
    mprDeletePath(mprGetTempPath(dpath));

    if (!mprPathExists(app->paksCacheDir, R_OK)) {
        if (mprMakeDir(app->paksCacheDir, 0775, -1, -1, 0) < 0) {
            fail("Cannot make directory %s", app->paksCacheDir);
        }
    }
    trace("Export", "ESP paks from %s to %s", espPaks, app->paksCacheDir);

    paks = mprGetPathFiles(espPaks, MPR_PATH_DESCEND | MPR_PATH_RELATIVE);
    for (ITERATE_ITEMS(paks, dp, i)) {
        src = mprJoinPath(espPaks, dp->name);
        dest = mprJoinPath(app->paksCacheDir, dp->name);
        if (dp->isDir) {
            if (mprMakeDir(dest, 0775, -1, -1, 1) < 0) {
                fail("Cannot make directory %s", src);
                break;
            }
        } else {
            mprGetPathInfo(src, &info);
            if (mprCopyPath(src, dest, info.perms) < 0) {
                fail("Cannot copy %s to %s", src, dest);
                break;
            }
        }
    }
}


static MprHash *getTargets(int argc, char **argv)
{
    MprHash     *targets;
    int         i;

    targets = mprCreateHash(0, MPR_HASH_STABLE);
    for (i = 0; i < argc; i++) {
        mprAddKey(targets, mprGetAbsPath(argv[i]), NULL);
    }
    return targets;
}


static bool similarRoute(HttpRoute *r1, HttpRoute *r2)
{
    EspRoute    *e1, *e2;

    e1 = r1->eroute;
    e2 = r2->eroute;

    if (!smatch(r1->documents, r2->documents)) {
        return 0;
    }
    if (!smatch(r1->home, r2->home)) {
        return 0;
    }
    if (!smatch(e1->appDir, e2->appDir)) {
        return 0;
    }
    if (!smatch(e1->clientDir, e2->clientDir)) {
        return 0;
    }
    if (!smatch(e1->controllersDir, e2->controllersDir)) {
        return 0;
    }
    if (!smatch(e1->layoutsDir, e2->layoutsDir)) {
        return 0;
    }
    if (!smatch(e1->srcDir, e2->srcDir)) {
        return 0;
    }
    if (!smatch(e1->viewsDir, e2->viewsDir)) {
        return 0;
    }
    if (!smatch(e1->generateDir, e2->generateDir)) {
        return 0;
    }
    if (!smatch(e1->paksDir, e2->paksDir)) {
        return 0;
    }
    if (scontains(r1->sourceName, "${") == 0 && scontains(r2->sourceName, "${") == 0) {
        if (r1->sourceName || r2->sourceName) {
            return smatch(r1->sourceName, r2->sourceName);
        }
    }
    return 1;
}


static MprList *getRoutes()
{
    HttpHost    *host;
    HttpRoute   *route, *parent, *rp;
    EspRoute    *eroute;
    MprList     *routes;
    MprKey      *kp;
    cchar       *filterRouteName, *filterRoutePrefix;
    int         prev, nextRoute;

    if (app->error) {
        return 0;
    }
    if ((host = mprGetFirstItem(http->hosts)) == 0) {
        fail("Cannot find default host");
        return 0;
    }
    filterRouteName = app->filterRouteName;
    filterRoutePrefix = app->filterRoutePrefix ? app->filterRoutePrefix : 0;
    routes = mprCreateList(0, MPR_LIST_STABLE);

    /*
        Filter ESP routes. Go in reverse order to locate outermost routes first.
     */
    for (prev = -1; (route = mprGetPrevItem(host->routes, &prev)) != 0; ) {
        if ((eroute = route->eroute) == 0 || !eroute->compile) {
            /* No ESP configuration for compiling */
            mprTrace(5, "Skip route name %s - no esp configuration", route->name);
            continue;
        }
        if (filterRouteName) {
            mprTrace(5, "Check route name %s, prefix %s with %s", route->name, route->startWith, filterRouteName);
            if (!smatch(filterRouteName, route->name)) {
                continue;
            }
        } else if (filterRoutePrefix) {
            mprTrace(5, "Check route name %s, prefix %s with %s", route->name, route->startWith, filterRoutePrefix);
            if (!smatch(filterRoutePrefix, route->prefix) && !smatch(filterRoutePrefix, route->startWith)) {
                continue;
            }
        } else {
            mprTrace(5, "Check route name %s, prefix %s", route->name, route->startWith);
        }
        parent = route->parent;
        if (parent && parent->eroute &&
            ((EspRoute*) parent->eroute)->compile && smatch(route->documents, parent->documents) && parent->startWith) {
            /*
                Use the parent instead if it has the same directory and is not the default route
                This is for MVC apps with a prefix of "/" and a directory the same as the default route.
             */
            continue;
        }
        if (!requiredRoute(route)) {
            mprTrace(5, "Skip route %s not required for selected targets", route->name);
            continue;
        }
        /*
            Check for routes with duplicate documents and home directories
         */
        rp = 0;
        for (ITERATE_ITEMS(routes, rp, nextRoute)) {
            if (similarRoute(route, rp)) {
                mprTrace(5, "Skip route %s because of prior similar route: %s", route->name, rp->name);
                route = 0;
                break;
            }
        }
        if (route && mprLookupItem(routes, route) < 0) {
            mprTrace(5, "Compiling route dir: %s name: %s prefix: %s", route->documents, route->name, route->startWith);
            mprAddItem(routes, route);
        }
    }
    if (mprGetListLength(routes) == 0) {
        if (filterRouteName) {
            fail("Cannot find usable ESP configuration in %s for route %s", app->appwebConfig, filterRouteName);
        } else if (filterRoutePrefix) {
            fail("Cannot find usable ESP configuration in %s for route prefix %s", app->appwebConfig, filterRoutePrefix);
        } else {
            kp = mprGetFirstKey(app->targets);
            if (kp) {
                fail("Cannot find usable ESP configuration in %s for %s", app->appwebConfig, kp->key);
            } else {
                fail("Cannot find usable ESP configuration", app->appwebConfig);
            }
        }
        return 0;
    }
    /*
        Check we have a route for all targets
     */
    for (ITERATE_KEYS(app->targets, kp)) {
        if (!kp->type) {
            fail("Cannot find a usable route for %s", kp->key);
            return 0;
        }
    }
    if ((app->route = mprGetFirstItem(routes)) == 0) {
        if (app->require & REQ_ROUTES) {
            fail("Cannot find a suitable route");
        }
        return 0;
    }
    app->eroute = app->route->eroute;
    return routes;
}


/*
    Find a suitable appweb.conf

    Search strategy is: [--config path] : ./appweb.conf : [parent]/appweb.conf
 */
static cchar *findAppwebConfig()
{
    cchar   *name, *path;

    if (app->error || app->require & REQ_NO_CONFIG) {
        return 0;
    }
    name = sclone("appweb.conf");
    path = app->appwebConfig;
    if (path == 0) {
        path = name;
    }
    mprLog(5, "Probe for \"%s\"", path);
    if (!mprPathExists(path, R_OK)) {
        if (app->appwebConfig) {
            /* specified via --config */
            fail("Cannot open config file %s", path);
            return 0;
        }
        path = 0;
#if UNUSED
        for (current = mprGetCurrentPath(); current; current = parent) {
            mprLog(5, "Probe for \"%s\"", current);
            if (mprPathExists(mprJoinPath(current, name), R_OK)) {
                path = mprJoinPath(current, name);
                break;
            }
            parent = mprGetPathParent(current);
            if (mprSamePath(parent, current)) {
                break;
            }
        }
#endif
        if (!path) {
            return 0;
        }
    }
    return path;
}



static int runEspCommand(HttpRoute *route, cchar *command, cchar *csource, cchar *module)
{
    MprCmd      *cmd;
    MprList     *elist;
    MprKey      *var;
    EspRoute    *eroute;
    cchar       **env;
    char        *err, *out;

    eroute = route->eroute;
    cmd = mprCreateCmd(0);
    if ((app->command = espExpandCommand(route, command, csource, module)) == 0) {
        fail("Missing EspCompile directive for %s", csource);
        return MPR_ERR_CANT_READ;
    }
    mprTrace(4, "ESP command: %s\n", app->command);
    if (eroute->env) {
        elist = mprCreateList(0, MPR_LIST_STABLE);
        for (ITERATE_KEYS(eroute->env, var)) {
            mprAddItem(elist, sfmt("%s=%s", var->key, var->data));
        }
        mprAddNullItem(elist);
        env = (cchar**) &elist->items[0];
    } else {
        env = 0;
    }
    if (eroute->searchPath) {
        mprSetCmdSearchPath(cmd, eroute->searchPath);
    }
    if (app->show) {
        trace("Run", app->command);
    }
    //  WARNING: GC will run here
    if (mprRunCmd(cmd, app->command, env, NULL, &out, &err, -1, 0) != 0) {
        if (err == 0 || *err == '\0') {
            /* Windows puts errors to stdout Ugh! */
            err = out;
        }
        fail("Cannot run command: \n%s\nError: %s", app->command, err);
        return MPR_ERR_CANT_COMPLETE;
    }
    if (out && *out) {
#if ME_WIN_LIKE
        if (!scontains(out, "Creating library ")) {
            if (!smatch(mprGetPathBase(csource), strim(out, " \t\r\n", MPR_TRIM_BOTH))) {
                mprRawLog(0, "%s\n", out);
            }
        }
#else
        mprRawLog(0, "%s\n", out);
#endif
    }
    if (err && *err) {
        mprRawLog(0, "%s\n", err);
    }
    return 0;
}


static void compileFile(HttpRoute *route, cchar *source, int kind)
{
    EspRoute    *eroute;
    cchar       *canonical, *defaultLayout, *page, *layout, *data, *prefix, *lpath, *appName;
    char        *err, *quote, *script;
    ssize       len;
    int         recompile;

    if (app->error) {
        return;
    }
    eroute = route->eroute;
    defaultLayout = 0;
    if (kind == ESP_SRC) {
        prefix = "app_";
    } else if (kind == ESP_CONTROlLER) {
        prefix = "controller_";
    } else if (kind == ESP_MIGRATION) {
        prefix = "migration_";
    } else {
        prefix = "view_";
    }
    canonical = mprGetPortablePath(mprGetRelPath(source, route->documents));
    appName = eroute->appName ? eroute->appName : route->host->name;
    app->cacheName = mprGetMD5WithPrefix(sfmt("%s:%s", appName, canonical), -1, prefix);
    app->module = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, app->cacheName, ME_SHOBJ));
    defaultLayout = (eroute->layoutsDir) ? mprJoinPath(eroute->layoutsDir, "default.esp") : 0;
    mprMakeDir(eroute->cacheDir, 0755, -1, -1, 1);

    if (app->combined) {
        why(source, "combined mode forces complete rebuild");

    } else if (app->rebuild) {
        why(source, "due to forced rebuild");

    } else if (!espModuleIsStale(source, app->module, &recompile)) {
        if (kind & (ESP_PAGE | ESP_VIEW)) {
            if ((data = mprReadPathContents(source, &len)) == 0) {
                fail("Cannot read %s", source);
                return;
            }
            if ((lpath = scontains(data, "@ layout \"")) != 0) {
                lpath = strim(&lpath[10], " ", MPR_TRIM_BOTH);
                if ((quote = schr(lpath, '"')) != 0) {
                    *quote = '\0';
                }
                layout = (eroute->layoutsDir && *lpath) ? mprJoinPath(eroute->layoutsDir, lpath) : 0;
            } else {
                layout = defaultLayout;
            }
            if (!layout || !espModuleIsStale(layout, app->module, &recompile)) {
                why(source, "is up to date");
                return;
            }
        } else {
            why(source, "is up to date");
            return;
        }
    } else if (mprPathExists(app->module, R_OK)) {
        why(source, "has been modified");
    } else {
        why(source, "%s is missing", app->module);
    }
    if (app->combinedFile) {
        trace("Catenate", "%s", source);
        mprWriteFileFmt(app->combinedFile, "/*\n    Source from %s\n */\n", source);
    }
    if (kind & (ESP_CONTROlLER | ESP_MIGRATION | ESP_SRC)) {
        app->csource = source;
        if (app->combinedFile) {
            if ((data = mprReadPathContents(source, &len)) == 0) {
                fail("Cannot read %s", source);
                return;
            }
            if (mprWriteFile(app->combinedFile, data, slen(data)) < 0) {
                fail("Cannot write compiled script file %s", app->combinedFile->path);
                return;
            }
            mprWriteFileFmt(app->combinedFile, "\n\n");
            if (kind & ESP_SRC) {
                mprAddItem(app->combinedItems, sfmt("esp_app_%s", eroute->appName));
            } else if (eroute->appName && *eroute->appName) {
                mprAddItem(app->combinedItems, sfmt("esp_controller_%s_%s", eroute->appName, mprTrimPathExt(mprGetPathBase(source))));
            } else {
                mprAddItem(app->combinedItems, sfmt("esp_controller_%s", mprTrimPathExt(mprGetPathBase(source))));
            }
        }
    }
    if (kind & (ESP_PAGE | ESP_VIEW)) {
        if ((page = mprReadPathContents(source, &len)) == 0) {
            fail("Cannot read %s", source);
            return;
        }
        /* No yield here */
        if ((script = espBuildScript(route, page, source, app->cacheName, defaultLayout, NULL, &err)) == 0) {
            fail("Cannot build %s, error %s", source, err);
            return;
        }
        len = slen(script);
        if (app->combinedFile) {
            if (mprWriteFile(app->combinedFile, script, len) < 0) {
                fail("Cannot write compiled script file %s", app->combinedFile->path);
                return;
            }
            mprWriteFileFmt(app->combinedFile, "\n\n");
            mprAddItem(app->combinedItems, sfmt("esp_%s", app->cacheName));

        } else {
            app->csource = mprJoinPathExt(mprTrimPathExt(app->module), ".c");
            trace("Parse", "%s", source);
            mprMakeDir(eroute->cacheDir, 0755, -1, -1, 1);
            if (mprWritePathContents(app->csource, script, len, 0664) < 0) {
                fail("Cannot write compiled script file %s", app->csource);
                return;
            }
        }
    }
    if (!app->combinedFile) {
        /*
            WARNING: GC yield here
         */
        qtrace("Compile", "%s", app->csource);
        if (!eroute->compile) {
            fail("Missing EspCompile directive for %s", app->csource);
            return;
        }
        if (runEspCommand(route, eroute->compile, app->csource, app->module) < 0) {
            return;
        }
        if (eroute->link) {
            vtrace("Link", "%s", mprGetRelPath(mprTrimPathExt(app->module), NULL));
            if (runEspCommand(route, eroute->link, app->csource, app->module) < 0) {
                return;
            }
#if !(ME_DEBUG && MACOSX)
            /*
                MAC needs the object for debug information
             */
            mprDeletePath(mprJoinPathExt(mprTrimPathExt(app->module), ME_OBJ));
#endif
        }
        if (!eroute->keepSource && !app->keep && (kind & (ESP_VIEW | ESP_PAGE))) {
            mprDeletePath(app->csource);
        }
    }
}


/*
    esp compile [controller_names | page_names | paths]
 */
static void compile(int argc, char **argv)
{
    EspRoute    *eroute;
    HttpRoute   *route;
    MprFile     *file;
    MprKey      *kp;
    cchar       *name;
    int         next;

    if (app->error) {
        return;
    }
    app->combined = app->eroute->combined;
    vtrace("Info", "Compiling in %s mode", app->combined ? "combined" : "discrete");

    if (app->genlink) {
        app->slink = mprCreateList(0, MPR_LIST_STABLE);
    }
    for (ITERATE_ITEMS(app->routes, route, next)) {
        eroute = route->eroute;
        mprMakeDir(eroute->cacheDir, 0755, -1, -1, 1);
        mprTrace(2, "Build with route \"%s\" at %s", route->name, route->documents);
        if (app->combined) {
            compileCombined(route);
        } else {
            compileItems(route);
        }
    }
    /*
        Check we have compiled all targets
     */
    for (ITERATE_KEYS(app->targets, kp)) {
        if (!kp->type) {
            fail("Cannot find target %s to compile", kp->key);
        }
    }
    if (app->slink) {
        qtrace("Generate", app->genlink);
        if ((file = mprOpenFile(app->genlink, O_WRONLY | O_TRUNC | O_CREAT | O_BINARY, 0664)) == 0) {
            fail("Cannot open %s", app->combinedPath);
            return;
        }
        mprWriteFileFmt(file, "/*\n    %s -- Generated Appweb Static Initialization\n */\n", app->genlink);
        mprWriteFileFmt(file, "#include \"mpr.h\"\n\n");
        mprWriteFileFmt(file, "#include \"esp.h\"\n\n");
        for (ITERATE_ITEMS(app->slink, route, next)) {
            eroute = route->eroute;
            name = app->appName ? app->appName : mprGetPathBase(route->documents);
            mprWriteFileFmt(file, "extern int esp_app_%s_combined(HttpRoute *route, MprModule *module);", name);
            mprWriteFileFmt(file, "    /* SOURCE %s */\n",
                mprGetRelPath(mprJoinPath(eroute->cacheDir, sjoin(name, ".c", NULL)), NULL));
        }
        mprWriteFileFmt(file, "\nPUBLIC void appwebStaticInitialize()\n{\n");
        for (ITERATE_ITEMS(app->slink, route, next)) {
            name = app->appName ? app->appName : mprGetPathBase(route->documents);
            mprWriteFileFmt(file, "    espStaticInitialize(esp_app_%s_combined, \"%s\", \"%s\");\n", name, name, route->name);
        }
        mprWriteFileFmt(file, "}\n");
        mprCloseFile(file);
        app->slink = 0;
    }
}


/*
    Select a route that is responsible for a target
 */
static bool requiredRoute(HttpRoute *route)
{
    EspRoute    *eroute;
    MprKey      *kp;
    cchar       *source;

    if (app->targets == 0 || mprGetHashLength(app->targets) == 0) {
        return 1;
    }
    for (ITERATE_KEYS(app->targets, kp)) {
        if (mprIsPathContained(route->documents, kp->key)) {
            kp->type = ESP_FOUND_TARGET;
            return 1;
        }
        if (route->sourceName) {
            eroute = route->eroute;
            source = mprJoinPath(eroute->controllersDir, route->sourceName);
            if (mprIsPathContained(kp->key, source)) {
                kp->type = ESP_FOUND_TARGET;
                return 1;
            }
        }
    }
    return 0;
}


/*
    Select a resource that matches specified targets
 */
static bool selectResource(cchar *path, cchar *kind)
{
    MprKey  *kp;
    cchar   *ext;

    ext = mprGetPathExt(path);
    if (kind && !smatch(ext, kind)) {
        return 0;
    }
    if (app->targets == 0 || mprGetHashLength(app->targets) == 0) {
        return 1;
    }
    for (ITERATE_KEYS(app->targets, kp)) {
        if (mprIsPathContained(kp->key, path)) {
            kp->type = ESP_FOUND_TARGET;
            return 1;
        }
    }
    return 0;
}


/*
    Compile all the items relevant to a route
 */
static void compileItems(HttpRoute *route)
{
    EspRoute    *eroute;
    MprDirEntry *dp;
    cchar       *path;
    int         next;

    eroute = route->eroute;
    if (eroute->controllersDir) {
        assert(eroute);
        app->files = mprGetPathFiles(eroute->controllersDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (selectResource(path, "c")) {
                compileFile(route, path, ESP_CONTROlLER);
            }
        }
    }
    if (eroute->viewsDir) {
        app->files = mprGetPathFiles(eroute->viewsDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (sstarts(path, eroute->layoutsDir)) {
                continue;
            }
            if (selectResource(path, "esp")) {
                compileFile(route, path, ESP_VIEW);
            }
        }
    }
    if (eroute->srcDir) {
        path = mprJoinPath(eroute->srcDir, "app.c");
        if (mprPathExists(path, R_OK) && selectResource(path, "c")) {
            compileFile(route, path, ESP_SRC);
        }
    }
    if (eroute->clientDir) {
        app->files = mprGetPathFiles(eroute->clientDir, MPR_PATH_DESCEND | MPR_PATH_NODIRS);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (sstarts(path, eroute->generateDir)) {
                continue;
            }
            if (sstarts(path, eroute->layoutsDir)) {
                continue;
            }
            if (sstarts(path, eroute->paksDir)) {
                continue;
            }
            if (sstarts(path, eroute->viewsDir)) {
                continue;
            }
            if (selectResource(path, "esp")) {
                compileFile(route, path, ESP_PAGE);
            }
        }

    } else {
        /* Non-MVC */
        app->files = mprGetPathFiles(route->documents, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (selectResource(path, "esp")) {
                compileFile(route, path, ESP_PAGE);
            }
        }
        /*
            Stand-alone controllers
         */
        if (route->sourceName) {
            path = mprJoinPath(route->home, route->sourceName);
            if (mprPathExists(path, R_OK)) {
                compileFile(route, path, ESP_CONTROlLER);
            }
        }
    }
}


/*
    Compile all the items for a route into a combined (single) output file
 */
static void compileCombined(HttpRoute *route)
{
    MprDirEntry     *dp;
    MprKeyValue     *kp;
    EspRoute        *eroute;
    cchar           *name;
    char            *path, *line;
    int             next, kind;

    eroute = route->eroute;
    name = app->appName ? app->appName : mprGetPathBase(route->documents);

    /*
        Combined ... Catenate all source
     */
    app->combinedItems = mprCreateList(-1, MPR_LIST_STABLE);
    app->combinedPath = mprJoinPath(eroute->cacheDir, sjoin(name, ".c", NULL));

    app->build = mprCreateList(0, MPR_LIST_STABLE);
    path = mprJoinPath(app->eroute->srcDir, "app.c");
    if (mprPathExists(path, R_OK)) {
        mprAddItem(app->build, mprCreateKeyPair(path, "src", 0));
    }
    if (eroute->controllersDir) {
        app->files = mprGetPathFiles(eroute->controllersDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (smatch(mprGetPathExt(path), "c")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "controller", 0));
            }
        }
    }
    if (eroute->clientDir) {
        app->files = mprGetPathFiles(eroute->clientDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (sstarts(path, eroute->layoutsDir)) {
                continue;
            }
            if (sstarts(path, eroute->viewsDir)) {
                continue;
            }
            if (smatch(mprGetPathExt(path), "esp")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "page", 0));
            }
        }
    }
    if (eroute->viewsDir) {
        app->files = mprGetPathFiles(eroute->viewsDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (smatch(mprGetPathExt(path), "esp")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "view", 0));
            }
        }
    }
    if (!eroute->controllersDir && !eroute->clientDir) {
        app->files = mprGetPathFiles(route->documents, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (smatch(mprGetPathExt(path), "esp")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "page", 0));
            }
        }
    }
    if (mprGetListLength(app->build) > 0) {
        if ((app->combinedFile = mprOpenFile(app->combinedPath, O_WRONLY | O_TRUNC | O_CREAT | O_BINARY, 0664)) == 0) {
            fail("Cannot open %s", app->combinedPath);
            return;
        }
        mprWriteFileFmt(app->combinedFile, "/*\n    Combined compilation of %s\n */\n\n", name);
        mprWriteFileFmt(app->combinedFile, "#include \"esp.h\"\n\n");

        for (ITERATE_ITEMS(app->build, kp, next)) {
            if (smatch(kp->value, "src")) {
                kind = ESP_SRC;
            } else if (smatch(kp->value, "controller")) {
                kind = ESP_CONTROlLER;
            } else if (smatch(kp->value, "page")) {
                kind = ESP_VIEW;
            } else {
                kind = ESP_PAGE;
            }
            compileFile(route, kp->key, kind);
        }
        if (app->slink) {
            mprAddItem(app->slink, route);
        }
        mprWriteFileFmt(app->combinedFile, "\nESP_EXPORT int esp_app_%s_combined(HttpRoute *route, MprModule *module) {\n", name);
        for (next = 0; (line = mprGetNextItem(app->combinedItems, &next)) != 0; ) {
            mprWriteFileFmt(app->combinedFile, "    %s(route, module);\n", line);
        }
        mprWriteFileFmt(app->combinedFile, "    return 0;\n}\n");
        mprCloseFile(app->combinedFile);

        app->module = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, name, ME_SHOBJ));
        qtrace("Compile", "%s", name);
        if (runEspCommand(route, eroute->compile, app->combinedPath, app->module) < 0) {
            return;
        }
        if (eroute->link) {
            trace("Link", "%s", mprGetRelPath(mprTrimPathExt(app->module), NULL));
            if (runEspCommand(route, eroute->link, app->combinedPath, app->module) < 0) {
                return;
            }
        }
    }
    app->combinedItems = 0;
    app->combinedFile = 0;
    app->combinedPath = 0;
    app->build = 0;
}


static void generateItem(cchar *item)
{
    if (getConfigValue(sfmt("esp.server.generate.%s", item), 0) == 0) {
        fail("No suitable package installed to generate %s", item);
        return;
    }
    genKey(item, 0, 0);
}


/*
    esp generate controller name [action [, action] ...]

    Generate a server-side controller.
 */
static void generateController(int argc, char **argv)
{
    MprHash     *tokens;
    cchar       *action, *actions, *defines;
    int         i;

    if (argc < 1) {
        usageError();
        return;
    }
    if (getConfigValue("esp.server.generate.controller", 0) == 0) {
        fail("No suitable package installed to generate controllers");
        return;
    }
    app->controller = sclone(argv[0]);
    defines = sclone("");
    actions = sclone("");
    for (i = 1; i < argc; i++) {
        action = argv[i];
        defines = sjoin(defines, sfmt("    espDefineAction(route, \"%s-cmd-%s\", %s);\n", app->controller, action, action), NULL);
        actions = sjoin(actions, sfmt("static void %s() {\n}\n\n", action), NULL);
    }
    tokens = makeTokens(0, mprDeserialize(sfmt("{ ACTIONS: '%s', DEFINE_ACTIONS: '%s' }", actions, defines)));
    genKey("controller", sfmt("%s/%s.c", app->eroute->controllersDir, app->controller), tokens);
}


/*
    esp migration description model [field:type [, field:type] ...]

    The description is used to name the migration
 */
static void generateMigration(int argc, char **argv)
{
    cchar       *name, *stem, *table;

    if (argc < 2) {
        fail("Bad migration command line");
    }
    table = app->table ? app->table : sclone(argv[1]);
    stem = sfmt("Migration %s", argv[0]);
    /* 
        Migration name used in the filename and in the exported load symbol 
     */
    name = sreplace(slower(stem), " ", "_");
    createMigration(name, table, stem, argc - 2, &argv[2]);
}


static void createMigration(cchar *name, cchar *table, cchar *comment, int fieldCount, char **fields)
{
    MprHash     *tokens;
    MprList     *files;
    MprDirEntry *dp;
    cchar       *dir, *seq, *forward, *backward, *data, *path, *def, *field, *tail, *typeDefine;
    char        *typeString;
    int         i, type, next;

    seq = sfmt("%s%d", mprGetDate("%Y%m%d%H%M%S"), nextMigration);
    forward = sfmt("    ediAddTable(db, \"%s\");\n", table);
    backward = sfmt("    ediRemoveTable(db, \"%s\");\n", table);

    def = sfmt("    ediAddColumn(db, \"%s\", \"id\", EDI_TYPE_INT, EDI_AUTO_INC | EDI_INDEX | EDI_KEY);\n", table);
    forward = sjoin(forward, def, NULL);

    for (i = 0; i < fieldCount; i++) {
        field = stok(sclone(fields[i]), ":", &typeString);
        if ((type = ediParseTypeString(typeString)) < 0) {
            fail("Unknown type '%s' for field '%s'", typeString, field);
            return;
        }
        if (smatch(field, "id")) {
            continue;
        }
        typeDefine = sfmt("EDI_TYPE_%s", supper(ediGetTypeString(type)));
        def = sfmt("    ediAddColumn(db, \"%s\", \"%s\", %s, 0);\n", table, field, typeDefine);
        forward = sjoin(forward, def, NULL);
    }
    tokens = mprDeserialize(sfmt("{ MIGRATION: '%s', TABLE: '%s', COMMENT: '%s', FORWARD: '%s', BACKWARD: '%s' }", 
        name, table, comment, forward, backward));
    if ((data = getTemplate("migration", tokens)) == 0) {
        return;
    }
    dir = mprJoinPath(app->eroute->dbDir, "migrations");
    makeEspDir(dir);
    files = mprGetPathFiles("db/migrations", MPR_PATH_RELATIVE);
    tail = sfmt("%s.c", name);
    for (ITERATE_ITEMS(files, dp, next)) {
        if (sends(dp->name, tail)) {
            if (!app->overwrite && !app->force) {
                qtrace("Exists", "A migration with the same description already exists: %s", dp->name);
                return;
            }
            mprDeletePath(mprJoinPath("db/migrations/", dp->name));
        }
    }
    path = sfmt("%s/%s_%s.c", dir, seq, name, ".c");
    makeEspFile(path, data, 0);
}


static void generateScaffoldController(int argc, char **argv)
{
    cchar   *key;

    key = app->singleton ? "controller-singleton" : "controller";
    genKey(key, sfmt("%s/%s.c", app->eroute->controllersDir, app->controller), 0);
}


static void generateClientController(int argc, char **argv)
{
    genKey("clientController", sfmt("%s/%s/%sControl.js", app->eroute->appDir, app->controller, stitle(app->controller)), 0);
}


static void generateClientModel(int argc, char **argv)
{
    genKey("clientModel", sfmt("%s/%s/%s.js", app->eroute->appDir, app->controller, stitle(app->controller)), 0);
}


/*
    Called with args: model [field:type [, field:type] ...]
 */
static void generateScaffoldMigration(int argc, char **argv)
{
    cchar       *comment;

    if (argc < 1) {
        fail("Bad migration command line");
    }
    comment = sfmt("Create Scaffold %s", stitle(app->controller));
    createMigration(sfmt("create_scaffold_%s", app->table), app->table, comment, argc - 1, &argv[1]);
}


/*
    esp generate table name [field:type [, field:type] ...]
 */
static void generateTable(int argc, char **argv)
{
    Edi         *edi;
    cchar       *field;
    char        *typeString;
    int         rc, i, type;

    app->table = app->table ? app->table : sclone(argv[0]);
    if ((edi = app->eroute->edi) == 0) {
        fail("Database not open. Check appweb.conf");
        return;
    }
    edi->flags |= EDI_SUPPRESS_SAVE;
    if ((rc = ediAddTable(edi, app->table)) < 0) {
        if (rc != MPR_ERR_ALREADY_EXISTS) {
            fail("Cannot add table '%s'", app->table);
        }
    } else {
        if ((rc = ediAddColumn(edi, app->table, "id", EDI_TYPE_INT, EDI_AUTO_INC | EDI_INDEX | EDI_KEY)) != 0) {
            fail("Cannot add column 'id'");
        }
    }
    for (i = 1; i < argc && !app->error; i++) {
        field = stok(sclone(argv[i]), ":", &typeString);
        if ((type = ediParseTypeString(typeString)) < 0) {
            fail("Unknown type '%s' for field '%s'", typeString, field);
            break;
        }
        if ((rc = ediAddColumn(edi, app->table, field, type, 0)) != 0) {
            if (rc != MPR_ERR_ALREADY_EXISTS) {
                fail("Cannot add column '%s'", field);
                break;
            } else {
                ediChangeColumn(edi, app->table, field, type, 0);
            }
        }
    }
    edi->flags &= ~EDI_SUPPRESS_SAVE;
    ediSave(edi);
    qtrace("Update", "Database schema");
}


/*
    Called with args: name [field:type [, field:type] ...]
 */
static void generateScaffoldViews(int argc, char **argv)
{
    genKey("clientList", "${APPDIR}/${CONTROLLER}/${CONTROLLER}-${FILENAME}", 0);
    genKey("clientEdit", "${APPDIR}/${CONTROLLER}/${CONTROLLER}-${FILENAME}", 0);
}


/*
    esp generate scaffold NAME [field:type [, field:type] ...]
 */
static void generateScaffold(int argc, char **argv)
{
    char    *plural;

    if (argc < 1) {
        usageError();
        return;
    }
    if (getConfigValue("esp.server.generate.controller", 0) == 0) {
        fail("No suitable package installed to generate scaffolds");
        return;
    }
    app->controller = sclone(argv[0]);
    if (!identifier(app->controller)) {
        fail("Cannot generate scaffold. Controller name must be a valid C identifier");
        return;
    }
    /*
        This feature is undocumented.
        Having plural database table names greatly complicates things and ejsJoin is not able to follow foreign fields: NameId.
     */
    stok(sclone(app->controller), "-", &plural);
    if (plural) {
        app->table = sjoin(app->controller, plural, NULL);
    } else {
        app->table = app->table ? app->table : app->controller;
    }
    generateScaffoldController(argc, argv);
    generateClientController(argc, argv);
    generateScaffoldViews(argc, argv);
    generateClientModel(argc, argv);
    generateScaffoldMigration(argc, argv);
    migrate(0, 0);
}


/*
    Sort versions in decreasing version order.
    Ensure that pre-releases are sorted before production releases
 */
static int reverseSortFiles(MprDirEntry **d1, MprDirEntry **d2)
{
    char    *base1, *base2, *b1, *b2, *p1, *p2;
    int     rc;

    base1 = mprGetPathBase((*d1)->name);
    base2 = mprGetPathBase((*d2)->name);

    if (smatch(base1, base2)) {
        return 0;
    }
    b1 = stok(base1, "-", &p1);
    b2 = stok(base2, "-", &p2);
    rc = scmp(b1, b2);
    if (rc == 0) {
        if (!p1) {
            rc = 1;
        } else if (!p2) {
            rc = -1;
        } else {
            rc = scmp(p1, p2);
        }
    }
    return -rc;
}


static int sortFiles(MprDirEntry **d1, MprDirEntry **d2)
{
    return scmp((*d1)->name, (*d2)->name);
}


static bool upgradePak(cchar *name)
{
    MprJson     *spec;
    cchar       *cachedVersion, *path, *version;

    cachedVersion = getPakVersion(name, NULL);

    path = mprJoinPaths(app->route->documents, app->paksDir, name, ME_ESP_PACKAGE, NULL);
    if ((spec = loadPackage(path)) == 0) {
        fail("Cannot load package.json \"%s\"", path);
        return 0;
    }
    version = mprGetJson(spec, "version", 0);
    if (smatch(cachedVersion, version) && !app->force) {
        qtrace("Info", "Installed %s is current with %s", name, version);
    } else {
        installPak(name, cachedVersion, 1);
    }
    return 1;
}


/*
    Install files for a pak and all its dependencies.
    The name may contain "#version" if version is NULL. If no version is specified, use the latest.
 */
static bool installPak(cchar *name, cchar *criteria, bool topLevel)
{
    MprJson *deps, *cp;
    cchar   *path, *version;
    int     i;

    path = mprJoinPaths(app->route->documents, app->paksDir, name, NULL);
    if (mprPathExists(path, X_OK) && !app->overwrite && !app->force) {
        if (topLevel || app->verbose) {
            qtrace("Info",  "Pak %s is already installed", name);
        }
        return 1;
    }
    if (!criteria) {
        /* Criteria not specified. Look in dependencies to see if there is a criteria */
        deps = mprGetJsonObj(app->config, "dependencies", MPR_JSON_TOP);
        if (deps) {
            for (i = 0, cp = deps->children; i < deps->length; i++, cp = cp->next) {
                if (smatch(cp->name, name)) {
                    criteria = cp->value;
                    break;
                }
            }
        }
    }
    if ((version = findAcceptableVersion(name, criteria)) == 0) {
        return 0;
    }
    if (!blendPak(name, version, topLevel)) {
        return 0;
    }
    //  MOB - Odd place for this
    if (app->database && getConfigValue("esp.server.database", 0) != 0) {
        mprSetJson(app->config, "esp.server.database", 
            sfmt("%s://%s.%s", app->database, app->appName, app->database), 0);
    }
    trace("Save", mprJoinPath(app->route->documents, ME_ESP_PACKAGE));
    savePackage();
    installPakFiles(name, version, topLevel);
    return 1;
}


static void uninstallPak(cchar *name) 
{
    MprJson     *scripts, *script, *spec, *escripts, *escript;
    MprList     *files;
    MprDirEntry *dp;
    cchar       *path, *package;
    char        *base, *cp;
    int         i;

    path = mprJoinPaths(app->route->documents, app->paksDir, name, NULL);
    package = mprJoinPath(path, ME_ESP_PACKAGE);
    if (!mprPathExists(package, R_OK)) {
        fail("Cannot find pak: \"%s\"", name);
        return;
    }
    if ((spec = loadPackage(package)) == 0) {
        fail("Cannot load: \"%s\"", package);
        return;
    }
    qtrace("Remove", name);
    trace("Remove", "Dependency in %s", ME_ESP_PACKAGE);
    mprRemoveJson(app->config, sfmt("dependencies.%s", name));

    trace("Remove", "Client scripts in %s", ME_ESP_PACKAGE);
    scripts = mprGetJsonObj(spec, "client-scripts", MPR_JSON_TOP);
    for (ITERATE_JSON(scripts, script, i)) {
        if (script->type & MPR_JSON_STRING) {
            base = sclone(script->value);
            if ((cp = scontains(base, "/*")) != 0) {
                *cp = '\0';
            }
            base = sreplace(base, "${PAKS}", "paks");
            escripts = mprGetJsonObj(app->config, "client-scripts", MPR_JSON_TOP);
        restart:
            for (ITERATE_JSON(escripts, escript, i)) {
                if (escript->type & MPR_JSON_STRING) {
                    if (sstarts(escript->value, base)) {
                        mprRemoveJsonChild(escripts, escript);
                        goto restart;
                    }
                }
            }
        }
    }
    files = mprGetPathFiles(path, MPR_PATH_DEPTH_FIRST | MPR_PATH_DESCEND);
    for (ITERATE_ITEMS(files, dp, i)) {
        trace("Remove", mprGetRelPath(dp->name, 0));
        mprDeletePath(dp->name);
    }
    mprDeletePath(path);
}


/*
    Blend a pak package.json configuration
    This will recursively blend all dependencies. Order is bottom up so dependencies can define directories.
 */
static bool blendPak(cchar *name, cchar *version, bool topLevel)
{
    MprJson     *cp, *deps, *spec;
    cchar       *path, *dver;
    int         i;

    path = mprJoinPaths(app->route->documents, app->paksDir, name, NULL);
    if (mprPathExists(path, X_OK) && !app->overwrite && !app->force) {
        /* Already installed */
        return 1;
    }
    path = mprJoinPaths(app->paksCacheDir, name, version, ME_ESP_PACKAGE, NULL);
    if ((spec = loadPackage(path)) == 0) {
        fail("Cannot load package.json \"%s\"", path);
        return 0;
    }
    /*
        Blend dependencies bottom up so that lower paks can define dirs
     */
    deps = mprGetJsonObj(spec, "dependencies", MPR_JSON_TOP);
    if (deps) {
        for (i = 0, cp = deps->children; i < deps->length; i++, cp = cp->next) {
            if ((dver = findAcceptableVersion(cp->name, cp->value)) == 0) {
                return 0;
            }
            if (!blendPak(cp->name, dver, 0)) {
                return 0;
            }
        }
    }
    blendSpec(name, version, spec);
    vtrace("Blend", "%s configuration", name);
    return 1;
}


/*
    Blend a key from one json object to another. Does not overwrite existing properties.
 */
static void blendJson(MprJson *dest, cchar *toKey, MprJson *from, cchar *fromKey)
{
    MprJson     *to;

    if ((from = mprGetJsonObj(from, fromKey, 0)) == 0) {
        return;
    }
    if ((to = mprGetJsonObj(dest, toKey, 0)) == 0) {
        to = mprCreateJson(from->type);
    }
    mprBlendJson(to, from, MPR_JSON_OVERWRITE);
    mprSetJsonObj(dest, toKey, to, 0);
}


static bool blendSpec(cchar *name, cchar *version, MprJson *spec)
{
    EspRoute    *eroute;
    MprJson     *blend, *cp, *scripts;
    cchar       *script, *client, *paks, *key;
    char        *major, *minor, *patch;
    int         i;

    eroute = app->eroute;
    if (mprGetJsonObj(spec, "esp", MPR_JSON_TOP) != 0) {
        blendJson(app->config, "esp", spec, "esp");
    }
    if (mprGetJsonObj(spec, "dirs", MPR_JSON_TOP) != 0) {
        blendJson(app->config, "dirs", spec, "dirs");
    }
    /*
        Aggregate client scripts and expand ${} references
     */
    if ((scripts = mprGetJsonObj(spec, "client-scripts", MPR_JSON_TOP)) != 0) {
        if ((client = mprGetJson(app->config, "dirs.client", 0)) == 0) {
            client = sjoin(mprGetPathBase(eroute->clientDir), "/", NULL);
        }
        if ((paks = mprGetJson(app->config, "dirs.paks", 0)) == 0) {
            paks = ESP_PAKS_DIR;
        }
        paks = strim(paks, sjoin(client, "/", NULL), MPR_TRIM_START);
        for (ITERATE_JSON(scripts, cp, i)) {
            if (!(cp->type & MPR_JSON_STRING)) continue;
            script = sreplace(cp->value, "${PAKS}", paks);
            script = stemplateJson(script, app->config);
            if (!mprGetJson(app->config, sfmt("client-scripts[@ = %s]", script), 0)) {
                mprSetJson(app->config, "client-scripts[*]", script, 0);
            }
        }
    }
    blend = mprGetJsonObj(spec, "blend", MPR_JSON_TOP);
    for (ITERATE_JSON(blend, cp, i)) {
        blendJson(app->config, cp->name, spec, cp->value);
    }
    major = stok(sclone(version), ".", &minor);
    minor = stok(minor, ".", &patch);
    key = sfmt("dependencies.%s", name);
    if (!mprGetJson(app->config, key, 0)) {
        mprSetJson(app->config, key, sfmt("~%s.%s", major, minor), 0);
    }
    return 1;
}

/*
    Install files for a pak and all its dependencies.
    The name may contain "#version" if version is NULL. If no version is specified, use the latest.
 */
static bool installPakFiles(cchar *name, cchar *criteria, bool topLevel)
{
    MprJson     *deps, *spec, *cp;
    cchar       *path, *package, *version;
    int         i;

    path = mprJoinPaths(app->route->documents, app->paksDir, name, NULL);
    if (mprPathExists(path, X_OK) && !app->overwrite && !app->force) {
        if (topLevel || app->verbose) {
            qtrace("Info",  "Pak %s is already installed", name);
        }
        return 1;
    }
    if ((version = findAcceptableVersion(name, criteria)) == 0) {
        return 0;
    }
    qtrace(app->upgrade ? "Upgrade" : "Install", "%s %s", name, version);
    path = mprJoinPaths(app->paksCacheDir, name, version, NULL);
    package = mprJoinPath(path, ME_ESP_PACKAGE);
    if ((spec = loadPackage(package)) == 0) {
        fail("Cannot load package.json \"%s\"", package);
        return 0;
    }
    copyEspFiles(name, version, path, app->route->documents);

    /*
        Install required dependencies
     */
    if (!app->upgrade) {
        deps = mprGetJsonObj(spec, "dependencies", MPR_JSON_TOP);
        if (deps) {
            for (i = 0, cp = deps->children; i < deps->length; i++, cp = cp->next) {
                if (!installPakFiles(cp->name, cp->value, 0)) {
                    break;
                }
            }
        }
    }
    trace("Info", "%s successfully installed", name);
    return 1;
}


static MprJson *createPackage()
{
    return mprParseJson(sfmt("{ name: '%s', title: '%s', descript: '%s', version: '1.0.0', \
        dependencies: {}, 'client-scripts': [], dirs: { client: 'client', paks: 'client/paks' }, \
        esp: {server: {routes: 'esp-server'}}}",
        app->appName, app->appName, app->appName));
}


static void copyEspFiles(cchar *name, cchar *version, cchar *fromDir, cchar *toDir)
{
    MprList     *files;
    MprDirEntry *dp;
    MprHash     *relocate;
    MprJson     *config, *export, *ex;
    MprPath     info;
    EspRoute    *eroute;
    cchar       *base, *path, *fname;
    char        *fromData, *toData, *from, *to, *fromSum, *toSum;
    int         i, j, next;

    eroute = app->eroute;
    path = mprJoinPath(fromDir, ME_ESP_PACKAGE);
    if (!mprPathExists(path, R_OK) || (config = loadPackage(path)) == 0) {
        fail("Cannot load %s", path);
        return;
    }
    /*
        Build a list of files to export to the top level
     */
    export = mprGetJsonObj(config, "export", MPR_JSON_TOP);
    relocate = mprCreateHash(0, 0);
    for (ITERATE_JSON(export, ex, i)) {
        if (!(ex->type & MPR_JSON_STRING)) continue;
        files = mprGlobPathFiles(fromDir, ex->value, MPR_PATH_RELATIVE);
        for (ITERATE_ITEMS(files, fname, j)) {
            mprAddKey(relocate, fname, fname);
        }
    }
    if ((base = mprGetJson(app->config, "dirs.paks", 0)) == 0) {
        base = app->paksDir;
    }
    files = mprGetPathFiles(fromDir, MPR_PATH_DESCEND | MPR_PATH_RELATIVE | MPR_PATH_NODIRS);
    for (next = 0; (dp = mprGetNextItem(files, &next)) != 0 && !app->error; ) {
        if (mprLookupKey(relocate, dp->name) != 0) {
            to = mprJoinPath(toDir, dp->name);
        } else {
            to = mprJoinPaths(toDir, base, name, dp->name, NULL);
        }
        from = mprJoinPath(fromDir, dp->name);
        mprGetPathInfo(from, &info);
        if (mprMakeDir(mprGetPathDir(to), 0755, -1, -1, 1) < 0) {
            fail("Cannot make directory %s", mprGetPathDir(to));
            return;
        }
        if (mprPathExists(to, R_OK) && !app->overwrite && !app->upgrade) {
            //  MOB - remove this test
            if (!app->generateApp || app->priorInstall) {
                trace("Exists",  "File: %s", mprGetRelPath(to, 0));
            }
        } else {
            if (app->upgrade) {
                fromData = mprReadPathContents(from, 0);
                fromSum = mprGetMD5(fromData);
                toData = mprReadPathContents(to, 0);
                toSum = mprGetMD5(toData);
                if (!smatch(fromSum, toSum)) {
                    trace("Upgrade",  "File: %s", mprGetRelPath(to, 0));
                    if (mprCopyPath(from, to, info.perms) < 0) {
                        fail("Cannot copy file %s to %s", from, mprGetRelPath(to, 0));
                        return;
                    }
                } else {
                    vtrace("Same",  "File: %s", mprGetRelPath(to, 0));
                }
            } else {
                trace("Create", "%s", mprGetRelPath(to, 0));
                if (mprCopyPath(from, to, info.perms) < 0) {
                    fail("Cannot copy file %s to %s", from, mprGetRelPath(to, 0));
                    return;
                }
            }
        }
    }
}


static void makeEspDir(cchar *path)
{
    if (mprPathExists(path, X_OK)) {
        ;
    } else {
        if (mprMakeDir(path, 0755, -1, -1, 1) < 0) {
            app->error++;
        } else {
            trace("Create",  "Directory: %s", mprGetRelPath(path, 0));
        }
    }
}


static void makeEspFile(cchar *path, cchar *data, ssize len)
{
    bool    exists;

    exists = mprPathExists(path, R_OK);
    if (exists && !app->overwrite && !app->force) {
        if (!app->generateApp) {
            trace("Exists", path);
        }
        return;
    }
    makeEspDir(mprGetPathDir(path));
    if (len <= 0) {
        len = slen(data);
    }
    if (mprWritePathContents(path, data, len, 0644) < 0) {
        fail("Cannot write %s", path);
        return;
    }
    if (!exists) {
        trace("Create", mprGetRelPath(path, 0));
    } else {
        trace("Overwrite", path);
    }
}


static cchar *getCachedPaks()
{
    MprDirEntry     *dp;
    MprJson         *config, *keyword;
    MprList         *files, *result;
    cchar           *base, *path, *version;
    int             index, next, show;

    if (!app->paksCacheDir) {
        return 0;
    }
    result = mprCreateList(0, 0);
    files = mprGetPathFiles(app->paksCacheDir, 0);
    for (ITERATE_ITEMS(files, dp, next)) {
        version = getPakVersion(dp->name, NULL);
        path = mprJoinPaths(dp->name, version, ME_ESP_PACKAGE, NULL);
        if (mprPathExists(path, R_OK)) {
            base = mprGetPathBase(path);
            if ((config = loadPackage(path)) != 0) {
                show = 0;
                if (sstarts(base, "esp-")) {
                    show++;
                } else {
                    MprJson *keywords = mprGetJsonObj(config, "keywords", 0);
                    for (ITERATE_JSON(keywords, keyword, index)) {
                        if (smatch(keyword->value, "esp")) {
                            show++;
                            break;
                        }
                    }
                }
                if (show && !smatch(base, "esp")) {
                    mprAddItem(result, sfmt("%24s: %s", 
                        mprGetJson(config, "name", 0), mprGetJson(config, "description", 0)));
                }
            }
        }
    }
    return mprListToString(result, "\n");
}


#if UNUSED && KEEP
static bool isBinary(cchar *path)
{
    cchar   *mime;

    if ((mime = mprLookupMime(NULL, path)) != 0) {
        if (scontains(mime, "octet-stream") || scontains(mime, "gzip") || sstarts(mime, "image") || sstarts(mime, "video") || sstarts(mime, "audio")) {
            return 1;
        }
    }
    return 0;
}
#endif


static cchar *readTemplate(cchar *path, MprHash *tokens, ssize *len)
{
    cchar   *cp, *data;
    ssize   size;

    if ((data = mprReadPathContents(path, &size)) == 0) {
        fail("Cannot open template file \"%s\"", path);
        return 0;
    }
    if (len) {
        *len = size;
    }
    /* Detect non-text content via premature nulls */
    for (cp = data; *cp; cp++) { }
    if ((cp - data) < size) {
        /* Skip template as the data looks lik binary */
        return data;
    }
    vtrace("Info", "Using template %s", path);
    data = stemplate(data, tokens);
    if (len) {
        *len = slen(data);
    }
    return data;
}


static cchar *getTemplate(cchar *key, MprHash *tokens)
{
    cchar   *pattern;

    if ((pattern = getConfigValue(sfmt("esp.server.generate.%s", key), 0)) != 0) {
        if (mprPathExists(app->eroute->generateDir, X_OK)) {
            return readTemplate(mprJoinPath(app->eroute->generateDir, pattern), tokens, NULL);
        }
#if DEPECATE || 1
        if (mprPathExists("generate", X_OK)) {
            return readTemplate(mprJoinPath("generate", pattern), tokens, NULL);
        }
        if (mprPathExists("templates", X_OK)) {
            return readTemplate(mprJoinPath("templates", pattern), tokens, NULL);
        }
#endif
    }
    return 0;
}


static MprHash *makeTokens(cchar *path, MprHash *other)
{
    MprHash     *tokens;
    cchar       *filename, *list;

    filename = mprGetPathBase(path);
    list = smatch(app->controller, app->table) ? sfmt("%ss", app->controller) : app->table; 
    tokens = mprDeserialize(sfmt(
        "{ APP: '%s', APPDIR: '%s', BINDIR: '%s', DATABASE: '%s', DOCUMENTS: '%s', FILENAME: '%s', HOME: '%s', "
        "LIST: '%s', LISTEN: '%s', CONTROLLER: '%s', UCONTROLLER: '%s', MODEL: '%s', UMODEL: '%s', ROUTES: '%s', "
        "SERVER: '%s', TABLE: '%s', UAPP: '%s', ACTIONS: '', DEFINE_ACTIONS: '', VIEWSDIR: '%s' }",
        app->appName, app->eroute->appDir, app->binDir, app->database, app->route->documents, filename, app->route->home,
        list, app->listen, app->controller, stitle(app->controller), app->controller, stitle(app->controller), app->routeSet, 
            app->route->serverPrefix, app->table, app->title, app->eroute->viewsDir));
    if (other) {
        mprBlendHash(tokens, other);
    }
    return tokens;
}


static void genKey(cchar *key, cchar *path, MprHash *tokens)
{
    cchar       *data, *pattern;

    if (app->error) {
        return;
    }
    if ((pattern = getConfigValue(sfmt("esp.server.generate.%s", key), 0)) == 0) {
        return;
    }
    if (!tokens) {
        tokens = makeTokens(pattern, 0);
    }
    if ((data = getTemplate(key, tokens)) == 0) {
        return;
    }
    if (!path) {
        path = mprTrimPathComponents(pattern, 1);
    }
    makeEspFile(stemplate(path, tokens), data, 0);
}


static void usageError()
{
    cchar   *name, *paks;

    name = mprGetAppName();
    mprEprintf("\nESP Usage:\n\n"
    "  %s [options] [commands]\n\n"
    "  Options:\n"
    "    --config appwebConfig      # Use named config file instead appweb.conf\n"
    "    --database name            # Database provider 'mdb|sdb'\n"
    "    --genlink filename         # Generate a static link module for combined compilations\n"
    "    --home directory           # Change to directory first\n"
    "    --keep                     # Keep intermediate source\n"
    "    --listen [ip:]port         # Generate app to listen at address\n"
    "    --log logFile:level        # Log to file file at verbosity level\n"
    "    --name appName             # Name for the app when compiling combined\n"
    "    --optimize                 # Compile optimized without symbols\n"
    "    --overwrite                # Overwrite existing files\n"
    "    --quiet                    # Don't emit trace\n"
    "    --platform os-arch-profile # Target platform\n"
    "    --rebuild                  # Force a rebuild\n"
    "    --routeName name           # Name of route to select\n"
    "    --routePrefix prefix       # Prefix of route to select\n"
    "    --single                   # Generate a singleton controller\n"
    "    --show                     # Show compile commands\n"
    "    --static                   # Use static linking\n"
    "    --symbols                  # Compile for debug with symbols\n"
    "    --table name               # Override table name if plural required\n"
    "    --verbose                  # Emit more verbose trace\n"
    "    --why                      # Why compile or skip building\n"
    "\n"
    "  Commands:\n"
    "    esp config\n"
    "    esp clean\n"
    "    esp compile [pathFilters ...]\n"
    "    esp debug|release\n"
    "    esp generate app name [paks...]\n"
    "    esp generate controller name [action [, action] ...\n"
    "    esp generate migration description model [field:type [, field:type] ...]\n"
    "    esp generate scaffold model [field:type [, field:type] ...]\n"
    "    esp generate table name [field:type [, field:type] ...]\n"
    "    esp get package-field\n"
    "    esp init\n"
    "    esp install paks...\n"
    "    esp list\n"
    "    esp migrate [forward|backward|NNN]\n"
    "    esp mode [debug|release]\n"
    "    esp [run] [ip]:[port] ...\n"
    "    esp set package-field value\n"
    "    esp uninstall paks...\n"
    "    esp upgrade paks...\n"
    "\n", name);

    initRuntime();
    paks = getCachedPaks();
    if (paks) {
        mprEprintf("  Local Paks: (See also http://embedthis.com/catalog)\n%s\n", paks);
    }
    app->error = 1;
}


static void fail(cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    va_start(args, fmt);
    msg = sfmtv(fmt, args);
    mprError("%s", msg);
    va_end(args);
    app->error = 1;
}


static void fatal(cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    va_start(args, fmt);
    msg = sfmtv(fmt, args);
    mprFatal("%s", msg);
    va_end(args);
}


static void qtrace(cchar *tag, cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    if (!app->silent) {
        va_start(args, fmt);
        msg = sfmtv(fmt, args);
        tag = sfmt("[%s]", tag);
        mprRawLog(0, "%12s %s\n", tag, msg);
        va_end(args);
    }
}


static void trace(cchar *tag, cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    if (!app->quiet) {
        va_start(args, fmt);
        msg = sfmtv(fmt, args);
        tag = sfmt("[%s]", tag);
        mprRawLog(0, "%12s %s\n", tag, msg);
        va_end(args);
    }
}


/*
    Trace when run with --verbose
 */
static void vtrace(cchar *tag, cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    if (app->verbose && !app->quiet) {
        va_start(args, fmt);
        msg = sfmtv(fmt, args);
        tag = sfmt("[%s]", tag);
        mprRawLog(0, "%12s %s\n", tag, msg);
        va_end(args);
    }
}

static void why(cchar *path, cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    if (app->why) {
        va_start(args, fmt);
        msg = sfmtv(fmt, args);
        mprRawLog(0, "%14s %s %s\n", "[Why]", path, msg);
        va_end(args);
    }
}


static MprJson *loadPackage(cchar *path)
{
    MprJson *obj;
    cchar   *errMsg, *str;

    if (!mprPathExists(path, R_OK)) {
        fail("Cannot locate %s", path);
        return 0;
    }
    if ((str = mprReadPathContents(path, NULL)) == 0) {
        fail("Cannot read %s", path);
        return 0;
    } else if ((obj = mprParseJsonEx(str, NULL, 0, 0, &errMsg)) == 0) {
        fail("Cannot load %s. Error: %s", path, errMsg);
        return 0;
    }
    return obj;
}


static void savePackage()
{
    cchar       *path;

    path = mprJoinPath(app->route ? app->route->documents : ".", ME_ESP_PACKAGE);
    if (mprSaveJson(app->config, path, MPR_JSON_PRETTY | MPR_JSON_QUOTES) < 0) {
        fail("Cannot save %s", path);
    }
}


/*
    Get a version string from a name#version or from the latest cached version
 */
static cchar *getPakVersion(cchar *name, cchar *version)
{
    MprDirEntry     *dp;
    MprList         *files;

    if (!version || smatch(version, "*")) {
        name = stok(sclone(name), "#", (char**) &version);
        if (!version) {
            files = mprGetPathFiles(mprJoinPath(app->paksCacheDir, name), MPR_PATH_RELATIVE);
            mprSortList(files, (MprSortProc) reverseSortFiles, 0);
            if ((dp = mprGetFirstItem(files)) != 0) {
                version = mprGetPathBase(dp->name);
            }
            if (version == 0) {
                fail("Cannot find pak: %s", name);
                return 0;
            }
        }
    }
    return version;
}


static bool acceptableVersion(cchar *criteria, cchar *version)
{
    cchar   *expr;
    char    *crit, *ortok, *andtok, *range;
    bool    allMatched;

    crit = strim(sclone(criteria), "v=", MPR_TRIM_START);
    version = strim(sclone(version), "v=", MPR_TRIM_START);
    for (ortok = crit; (range = stok(ortok, "||", &ortok)) != 0; ) {
        range = strim(range, " \t", 0);
        allMatched = 1;
        for (andtok = range; (expr = stok(andtok, "&& \t", &andtok)) != 0; ) {
            if (!inRange(expr, version)) {
                allMatched = 0;
                break;
            }
        }
        if (allMatched) {
            return 1;
        }
    }
    return 0;
}


static bool inRange(cchar *expr, cchar *version)
{
    char    *cp, *op, *base, *pre, *low, *high, *preVersion;
    int64   min, max, numberVersion;
    ssize   i;

    if ((i = strspn(expr, "<>=~ \t")) > 0) {
        op = snclone(expr, i);
        expr = &expr[i];
    } else {
        op = 0;
    }
    if (smatch(expr, "*")) {
        expr = "x";
    }
    version = stok(sclone(version), "-", &preVersion);
    base = stok(sclone(expr), "-", &pre);
    if (op && (*op == '~' || *op == '^')) {
        if (*op == '^' && schr(version, '-')) {
            return 0;
        }
        base = slower(base);
        if ((cp = scontains(base, ".x")) != 0) {
            *cp = '\0';
        }
        return sstarts(version, base);
    }
    if (scontains(base, "x") && !schr(version, '-')) {
        low = sfmt(">=%s", sreplace(base, "x", "0"));
        high = sfmt("<%s", sreplace(base, "x", VER_FACTOR_MAX));
        return inRange(low, version) && inRange(high, version);
    }
    min = 0;
    max = MAX_VER;
    if (!op) {
        min = max = asNumber(base);
    } else if (smatch(op, ">=")) {
        min = asNumber(base);
    } else if (*op == '>') {
        min = asNumber(base) + 1;
    } else if (smatch(op, "<=")) {
        max = asNumber(base);
    } else if (*op == '<') {
        max = asNumber(base) - 1;
    } else {
        min = max = asNumber(base);
    }
    numberVersion = asNumber(version);
    if (min <= numberVersion && numberVersion <= max) {
        if ((pre && smatch(pre, preVersion)) || (!pre && !preVersion)) {
            return 1;
        }
    }
    return 0;
}


static int64 asNumber(cchar *version)
{
    char    *tok;
    int64   major, minor, patch;

    major = stoi(stok(sclone(version), ".", &tok));
    minor = stoi(stok(tok, ".", &tok));
    patch = stoi(stok(tok, ".", &tok));
    return (((major * VER_FACTOR) + minor) * VER_FACTOR) + patch;
}


static cchar *findAcceptableVersion(cchar *name, cchar *criteria)
{
    MprDirEntry     *dp;
    MprList         *files;
    int             next;

    if (!criteria || smatch(criteria, "*")) {
        criteria = "x";
    }
    if (schr(name, '#')) {
        name = stok(sclone(name), "#", (char**) &criteria);
    }
    files = mprGetPathFiles(mprJoinPath(app->paksCacheDir, name), MPR_PATH_RELATIVE);
    mprSortList(files, (MprSortProc) reverseSortFiles, 0);
    for (ITERATE_ITEMS(files, dp, next)) {
        if (acceptableVersion(criteria, dp->name)) {
            return dp->name;
        }
    }
    fail("Cannot find acceptable version for: %s with criteria %s in %s", name, criteria, app->paksCacheDir);
    return 0;
}


static bool identifier(cchar *name)
{
    cchar   *cp;

    if (!name) {
        return 0;
    }
    for (cp = name; *cp; cp++) {
        if (!isalnum(*cp)) {
            break;
        }
    }
    return *cp == '\0' && isalpha(*name);
}
#endif /* ME_COM_ESP */

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2014. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
