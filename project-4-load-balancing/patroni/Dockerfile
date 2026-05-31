FROM postgres:16
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3-pip python3-venv curl \
 && pip3 install --break-system-packages "patroni[etcd3]" psycopg2-binary \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV PATH=$PATH:/usr/lib/postgresql/16/bin
# Run Patroni as 'postgres' user, not root (initdb rejects root).
USER postgres
ENTRYPOINT ["patroni"]
CMD ["/etc/patroni/patroni.yml"]
