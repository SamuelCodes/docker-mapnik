FROM ubuntu:latest
MAINTAINER Sam Coles <sam.coles@giantquanta.com>

RUN apt-get update && apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository ppa:mapnik/nightly-trunk
RUN apt-get update
RUN apt-get install -y libmapnik libmapnik-dev mapnik-utils python-mapnik \
                       mapnik-input-plugin-gdal mapnik-input-plugin-ogr \
                       mapnik-input-plugin-postgis \
                       mapnik-input-plugin-sqlite \
                       mapnik-input-plugin-osm

# This volume is used for osm imports
RUN mkdir -p /data/osm
VOLUME /data/osm/

# Build the latest version of osm2pgsql
RUN apt-get install -y build-essential libxml2-dev libgeos++-dev libpq-dev \
                       libbz2-dev libproj-dev libtool automake git \
                       libprotobuf-c0-dev protobuf-c-compiler \
                       lua5.2 liblua5.2-0 liblua5.2-dev liblua5.1-0

# Install utilities
RUN apt-get install -y curl postgresql-client-9.3

RUN git clone --depth=1 https://github.com/openstreetmap/osm2pgsql.git /tmp/osm2pgsql
WORKDIR /tmp/osm2pgsql
RUN ./autogen.sh && ./configure && make && make install

# Setup the entrypoint
ADD map.sh /map
RUN chmod a+x /map
ENTRYPOINT ["/map"]

# The default command is to run a tileserver
WORKDIR /data
CMD ["tiles"]
EXPOSE 8080

# Cleanup sources
RUN rm -rf /tmp/osm2pgsql
