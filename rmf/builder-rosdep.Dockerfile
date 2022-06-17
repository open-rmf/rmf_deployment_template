FROM ros:humble

RUN apt update -y
RUN apt install curl git wget -y

RUN rm /etc/apt/sources.list.d/ros2-latest.list
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update && apt upgrade -y
RUN apt install \
    python3-pip python3-vcstool cmake python3-colcon-common-extensions -y

RUN apt install clang-13 lldb-13 lld-13 -y
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-13 100

RUN apt install ros-humble-rmw-cyclonedds-cpp -y
