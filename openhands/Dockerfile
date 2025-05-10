FROM docker.all-hands.dev/all-hands-ai/runtime:0.37-nikolaik

RUN curl -fL https://github.com/adoptium/temurin24-binaries/releases/download/jdk-24.0.1%2B9/OpenJDK24U-jdk_x64_linux_hotspot_24.0.1_9.tar.gz -o /tmp/jdk24.tar.gz && \
    mkdir -p /opt/jdk && \
    tar -xzf /tmp/jdk24.tar.gz --strip-components=1 -C /opt/jdk && \
    rm /tmp/jdk24.tar.gz

RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    curl -L https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -o /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d /opt/android-sdk/cmdline-tools && \
    mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

ENV JAVA_HOME=/opt/jdk ANDROID_SDK_ROOT=/opt/android-sdk

RUN yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses
