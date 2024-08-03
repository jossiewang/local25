## AMD64 architecture ##
FROM osrf/ros:noetic-desktop-full-focal

LABEL org.opencontainers.image.authors="jossiew621@gapp.nthu.edu.tw"
LABEL shell=bash

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV SHELL=/bin/bash
ENV TERM=xterm-256color

# Create the user
# add user with default bash
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

## pkgs installation
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo vim curl wget tmux htop git git-extras \
    gnupg2 net-tools locales \
    x11-apps apt-utils \
    ## ros dependencies
    libsdl-image1.2-dev \
    libsdl-dev \
    ros-noetic-tf2-sensor-msgs \
    ros-noetic-move-base-msgs \
    ros-noetic-mbf-costmap-core \
    ros-noetic-mbf-msgs \
    libsuitesparse-dev \
    ros-noetic-libg2o \
    ros-noetic-teleop-twist-keyboard \
    ros-noetic-costmap-converter \
    ros-noetic-robot-localization \
    ros-noetic-imu-tools \
    libusb-1.0-0 libusb-1.0-0-dev -y \
    && rm -rf /var/lib/apt/lists/*d

## set time(Taipei) and language
RUN echo "en_US.UTF-8 UTF-8" > /etc/local.gen && locale-gen en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tzdata
RUN TZ=Asia/Taipei && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata 

### install YDLiDAR SDK
COPY .YDLidar-SDK /home/YDLidar-SDK
WORKDIR /home/YDLidar-SDK
RUN mkdir -p build && rm -rf build/*
WORKDIR /home/YDLidar-SDK/build
RUN cmake .. && \
    make && \
    sudo make install

USER $USERNAME
ARG WORKSPACE_DIR=/home/$USERNAME/summer2024_ws
WORKDIR ${WORKSPACE_DIR}/src

WORKDIR ${WORKSPACE_DIR}/src/ydlidar_ros_driver
COPY ydlidar_ros_driver ${WORKSPACE_DIR}/src/ydlidar_ros_driver

WORKDIR ${WORKSPACE_DIR}/src
RUN git clone https://github.com/tysik/obstacle_detector.git

# Update package lists and install dependencies
RUN sudo apt-get update && \
    rosdep update && \
    rosdep install --from-paths . --ignore-src -r -y

# Build the workspace
RUN cd .. && \
    /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash; catkin_make' && \
    echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

# Clean up
RUN sudo apt-get autoremove -y && \
    sudo apt-get autoclean -y && \
    sudo rm -rf /var/lib/apt/lists/*

USER ${USERNAME}
COPY .bashrc /home/$USERNAME/.bashrc.conf
COPY install.sh /home/$USERNAME/install.sh
RUN cat /home/$USERNAME/.bashrc.conf >> /home/$USERNAME/.bashrc

SHELL ["/bin/bash", "-c"]
RUN cd /home/$USERNAME/summer2024_ws && source /opt/ros/noetic/setup.bash && catkin_make

CMD ["/bin/bash"]