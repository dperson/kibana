[![logo](https://raw.githubusercontent.com/dperson/kibana/master/logo.png)](https://www.elastic.co/products/kibana)

# Kibana

Kibana docker container

# What is Kibana?

Kibana allows you to see the value in your data

 * Flexible analytics and visualization platform
 * Real-time summary and charting of streaming data
 * Intuitive interface for a variety of users
 * Instant sharing and embedding of dashboards

# How to use this image

When started Kibana container will listen on port 5601

## Hosting a Kibana instance

    sudo docker run -it -d dperson/kibana

## Configuration

    sudo docker run -it --rm dperson/kibana -h

    Usage: kibana.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -t ""       Configure timezone
                    possible arg: "[timezone]" - zoneinfo timezone for container

    The 'command' (if provided and valid) will be run instead of kibana

ENVIRONMENT VARIABLES

 * `TZ` - As above, configure the zoneinfo timezone, IE `EST5EDT`
 * `USERID` - Set the UID for the app user
 * `GROUPID` - Set the GID for the app user
 * `ELASTICSEARCH` - URL for elasticsearch backend
 * `KIBANA_INDEX` - Index name
 * `DEFAULT_APP_ID` - Default App ID
 * `TIMEOUT` - Timeout for elasticsearch connection
 * `SHARD_TIME` - Shard timeout
 * `VERIFY_SSL` - Verify SSL

## Examples

Any of the commands can be run at creation with `docker run` or later with
`docker exec -it kibana kibana.sh` (as of version 1.3 of docker).

### Setting the Timezone

    sudo docker run -it -p 5601:5601 -d dperson/kibana -t EST5EDT

OR using `environment variables`

    sudo docker run -it -p 5601:5601 -e TZ=EST5EDT -d dperson/kibana

Will get you the same settings as

    sudo docker run -it --name kibana -p 5601:5601 -d dperson/kibana
    sudo docker exec -it kibana kibana.sh -t EST5EDT ls -AlF /etc/localtime
    sudo docker restart kibana

## Complex configuration

[Example configs](http://www.elastic.co/guide/)

If you wish to adapt the default configuration, use something like the following
to copy it from a running container:

    sudo docker cp es:/opt/kibana/config /some/path

You can use the modified configuration with:

    sudo docker run -it --name es -p 5601:5601 \
                -v /some/path:/opt/kibana/config:ro -d dperson/kibana

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/dperson/kibana/issues).