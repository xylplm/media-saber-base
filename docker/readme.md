## 特点

- 基于 alpine 实现，镜像体积小；

- 镜像层数少；

- 支持 amd64/arm64 架构；

- 重启即可更新程序，如果依赖有变化，会自动尝试重新安装依赖，若依赖自动安装不成功，会提示更新镜像；

- 可以以非 root 用户执行任务，降低程序权限和潜在风险；

- 可以设置文件掩码权限 umask。

## 创建

**注意**

- 媒体目录的设置必须符合 [配置说明](https://github.com/xylplm/media-saber#%E9%85%8D%E7%BD%AE) 的要求。

- umask 含义详见：http://www.01happy.com/linux-umask-analyze 。

- 创建后请根据 [配置说明](https://github.com/xylplm/media-saber#%E9%85%8D%E7%BD%AE) 及该文件本身的注释，修改`config/config.yaml`，修改好后再重启容器，最后访问`http://<ip>:<web_port>`。

**docker cli**

```
docker run -d \
    --name media-saber \
    --hostname media-saber \
    -p 3000:3000   `# 默认的webui控制端口` \
    -v $(pwd)/config:/config  `# 冒号左边请修改为你想在主机上保存配置文件的路径` \
    -v /你的媒体目录:/你想设置的容器内能见到的目录    `# 媒体目录，多个目录需要分别映射进来` \
    -e PUID=0     `# 想切换为哪个用户来运行程序，该用户的uid，详见下方说明` \
    -e PGID=0     `# 想切换为哪个用户来运行程序，该用户的gid，详见下方说明` \
    -e UMASK=000  `# 掩码权限，默认000，可以考虑设置为022` \
    xylplm/media-saber
```

**docker-compose**

新建`docker-compose.yaml`文件如下，并以命令`docker-compose up -d`启动。

```
version: "3"
services:
  media-saber:
    image: xylplm/media-saber:latest
    ports:
      - 3000:3000        # 默认的webui控制端口
    volumes:
      - ./config:/config   # 冒号左边请修改为你想保存配置的路径
      - /你的媒体目录:/你想设置的容器内能见到的目录   # 媒体目录，多个目录需要分别映射进来，需要满足配置文件说明中的要求
    environment:
      - PUID=0    # 想切换为哪个用户来运行程序，该用户的uid
      - PGID=0    # 想切换为哪个用户来运行程序，该用户的gid
      - UMASK=000 # 掩码权限，默认000，可以考虑设置为022
    restart: always
    network_mode: bridge
    hostname: media-saber
    container_name: media-saber
```

## 关于 PUID/PGID 的说明

- 如在使用诸如 emby、jellyfin、plex、qbittorrent、transmission、deluge、jackett、sonarr、radarr 等等的 docker 镜像，请保证创建本容器时的 PUID/PGID 和它们一样。

- 在 docker 宿主上，登陆媒体文件所有者的这个用户，然后分别输入`id -u`和`id -g`可获取到 uid 和 gid，分别设置为 PUID 和 PGID 即可。

- `PUID=0` `PGID=0`指 root 用户，它拥有最高权限，若你的媒体文件的所有者不是 root，不建议设置为`PUID=0` `PGID=0`。

## 如果要硬连接如何映射

参考下图，由 imogel@telegram 制作。

![如何映射](volume.png)
