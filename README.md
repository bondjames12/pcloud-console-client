<h1 align="center">
    pCloud Console Client
</h1>
<p align="center">A simple console client for <a href="https://pcloud.com">pCloud</a> cloud storage.</p>
<p align="center">
    <a href="https://github.com/sergeyklay/pcloud-console-client/actions?workflow=CI">
        <img src="https://github.com/sergeyklay/pcloud-console-client/actions/workflows/ci.yml/badge.svg?branch=master" alt="CI Status" />
    </a>
</p>

## Project Information

pCloud Console Client was forked from
[the project](https://github.com/pcloudcom/console-client) initially written by
pCloud Ltd to breathe new life into it and set a more dynamic pace of
development. The maintainer of this fork isn't affiliated to pCloud so this
project is as good or as bad as it gets. If you'd like to contribute to pCloud
Console Client you're most welcome!

## Documentation

- [Getting Started](https://github.com/sergeyklay/pcloud-console-client/blob/master/docs/GettingStarted.md)
- [Usage](https://github.com/sergeyklay/pcloud-console-client/blob/master/docs/Usage.md)

Super fast Compile and Install
```sh
sudo apt install \
    cmake \
    fuse \
    g++ \
    gcc \
    git \
    libfuse-dev \
    libmbedtls-dev \
    libpthread-stubs0-dev \
    libsqlite3-dev \
    make \
    pkg-config \
    zlib1g-dev
git clone https://github.com/bondjames12/pcloud-console-client.git
cd pcloud-console-client
git submodule init
git submodule update
mkdir build

cd build

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DPCLOUD_WITH_SYSTEMD=ON \
  -DPCLOUD_SYSTEMD_SERVICES_INSTALL_DIR==~/.config/systemd/user \
  ..


cmake --build . --config Release
sudo cmake --build . --target install

pcloudcc -u <email> -p -s
systemctl enable pcloudcc@<email>.service
systemctl start pcloudcc@<email>.service
systemctl status pcloudcc@<email>.service
```
## License

pCloud Console Client is open source software licensed under the
BSD 3-Clause License. See the LICENSE file for more information.
