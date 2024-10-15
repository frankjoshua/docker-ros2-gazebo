FROM frankjoshua/ros2

# ** [Optional] Uncomment this section to install additional packages. **
#
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
   && apt-get -y install --no-install-recommends  ros-${ROS_DISTRO}-gz-* \
   \
   # Clean up
   && apt-get autoremove -y \
   && apt-get clean -y \
   && rm -rf /var/lib/apt/lists/*

# Install necessary tools
RUN apt-get update && apt-get install -y \
    curl \
    lsb-release \
    gnupg \
 && rm -rf /var/lib/apt/lists/*

# Add Gazebo's official GPG key
RUN curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg

# Add the Gazebo APT repository
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
> /etc/apt/sources.list.d/gazebo-stable.list

# Update package lists and install Gazebo Harmonic
RUN apt-get update && apt-get install -y \
    gz-harmonic \
 && rm -rf /var/lib/apt/lists/*

# Set Gazebo environment variables
ENV GAZEBO_MODEL_PATH=/usr/share/gazebo-11/models:${GAZEBO_MODEL_PATH}
ENV GAZEBO_RESOURCE_PATH=/usr/share/gazebo-11:${GAZEBO_RESOURCE_PATH}
ENV GAZEBO_PLUGIN_PATH=/usr/lib/x86_64-linux-gnu/gazebo-11/plugins:${GAZEBO_PLUGIN_PATH}
ENV GAZEBO_SYSTEM_PLUGIN_PATH=/usr/lib/x86_64-linux-gnu/gazebo-11/plugins:${GAZEBO_SYSTEM_PLUGIN_PATH}

ENV DEBIAN_FRONTEND=dialog

USER root
WORKDIR /root
COPY ros2_ws ros2_ws
RUN cd ros2_ws && . install/setup.sh && colcon build

COPY ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod +x /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD [ "/bin/bash", "-i", "-c", "gz sim" ]
