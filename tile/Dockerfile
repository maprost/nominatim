FROM overv/openstreetmap-tile-server
ENV ALLOW_CORS=enabled
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
