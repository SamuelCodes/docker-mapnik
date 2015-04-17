#!/bin/bash

import() {
  osm2pgsql --create --database gis --slim -C 2048 --flat-nodes /data/osm \
            --host pg --username giskit $1
}

bootstrap_osm() {
  echo "Installing hstore in database"
  psql -h pg -d gis -U giskit -c 'CREATE EXTENSION hstore;'
  echo "Downloading the latest planet.osm"
  curl -# -o /data/osm/planet.osm.bz2 http://ftp5.gwdg.de/pub/misc/openstreetmap/planet.openstreetmap.org/planet/planet-latest.osm.bz2
  import "/data/osm/planet.osm.bz2"
}

case $1 in
  bootstrap_osm)
    bootstrap_osm
    ;;
  tiles)
    echo "Tiles not implemented yet"
    ;;
  import)
    import_file=${$2:-planet.osm}
    if [ -f $import_file ]
    then
      import $import_file
    else
      echo "No such file: $import_file"
    fi
    ;;
  *)
    eval ${*}
    ;;
esac
