FROM postgres:16

RUN apt-get update && apt-get install -y \
    pgbackrest \
    postgresql-16-cron \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Create directories for archive and backrest, change permissions
RUN mkdir -p /var/lib/postgresql/archive && \
    mkdir -p /var/lib/pgbackrest && \
    mkdir -p /var/log/pgbackrest && \
    chown postgres:postgres /var/lib/postgresql/archive && \
    chown postgres:postgres /var/lib/pgbackrest && \
    chown postgres:postgres /var/log/pgbackrest

# Set up cron jobs for pgBackRest (System cron)
RUN echo "0 2 * * * postgres pgbackrest --stanza=bankdb backup --type=incr >> /var/log/pgbackrest/cron.log 2>&1" > /etc/cron.d/pgbackrest && \
    echo "0 3 * * 0 postgres pgbackrest --stanza=bankdb backup --type=diff >> /var/log/pgbackrest/cron.log 2>&1" >> /etc/cron.d/pgbackrest && \
    echo "0 4 1 * * postgres pgbackrest --stanza=bankdb backup --type=full >> /var/log/pgbackrest/cron.log 2>&1" >> /etc/cron.d/pgbackrest && \
    chmod 0644 /etc/cron.d/pgbackrest && \
    crontab -u postgres /etc/cron.d/pgbackrest

# Add script to start cron daemon and then original postgres entrypoint
RUN echo '#!/bin/bash\ncron\nexec "$@"' > /usr/local/bin/entrypoint-wrapper.sh && \
    chmod +x /usr/local/bin/entrypoint-wrapper.sh

ENTRYPOINT ["/usr/local/bin/entrypoint-wrapper.sh", "docker-entrypoint.sh"]
CMD ["postgres"]
