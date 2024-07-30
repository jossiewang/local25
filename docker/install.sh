# Set user name as argument
USER="main"

cd /home/$USER/main_ws && source devel/setup.bash

# sudo apt update
# rosdep update
# rosdep install --from-paths src --ignore-src -r -y
catkin_make --only-pkg-with-deps navigation_msgs startup_msgs
source devel/setup.bash
catkin_make -DCATKIN_WHITELIST_PACKAGES=""