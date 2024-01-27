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

`{owner}/{repo}@{ref}`   使用公共操作

`{owner}/{repo}/{path}@{ref}`  在子目录中使用公共操作

`./path/to/dir`   使用与工作流程相同的存储库中的操作     下面的inputs名次解释运用的就是这种方法

`docker://{image}:{tag}`   使用 Docker Hub 操作

`docker://{host}/{image}:{tag}`  使用 GitHub Packages Container 注册表

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

```yaml
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

### 名词解释

[触发事件详细链接](https://docs.github.com/zh/actions/using-workflows/events-that-trigger-workflows)

#### args

在 GitHub Actions 中，`jobs.<job_id>.steps[*].with.args` 中的 `args` 是用于指定执行步骤时传递给 Action 或脚本的参数。这通常用于定制步骤的行为或将特定的参数传递给脚本或命令。

具体而言，这个 `args` 配置是一个数组，包含了传递给执行步骤的命令或脚本的参数。它可以用于在执行步骤时动态设置参数值。下面是一个简单的示例：

```yaml
jobs:
  example-job:
    runs-on: ubuntu-latest

    steps:
    - name: Run a script with arguments
      run: |
        echo "This is a script"
        echo "Arguments: $1, $2"
      shell: bash
      with:
        args:
          - "arg1"
          - "arg2"
```

在上面的示例中，`with.args` 包含了传递给脚本的两个参数 `"arg1"` 和 `"arg2"`。这些参数可以在脚本中使用 `$1` 和 `$2` 进行访问。

你可以根据实际需求在 `args` 中添加或删除参数，使其适应你执行的脚本或命令。

#### matrix

```yaml
jobs:
  example_matrix:
    strategy:
      matrix:
        version: [10, 12, 14]
    steps:
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.version }}
```

是的，这个配置使用了 GitHub Actions 中的矩阵策略，通过 `strategy` 和 `matrix` 定义了一组需要执行的作业（jobs）。在这个例子中，作业名为 `example_matrix`。

- `matrix` 定义了一个版本矩阵，其中 `version: [10, 12, 14]` 表示要执行的 Node.js 版本是 10、12 和 14。这意味着这个作业将在每个指定的 Node.js 版本上执行。
- `uses: actions/setup-node@v3` 表示使用 GitHub 提供的官方 Action `setup-node` 来设置 Node.js 环境。通过 `with` 部分的 `node-version: ${{ matrix.version }}`，在每次作业执行时，都会选择矩阵中定义的一个版本。

因此，这个配置会在 Node.js 版本 10、12 和 14 上分别执行相同的作业。

#### service


在 GitHub Actions 中，`services` 是一种用于在作业运行期间提供服务的机制。通过定义 `services`，你可以在需要的时候启动并运行某个服务，供其他作业或步骤使用。

以下是一个使用服务的简单示例：

```yaml
jobs:
  example:
    runs-on: ubuntu-latest
    services:
      myservice:
        image: myservice-image:latest
        ports:
          - 8080:80
    steps:
      - name: Run tests
        run: curl http://myservice:80
```

在这个例子中：

- `services` 定义了一个名为 `myservice` 的服务，使用了镜像 `myservice-image:latest`，并将容器的端口映射到主机的 `8080` 端口。
- 在作业的 `steps` 中，可以使用 `myservice` 来引用这个服务。在这里，通过 `curl http://myservice:80` 来测试服务是否正常运行。

通过这种方式，你可以方便地在 GitHub Actions 中使用服务，例如数据库、缓存等，以模拟真实环境中的依赖。

#### job-outputs

```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    # Map a step output to a job output
    outputs:
      output1: ${{ steps.step1.outputs.test }}
      output2: ${{ steps.step2.outputs.test }}
    steps:
      - id: step1
        run: echo "test=hello" >> "$GITHUB_OUTPUT"
      - id: step2
        run: echo "test=world" >> "$GITHUB_OUTPUT"
  job2:
    runs-on: ubuntu-latest
    needs: job1
    steps:
      - env:
          OUTPUT1: ${{needs.job1.outputs.output1}}
          OUTPUT2: ${{needs.job1.outputs.output2}}
        run: echo "$OUTPUT1 $OUTPUT2"
```

这个 GitHub Actions 的工作流包含两个作业（jobs）：`job1` 和 `job2`。

1. **job1**：
   - 运行在 `ubuntu-latest` 系统上。
   - 定义了两个输出参数：`output1` 和 `output2`。
   - 包含两个步骤（steps）：
     - `step1`：运行一个命令，向 `$GITHUB_OUTPUT` 文件中写入 "test=hello"。
     - `step2`：运行一个命令，向 `$GITHUB_OUTPUT` 文件中写入 "test=world"。
2. **job2**：
   - 同样运行在 `ubuntu-latest` 系统上。
   - 通过 `needs` 指定依赖关系，需要等待 `job1` 执行完成后再执行。
   - 包含一个步骤：
     - 设置了两个环境变量 `OUTPUT1` 和 `OUTPUT2`，这两个变量的值分别来自于 `job1` 的输出参数 `output1` 和 `output2`。
     - 运行一个命令，输出环境变量的值。

这个工作流的主要目的是通过 `outputs` 将 `job1` 的输出参数传递给 `job2`，并在 `job2` 中使用这些参数。最终，`job2` 的输出是 "hello world"，因为它是由 `job1` 的两个步骤输出拼接而成的。

#### concurrency

在 GitHub Actions 中，`concurrency` 是一个用于控制并发性的属性。它允许你限制并发运行同一 repository 中同一个 workflow 的 job 的数量。这对于资源管理和避免冲突非常有用。

使用 `concurrency` 可以确保同一时间运行的 job 实例数量不会超过指定的值。这对于一些需要独占性资源的场景很有帮助，例如数据库或其他共享资源，以避免冲突和竞争条件。

下面是一个使用 `concurrency` 的示例：

```yaml
name: My Workflow

on:
  push:
    branches:
      - main

jobs:
  my-job:
    runs-on: ubuntu-latest
    concurrency:
      group: ${{ github.workflow }}-${{ github.actor }}
      cancel-in-progress: true
    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Run my task
      run: echo "Hello, world!"
```

在这个示例中，`concurrency` 的配置如下：

- `group`: 指定了一个组名，用于标识并发执行的作业。`${{ github.workflow }}` 和 `${{ github.actor }}` 是 GitHub Actions 提供的预定义变量，分别表示 workflow 名称和执行 action 的用户（actor）。
- `cancel-in-progress`: 设置为 `true` 表示如果有新的作业实例请求并发执行，已经在运行的作业实例会被取消。如果设置为 `false`，则新的请求会等待，直到之前的作业实例完成。

这样的设置可以确保在同一时间只有一个执行中的 job 实例，并且如果有新的 push 事件触发了相同的 workflow，它会取消之前正在执行的作业实例。



取消之前正在执行的作业实例通常是出于资源管理和避免冲突的考虑。有几个常见的原因：

1. **资源限制：** 有些作业可能需要访问共享资源，比如数据库、文件系统或其他有限的服务。在某些情况下，如果有多个并发作业实例同时访问这些资源，可能会导致冲突或资源争夺，影响作业的正确执行。
2. **状态一致性：** 如果一个作业实例修改了一些状态，而另一个作业实例依赖于这个状态，那么同时运行多个实例可能导致状态不一致。通过取消之前的实例，可以确保在有状态的场景下，只有一个实例在运行。
3. **避免重复操作：** 在某些情况下，一个作业可能执行一些对系统状态有影响的操作，比如部署到生产环境。如果有新的提交触发了相同的部署工作，取消之前的实例可以确保不会出现并发执行相同操作的情况，从而避免不必要的重复操作。

需要注意的是，取消之前的作业实例可能会导致正在执行的任务被终止。因此，在使用 `cancel-in-progress: true` 时，需要确保你的作业可以安全地中止和终止，并且没有会导致不一致状态或数据损坏的风险。

#### inputs

在 GitHub Actions 中，如果一个工作流（workflow）有 `inputs`，那么你可以在引用它的地方通过 `with` 来传递这些输入参数。下面是一个示例：

假设你有一个名为 `test-action.yml` 的工作流，其中定义了一个 `input` 参数：

```yaml
name: Test Action

on:
  push:
    branches:
      - main

inputs:
  message:
    description: 'A custom message'
    required: true
    default: 'Hello, World!'

jobs:
  run-test-action:
    runs-on: ubuntu-latest

    steps:
    - name: Display Message
      run: echo "${{ inputs.message }}"
```

然后，你的 `test-action2.yml` 文件可以这样使用：

```yaml
name: Test Action 2

on:
  push:
    branches:
      - main

jobs:
  run-test-action2:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Repository
      uses: actions/checkout@v2

    - name: Run Test Action 1
      uses: ./.github/workflows/test-action.yml
      with:
        message: 'Custom message for Test Action 1'
```

在这个例子中，`test-action2.yml` 引用了 `test-action.yml` 并传递了一个自定义消息作为 `message` 输入参数。你需要根据 `test-action.yml` 的输入参数定义来填写 `with` 字段。

#### outputs

在 GitHub Actions 中，`outputs` 是 action 用于向 workflow 提供输出结果的一种机制。当一个 action 执行完毕后，可以通过 `outputs` 将一些信息传递给 workflow，以便在后续的步骤或 jobs 中使用。

以下是一个示例，展示如何在 action 中使用 `outputs`：

```yaml
name: My Workflow

on:
  push:
    branches:
      - main

jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
    - name: Run My Action
      id: my-action
      uses: my-org/my-action
      with:
        myInput: ${{ secrets.MY_SECRET }}

    - name: Use Action Output
      run: echo "The result is ${{ steps.my-action.outputs.myOutput }}"
```

在这个例子中，`my-action` 这个 action 在执行完毕后，通过 `outputs` 提供了一个名为 `myOutput` 的输出结果。在 workflow 的后续步骤中，可以通过 `${{ steps.my-action.outputs.myOutput }}` 来获取这个输出结果的值。

在 action 的定义中，可以这样定义 `outputs`：

```yaml
name: 'My Action'

outputs:
  myOutput:
    description: 'A description of my output'
```

在 action 的执行中，通过设置输出结果的值，可以将信息传递给 workflow 中的其他步骤。这使得不同步骤之间可以共享数据。

- 就是在`step`中使用其他action需要传参时，使用`with`，对应变量名并赋值
- 使用的其他action里要在inputs指明需要那些变量并命名，输出outputs里面也是要对要输出的数据进行命名
- 对执行完其他action后的outputs里数据进行调用，指明哪步调用的action到那个变量名`steps.‘step的id或name.outputs’.‘数据名’`

#### github.xxxx(ref...)

|      属性名称       |   类型   | 说明                                                         |
| :-----------------: | :------: | ------------------------------------------------------------ |
|    `github.ref`     | `string` | 触发工作流运行的分支或标记的格式完整的参考。 对于 `push` 触发的工作流，这是推送的分支或标记参考。 对于 `pull_request` 触发的工作流，这是拉取请求合并分支。 对于 `release` 触发的工作流，这是创建的发布标记。 对于其他触发器，这是触发工作流运行的分支或标记参考。 此变量仅在分支或标记可用于事件类型时才会设置。 给定的参考格式完整，这意味着对于分支，其格式为 `refs/heads/<branch_name>`，对于拉取请求，其格式为 `refs/pull/<pr_number>/merge`，对于标签，其格式为 `refs/tags/<tag_name>`。 例如，`refs/heads/feature-branch-1`。 |
|   `github.actor`    | `string` | 触发初始工作流运行的用户的用户名。 如果工作流运行是重新运行，则此值可能与 `github.triggering_actor` 不同。 即使启动重新运行的参与者 (`github.triggering_actor`) 具有不同的权限，任何工作流重新运行都将使用 `github.actor` 的权限。 |
| `github.repository` | `string` | 所有者和存储库名称。 例如，`octocat/Hello-World`。           |

[上下文变量原文链接](https://docs.github.com/zh/actions/learn-github-actions/contexts#github-context)

#### Glob Pattern

"Glob"是一种模式，类似于在命令行中输入`ls *.js`，或是在`.gitignore`文件中写`build/*`。

在解析路径模式时，大括号内使用逗号进行分隔，分隔部分可以包含`/`，所以`a{/b/c,bcd}`会被展开为`a/b/c`和`abcd`。

在匹配路径使用时，以下字符有一些特殊的作用：

- `*`：匹配单路径下的 0 个或 多个 字符串。
- `?`：匹配一个字符串。
- `[...]`：匹配指定范围内的字符串，类似于正则表达式中的`[]`。如果`[]`中的第一个字符串是`!`或者`^`，则匹配不在范围内的任意字符串。
- `!(pattern|pattern|pattern)`：匹配与提供模式中不匹配的内容。
- `?(pattern|pattern|pattern)`：匹配提供模式中的 0次 或 1次。
- `+(pattern|pattern|pattern)`：匹配提供模式中的 1次 或 多次。
- `*(a|b|c)`：匹配提供模式中的 0次 或 多次。
- `@(pattern|pat*|pat?erN)`：匹配与提供模式中完全匹配的。
- `**`：和`*`一样，可以匹配路径中的 0个 或 多个，而且`**`可以匹配当前目录和子目录。但无法抓去符号链接的目录。

#### schedule

通过 `schedule` 事件，可以在计划的时间触发工作流。

可使用 [POSIX cron 语法](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/crontab.html#tag_20_25_07)将工作流计划为在特定的 UTC 时间运行。 预定的工作流程在默认或基础分支的最新提交上运行。 您可以运行预定工作流程的最短间隔是每 5 分钟一次。

此示例在每天 5:30 和 17:30 UTC 触发工作流程：

```yaml
on:
  schedule:
    # * is a special character in YAML so you have to quote this string
    - cron:  '30 5,17 * * *'
```

多个 `schedule` 事件可以触发单个工作流。 你可以通过 `github.event.schedule` 上下文访问触发工作流的计划事件。 此示例触发工作流在每周一至周四 5:30 UTC 运行，但在周一和周三跳过 `Not on Monday or Wednesday` 步骤。

```yaml
on:
  schedule:
    - cron: '30 5 * * 1,3'
    - cron: '30 5 * * 2,4'

jobs:
  test_schedule:
    runs-on: ubuntu-latest
    steps:
      - name: Not on Monday or Wednesday
        if: github.event.schedule != '30 5 * * 1,3'
        run: echo "This step will be skipped on Monday and Wednesday"
      - name: Every time
        run: echo "This step will always run"
```

计划任务语法有五个字段，中间用空格分隔，每个字段代表一个时间单位。

```text
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of the month (1 - 31)
│ │ │ ┌───────────── month (1 - 12 or JAN-DEC)
│ │ │ │ ┌───────────── day of the week (0 - 6 or SUN-SAT)
│ │ │ │ │
│ │ │ │ │
│ │ │ │ │
* * * * *
```

你可在这五个字段中使用以下运算符：

| 运算符 | 说明         | 示例                                                         |
| :----- | :----------- | :----------------------------------------------------------- |
| *      | 任何值       | `15 * * * *` 在每天每小时的每个第 15 分钟运行。              |
| ,      | 值列表分隔符 | `2,10 4,5 * * *` 在每天第 4 和第 5 小时的第 2 和第 10 分钟运行。 |
| -      | 值的范围     | `30 4-6 * * *` 在第 4、5 和 6 小时的第 30 分钟运行。         |
| /      | 步骤值       | `20/15 * * * *` 在第 20 分钟到第 59 分钟每隔 15 分钟运行一次（第 20、35 和 50 分钟）。 |

注意：GitHub Actions 不支持非标准语法 `@yearly`、`@monthly`、`@weekly`、`@daily`、`@hourly` 和 `@reboot`。

#### Bash-Shell

"使用 Bash 作为 shell" 表示在执行脚本和命令时，将使用 Bash（Bourne Again SHell）作为命令行解释器。在这种上下文中，"shell" 是指命令行解释器，负责解释和执行用户输入的命令。

Bash 是一种流行的 Unix shell，它提供了在命令行上执行命令和脚本的功能。在 GitHub Actions 中，你可以指定要在作业中使用的 shell，通常是 Bash 或 PowerShell，具体取决于你的需求和操作系统。

在你提供的工作流配置中，通过设置 `shell: bash`，指定了在该作业中使用 Bash 作为 shell。这意味着在 `./scripts` 目录下的脚本或命令将由 Bash 解释和执行。

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

   ```sh
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
