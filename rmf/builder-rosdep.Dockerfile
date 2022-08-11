ARG BASE_REGISTRY="docker.io"
ARG ROS_DISTRO="humble"

FROM $BASE_REGISTRY/ros:$ROS_DISTRO

RUN apt update -y
RUN apt install curl git wget -y

RUN rm /etc/apt/sources.list.d/ros2-latest.list
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -

RUN apt update && apt upgrade -y
RUN apt install \
    python3-pip cmake python3-colcon-common-extensions -y

# download cyclonedds and use clang for humble
RUN if [ "$ROS_DISTRO" = "humble" ]; then \
        apt install ros-humble-rmw-cyclonedds-cpp -y && \
        apt install clang-13 lldb-13 lld-13 -y && \
        update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-13 100; \
    fi
