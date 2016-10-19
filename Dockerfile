FROM debian:stretch
MAINTAINER David Personette <dperson@gmail.com>

# Install kibana
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export url='https://download.elastic.co/kibana/kibana' && \
    export version='4.6.1' && \
    export sha1sum='b0191e833c83a348bbf6b09628756e898cceb73b' && \
    groupadd -r kibana && \
    useradd -c 'Kibana' -d /opt/kibana -g kibana -r kibana && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl psutils \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    echo "downloading kibana-${version}-linux-x64.tar.gz ..." && \
    curl -LOC- -s ${url}/kibana-${version}-linux-x86_64.tar.gz && \
    sha1sum kibana-${version}-linux-x86_64.tar.gz | grep -q "$sha1sum" && \
    tar -xf kibana-${version}-linux-x86_64.tar.gz -C /tmp && \
    mv /tmp/kibana-* /opt/kibana && \
    chown -Rh kibana. /opt/kibana && \
    apt-get purge -qqy ca-certificates curl && \
    apt-get autoremove -qqy && apt-get clean -qqy && \
    rm -rf /tmp/* /var/lib/apt/lists/* kibana-${version}-linux-x86_64.tar.gz
COPY kibana.sh /usr/bin/

EXPOSE 5601

VOLUME ["/opt/kibana"]

ENTRYPOINT ["kibana.sh"]