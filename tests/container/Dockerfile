# =============================================================================
#  Contenedor de prueba para archrice (Arch Linux)
#  Uso:  docker build -t archrice-test -f tests/container/Dockerfile .
#        docker run --rm archrice-test
# =============================================================================
FROM archlinux:base

RUN pacman -Syu --noconfirm \
 && pacman -S --noconfirm --needed \
      bash coreutils grep sed gawk findutils python sudo git

# install.sh exige usuario no root
RUN useradd -m -s /bin/bash tester \
 && echo 'tester ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/tester \
 && chmod 0440 /etc/sudoers.d/tester

COPY . /archrice
RUN chown -R tester:tester /archrice

USER tester
WORKDIR /archrice
ENV HOME=/home/tester

CMD ["bash", "tests/container/smoke-test.sh"]
