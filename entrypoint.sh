#!/bin/sh -x
export PATH=$ANDROID_HOME/emulator/:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin/:$PATH:$HOME:

#if not emulator, exec / else launch and wait for emulator

echo n | $ANDROID_HOME/tools/bin/avdmanager --verbose create avd \
    --force -k "system-images;${TARGET};${TAG};${ABI}" \
    -n ${NAME} -b ${ABI} -g ${TAG}

mkdir -p $HOME/.android/avd/Docker.avd
(
  # Enable keyboard support in QEMU (for VNC)
  echo 'hw.keyboard = true';
) >> $HOME/.android/avd/Docker.avd/config.ini

export DISPLAY=:0
emulator -avd Docker -no-skin -no-audio -no-window &

#wait for boot
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'

#unlock screen
adb shell wm dismiss-keyguard
sleep 5

exec $*
