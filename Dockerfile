# Build Android Apps in docker
# Build Tools: 27.0.3
# SDK Version v26.0.2
# NDK r17b
# Platforms: 26, 27

FROM openjdk:8-jdk

MAINTAINER trion development GmbH "info@trion.de"
LABEL maintainer trion development GmbH "info@trion.de"

#note: build-tools version in path must be synced to tools installed in pkg.txt
ENV SDK_TOOLS_VERSION="3859397" NDK_VERSION=r17b ANDROID_HOME="/sdk" \
  ANDROID_NDK_HOME="/ndk" PATH="$PATH:/sdk/tools" \
  PATH="$PATH:/sdk/build-tools/27.0.3/" \
   LANG=en_US.UTF-8

# install necessary packages
RUN apt-get update && apt-get install -qqy --no-install-recommends \
    apt-utils \
    locales \
    libc6-i386 \
    lib32stdc++6 \
    lib32gcc1 \
    lib32ncurses5 \
    lib32z1 \
    unzip \
    curl \
    cmake \
    lldb \
    git \
    build-essential \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

COPY pkg.txt /

# Install repo tool version 1.23 (https://source.android.com/setup/build/downloading#installing-repo)
# required tools, accept license
RUN curl -s https://storage.googleapis.com/git-repo-downloads/repo > /tmp/repo && \
    echo "d06f33115aea44e583c8669375b35aad397176a411de3461897444d247b6c220  /tmp/repo" > /tmp/repo.sha265 && \
    sha256sum -c /tmp/repo.sha265 && \
    rm /tmp/repo.sha265 && \
    mv /tmp/repo /usr/bin/repo && \
    chmod a+x /usr/bin/repo && \
    curl -s https://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip > /tools.zip && \
    unzip /tools.zip -d /sdk && \
    rm -v /tools.zip && \
    mv /pkg.txt /sdk && \
    mkdir -p /root/.android && touch /root/.android/repositories.cfg && \
    yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

# Update sdk packages and install required packages
RUN ${ANDROID_HOME}/tools/bin/sdkmanager --update && \
    while read -r pkg; do PKGS="${PKGS}${pkg} "; done < /sdk/pkg.txt && \
      ${ANDROID_HOME}/tools/bin/sdkmanager ${PKGS}

#install NDK
RUN mkdir /tmp/android-ndk && \
    cd /tmp/android-ndk && \
    curl -s -O https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip && \
    unzip -q android-ndk-${NDK_VERSION}-linux-x86_64.zip && \
    mv ./android-ndk-${NDK_VERSION} ${ANDROID_NDK_HOME} && \
    cd ${ANDROID_NDK_HOME} && \
    rm -rf /tmp/android-ndk
