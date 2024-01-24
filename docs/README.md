# TestForDocs
One repository for test of docsify  哈哈哈

- [访问不到README.md文件](https://cloud.tencent.com/developer/article/1855878?areaSource=102001.12&traceId=Aj1sJkLVb5XRVAqU_zMa1)

> docsify的搜索是缓存在网页的localStorage里

<u>不知道为啥gitpage不会清除缓存</u>

- 所以需要在控制台输入localStorage.clear()去手动清除上次的缓存
- 也可能是因为更换了仓库，gitpage里并没有更新缓存

## Git Action

> 算是一段脚本，当触发push或者其他事件时执行

`uses: actions/checkout@v3` 是 GitHub Actions 中的一个步骤，它用于将代码仓库（repository）的内容**检出**到工作目录中，以便在工作流程中进行后续的操作。

> 在软件开发中，“检出”通常指从版本控制系统（如 Git）中获取代码副本，并将其下载到本地工作环境，以便进行开发、构建和测试等操作。这是一个常见的版本控制工作流程步骤。

使用现成的代码的话

`厂家/action名@版本`

```yml
name: learn-github-actions				# action名称，如果没有则按照yml文件名来命名
run-name: ${{ github.actor }} is learning GitHub Actions  # 执行过程的名称描述   github.actor 执行者名称 
on:
  push:    # 当main分支有push事件时执行
    branches: [ "main" ]
  workflow_dispatch:  # 允许手动操作

env:    # 环境变量
  AZURE_WEBAPP_NAME: your-app-name    # set this to your application's name
  AZURE_WEBAPP_PACKAGE_PATH: '.'      # set this to the path to your web app project, defaults to the repository root
  NODE_VERSION: '14.x'                # set this to the node version to use

permissions:
  contents: read

jobs:              # 当事件触发时执行的工作内容
  build:			# build(其中一个事件的名称，自己起名) 事件
    runs-on: ubuntu-latest		# 运行在最新的ubuntu系统中
    steps:       # 执行详细步骤内容  是数组，以'-'和空格间距为区分
    - uses: actions/checkout@v3   # 检查仓库

    - name: Set up Node.js		# 为其中的步骤起名
      uses: actions/setup-node@v3  # 使用现成的action去创建nodejs环境  @v3 是该动作的版本。
      with:			# 定义使用动作时的参数	使用了环境变量 NODE_VERSION 的值，该变量在前面的配置文件中定义。
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'	# 启用 npm 缓存。这可以显著减少构建时间，因为缓存了 npm 的依赖项，避免了每次都重新下载。

    - name: npm install, build, and test
      run: |   # |：这是 YAML 语法中的一种方式，称为折叠块标记，它允许在一个标量（scalar）内保留换行符。在这里，| 表示在该步骤中执行的是多行脚本，而不是单个命令。
        npm install
        npm run build --if-present
        npm run test --if-present

    - name: Upload artifact for deployment job
      uses: actions/upload-artifact@v3
      with:
        name: node-app
        path: .

  deploy:
    permissions:
      contents: none
    runs-on: ubuntu-latest
    needs: build  #表示在执行部署任务之前需要先完成build事件任务。
    environment:  #定义部署的环境名称和 URL。
      name: 'Development'
      url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}

    steps:
    - name: Download artifact from build job
      uses: actions/download-artifact@v3
      with:
        name: node-app

    - name: 'Deploy to Azure WebApp'
      id: deploy-to-webapp
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
        package: ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}
```

### 连接服务器

> step里步骤要加注释的话只能在行末注释，不可换行注释

```shell
# 链接服务器并执行命令的workflow

name: SSH-Connect
run-name: update the repository of server

# 当有push和pr在main分支时，执行
on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

  # 允许手动执行
  workflow_dispatch:

# 工作流
jobs:
  # 任务名
  update-server:
    # 需要的运行环境
    runs-on: ubuntu-latest

    # 任务流程
    steps:
      # 检出仓库
      - uses: actions/checkout@v3 # 拉取更新repository
      - name: pull repository
        uses: garygrossgarten/github-action-ssh@release # ssh链接服务器
        with: 	# 参数配置以及执行的命令
          command: |
            cd /www/wwwroot/heachy.com/TestForDocsify
            git pull
          host: ${{ secrets.HOST }}
          username: root
          privateKey: ${{ secrets.PRIVATE_KEY}}

```

## Environment & Repository secrets 

```yml
name: Some task

on:
  push:
    branches:
      - main

jobs:
  prod-task:
    runs-on: ubuntu-latest
    environment: production
    steps:
      # 使用的是production环境下的secrets
      - name: Run node build process
        run: "NODE_ENV=${{ env.NODE_ENV }} npm run build"
  dev-task:
    runs-on: ubuntu-latest
    environment: development
    steps:
      # 使用的是development环境下的secrets
      - name: Run node build process
        run: "NODE_ENV=${{ env.NODE_ENV }} npm run build"
  task:
    runs-on: ubuntu-latest
    steps:
      # 使用的是仓库的secrets
      - name: Run node build process
        run: "NODE_ENV=${{ env.NODE_ENV }} npm run build"
```



## SSH秘钥

生成 SSH 密钥对通常可以使用 `ssh-keygen` 工具。以下是在 Unix/Linux 或 macOS 系统上生成 SSH 密钥对的简单步骤：

1. 打开终端

2. 在终端中运行以下命令：

   ```shell
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

   上述命令中，`your_email@example.com` 替换为你的 GitHub 账户关联的电子邮件地址。这个地址将用于标识你的 SSH 密钥。

3. 系统会提示你选择密钥文件的保存位置，默认是 `~/.ssh/id_rsa`。如果你希望选择不同的位置，可以输入其他路径。

4. 系统还会询问是否要设置密码保护密钥。这是可选的，如果设置密码，每次使用密钥时都需要输入密码。

5. 执行完成后，你将在指定的目录中看到两个文件：`id_rsa`（私钥）和 `id_rsa.pub`（公钥）。

   - `id_rsa`：私钥文件，用于身份验证。**请注意：私钥是非常敏感的信息，不要分享或泄露。**
   - `id_rsa.pub`：公钥文件，可以分享给其他人或用于身份验证。

将生成的公钥内容添加到 GitHub 中，作为一个密钥，可以在 GitHub 账户的设置中的 SSH 和 GPG keys 页面中完成。私钥则需妥善保存在你的工作站，用于在 GitHub Actions 中进行身份验证。在 GitHub Actions Workflow 文件中，你可以通过将私钥添加为 secret 来使用。

**注意：** 在生成 SSH 密钥对时，请确保私钥的保密性。私钥泄露可能导致未经授权的访问。

> 执行完后记得执行一句‘cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys’,(不知道要不要哈哈)

