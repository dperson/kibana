FROM alpine
MAINTAINER David Personette <dperson@gmail.com>

# Install kibana
RUN export url='https://artifacts.elastic.co/downloads/kibana' && \
    export version='7.3.1' && \
    export shasum='7c74ade7ba13ce0163787a72f92e6bbd9bf478d36f356897d9568c0' && \
    apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl fontconfig freetype shadow tini \
                tzdata && \
    addgroup -S kibana && \
    adduser -S -D -H -h /opt/kibana -s /sbin/nologin -G kibana -g 'Kibana User'\
                kibana && \
    file="kibana-${version}-linux-x86_64.tar.gz" && \
    echo "downloading $file ..." && \
    curl -LOSs ${url}/$file && \
    sha512sum $file | grep -q "$shasum" || \
    { echo "expected $shasum, got $(sha512sum $file)"; exit 13; } && \
    tar -xf $file -C /tmp && \
    mv /tmp/kibana-* /opt/kibana && \
    chown -Rh kibana. /opt/kibana && \
    rm -rf /tmp/* $file
COPY kibana.sh /usr/bin/

EXPOSE 5601

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -Lk 'http://localhost:5601/app/kibana/'

VOLUME ["/opt/kibana"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/kibana.sh"]