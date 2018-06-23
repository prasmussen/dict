{ pkgs ? import <nixpkgs> {} }:
let
  dictBackend =
    import ./dict-backend {};

  dictStatic =
    import ./dict-static {};

  dictDictionaries =
    import ./dict-dictionaries {};

  dictCfg =
    import ./dict-app-config.nix;

  listenAddr =
    ":${toString dictCfg.listenPort}";

  dictPlan =
    { resources, pkgs, lib, nodes, ... }:
    { networking.firewall.allowedTCPPorts =
        [ 22
          dictCfg.listenPort
        ];

      services.mongodb.enable = true;

      users.extraUsers = pkgs.lib.singleton
        { name = dictCfg.user;
          description = "dict-app user";
        };

      systemd.services.dict-dictionaries-init =
        { description = "dict-dictionaries database initialisation";
          after = [ "mongodb.service" ];
          wantedBy = [ "multi-user.target" ];

          environment =
            { LC_ALL = "en_US.UTF-8";
              LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
            };

          serviceConfig =
            { Type = "oneshot";
              RemainAfterExit = false;
              User = dictCfg.user;
            };

          script =
            ''
            query='dbs = db.adminCommand( { listDatabases: 1, filter: { "name": "dictionaries" } } ).databases; dbs.length > 0 && dbs[0].sizeOnDisk > 10000;'
            dbExists=$(${pkgs.mongodb}/bin/mongo --quiet --eval "$query")
            if [ "$dbExists" == "false" ]; then
                echo "Restoring database..."
                ${pkgs.mongodb-tools}/bin/mongorestore -d dictionaries ${dictDictionaries}
            else
                echo "Database already exists, all ok"
            fi
            '';
        };

      systemd.services.dict-backend =
        { description = "dict-backend";
          after = [ "dict-dictionaries-init.service" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig =
            { WorkingDirectory = "${dictBackend}";
              ExecStart = "${dictBackend}/bin/dict-backend";
              Restart = "always";
              User = dictCfg.user;
            };

          environment =
            { LC_ALL = "en_US.UTF-8";
              LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
              STATIC_PATH = "${dictStatic}";
              DB_URL = dictCfg.dbUrl;
              LISTEN_ADDR = listenAddr;
            };
        };
    };
in
{ dict-app = dictPlan;
}
