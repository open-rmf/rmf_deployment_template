ARG BASE_REGISTRY="docker.io"
ARG ROS_DISTRO="humble"

FROM $BASE_REGISTRY/ros:$ROS_DISTRO

RUN apt update && apt install -y \
  cmake \
  curl \
  python3-pip \
  git \
  wget \
  && rm -rf /var/lib/apt/lists/*

RUN rm /etc/apt/sources.list.d/ros2-latest.list
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -

RUN apt update && apt install -y \
  python3-colcon-common-extensions \
  && apt-get upgrade -y \
  && rm -rf /var/lib/apt/lists/*

# download cyclonedds and use clang for humble
RUN if [ "$ROS_DISTRO" = "humble" ]; then \
      apt update && apt install -y \
        clang-13 \
        lldb-13 \
        lld-13 \
        ros-humble-rmw-cyclonedds-cpp \
        && rm -rf /var/lib/apt/lists/* \
      && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-13 100; \
    fi
