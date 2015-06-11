FROM debian:jessie
MAINTAINER David Personette <dperson@dperson.com>

# Install kibana
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export URL='https://download.elasticsearch.org/kibana/kibana' && \
    export version='4.1.0' && \
    export sha1sum='db27d030fe0f103d416cd9acad42c35a1418b5f5' && \
    groupadd -r kibana && useradd -r -g kibana kibana && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    curl -LOC- -s $URL/kibana-${version}-linux-x64.tar.gz && \
    sha1sum kibana-${version}-linux-x64.tar.gz | grep -q "$sha1sum" && \
    tar -xf kibana-${version}-linux-x64.tar.gz -C /tmp && \
    mv /tmp/kibana-* /opt/kibana && \
    apt-get purge -qqy ca-certificates curl && \
    apt-get autoremove -qqy && apt-get clean -qqy && \
    rm -rf /tmp/* /var/lib/apt/lists/* kibana-${version}-linux-x64.tar.gz
COPY kibana.sh /usr/bin/

EXPOSE 5601

VOLUME ["/opt/kibana/config"]

ENTRYPOINT ["kibana.sh"]
