# kivy-p4a
FROM ubuntu:18.04

ENV USER="user"
ENV HOME_DIR="/home/${USER}"
ENV WORK_DIR="${HOME_DIR}/hostcwd" \
    PATH="${HOME_DIR}/.local/bin:${PATH}"

RUN apt update -qq > /dev/null && \
    apt install -qq --yes --no-install-recommends \
    locales && \
    locale-gen en_US.UTF-8 && \
    apt install -qq --yes mc openssh-client nano wget curl pkg-config autoconf automake libtool git && apt install -qq --yes --no-install-recommends \
    sudo openjdk-8-jdk zip unzip virtualenv python3-pip python3-setuptools file zlib1g-dev time


ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

# prepares non root env
RUN useradd --create-home --shell /bin/bash ${USER}
# with sudo access and no password
RUN usermod -append --groups sudo ${USER}
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR ${WORK_DIR}

#COPY . .

#RUN chown user /home/user/ -Rv

USER ${USER}

RUN pip3 install cython git+https://github.com/kivy/python-for-android.git git+https://github.com/HeaTTheatR/KivyMD.git

RUN    sudo mkdir manbuild && sudo chown user manbuild && cd manbuild \
    && wget --quiet https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && wget --quiet https://dl.google.com/android/repository/android-ndk-r17c-linux-x86_64.zip \
    && unzip -q -d sdk  sdk-tools-linux-4333796.zip && unzip -q android-ndk-r17c-linux-x86_64.zip && rm *.zip \
    && cd sdk/tools/bin && while true; do echo "y"; sleep 1; done  | ./sdkmanager "platforms;android-28" && ./sdkmanager "build-tools;28.0.3"

COPY . app

RUN sudo chown user ${WORK_DIR}/app -Rv

#USER root
#RUN chown user /home/user/ -R && chown -R user /home/user/hostcwd

#USER ${USER}

RUN echo '-----Python 3 ----' && cd app/demos/kitchen_sink/ \
    && time p4a apk

CMD tail -f /var/log/faillog

#ENTRYPOINT ["buildozer"]
