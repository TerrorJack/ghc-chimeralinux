FROM chimeralinux/chimera

COPY build.sh /tmp

RUN /tmp/build.sh

ENV \
  PATH=/root/.local/bin:${PATH}
