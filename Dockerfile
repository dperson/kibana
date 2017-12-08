FROM debian:stretch
MAINTAINER David Personette <dperson@gmail.com>

# Install kibana
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export url='https://artifacts.elastic.co/downloads/kibana' && \
    export version='6.0.1' && \
    export shasum='3761f8abff5d949631f365c228af2f205597e1f05137d0140917b35' && \
    groupadd -r kibana && \
    useradd -c 'Kibana' -d /opt/kibana -g kibana -r kibana && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl \
                procps libfontconfig libfreetype6 \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    file="kibana-${version}-linux-x86_64.tar.gz" && \
    echo "downloading $file ..." && \
    curl -LOSs ${url}/$file && \
    sha512sum $file | grep -q "$shasum" || \
    { echo "expected $shasum, got $(sha512sum $file)"; exit 13; } && \
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