FROM debian:stretch
MAINTAINER David Personette <dperson@gmail.com>

# Install kibana
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export url='https://artifacts.elastic.co/downloads/kibana' && \
    export version='5.5.1' && \
    export sha1sum='6dba24c876841fdf116a413c843f09d3e98b4002' && \
    groupadd -r kibana && \
    useradd -c 'Kibana' -d /opt/kibana -g kibana -r kibana && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl \
                procps libfontconfig libfreetype6 \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    file="kibana-${version}-linux-x86_64.tar.gz" && \
    echo "downloading $file ..." && \
    curl -LOSs ${url}/$file && \
    sha1sum $file | grep -q "$sha1sum" || \
    { echo "expected $sha1sum, got $(sha1sum $file)"; exit 13; } && \
    tar -xf $file -C /tmp && \
    mv /tmp/kibana-* /opt/kibana && \
    chown -Rh kibana. /opt/kibana && \
    apt-get purge -qqy ca-certificates curl && \
    apt-get autoremove -qqy && apt-get clean -qqy && \
    rm -rf /tmp/* /var/lib/apt/lists/* $file
COPY kibana.sh /usr/bin/

EXPOSE 5601

VOLUME ["/opt/kibana"]

ENTRYPOINT ["kibana.sh"]