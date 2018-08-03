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
emulator -avd Docker -no-skin -no-audio -no-window -no-boot-anim &

#wait for boot
echo "Waiting for device.."
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'

#disable animations
adb shell settings put global window_animation_scale 0.0
adb shell settings put global transition_animation_scale 0.0
adb shell settings put global animator_duration_scale 0.0

#unlock screen
echo "Unlocking screen..."
adb shell wm dismiss-keyguard
sleep 5

exec $*
