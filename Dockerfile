FROM mysql:5.7

WORKDIR /tools

COPY thanos.sh /tools/

CMD ["/tools/thanos.sh"]

