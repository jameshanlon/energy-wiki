#!/bin/bash

. CONFIG

# Finish intallation of memodump theme.
cp /moinmoin-memodump/memodump.py /opt/moin/wiki/data/plugin/theme/

# Set permissions on data.
chown -R www-data:www-data /opt/moin/wiki/data
