# docker-android-build
Build Android applications in Docker

This is useful for build systems like travis or gitlab that require a container with installed tools.


Example build for gitlab-ci

```
stages:
- release

variables:
  GRADLE_OPTS: "-Dorg.gradle.daemon=false"

before_script:
- export GRADLE_USER_HOME=$(pwd)/.gradle
- chmod +x ./gradlew

cache:
  key: ${CI_PROJECT_ID}
  paths:
  - .gradle/

build:
    stage: release
    image: trion/android-build
    tags:
      - x86_64
    script:
        - ./gradlew clean assembleRelease
    artifacts:
        expire_in: 2 weeks
        paths:
            - app/build/outputs/apk/*.apk

```
