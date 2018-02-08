FROM openjdk:8-jre-alpine

RUN apk add --no-cache --quiet \
    bash \
    curl

ENV NEO4J_SHA256=8a2a74f1270944d9b72f2af2c15cb350718e697af6e3800e67cb32a5d1605f6e \
    NEO4J_TARBALL=neo4j-community-3.3.2-unix.tar.gz \
    NEO4J_EDITION=community

ARG NEO4J_URI=http://dist.neo4j.org/neo4j-community-3.3.2-unix.tar.gz

RUN curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256}  ${NEO4J_TARBALL}" | sha256sum -csw - \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL} \
    && mv /var/lib/neo4j/data /data \
    && ln -s /data /var/lib/neo4j/data \
    && apk del curl

ENV PATH /var/lib/neo4j/bin:$PATH

WORKDIR /var/lib/neo4j

VOLUME /data

COPY plugins/*.jar plugins/
COPY guides/*.html guides/

ENV NEO4J_dbms_read__only=true \
    NEO4J_dbms_unmanaged__extension__classes='extension.web=/guides' \
    NEO4J_org_neo4j_server_guide_directory='guides' \
    NEO4J_dbms_allowFormatMigration=true \
    NEO4J_dbms_security_procedures_unrestricted='apoc.\\\*' 
RUN echo 'browser.remote_content_hostname_whitelist=*' >> conf/neo4j.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 7474 7473 7687

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["neo4j"]
