# TestForDocs
> One repository for test of docsify

- [GitPage链接](https://heachy.github.io/TestForDocsify/#/)

- [docsify官网](https://docsify.js.org/#/zh-cn/quickstart)

- [代码高亮文件网页](https://cdn.jsdelivr.net/npm/prismjs@1/components/)

- 可以先将md文件里的本地图片通过picgo上传后再push

- 在格式->图像->上传全部本地图片3
- 测试action ing  1  2   3  4

## Action的使用

> 这个仓库主要用来测试docsify和action，所以会有点杂哈哈
>
> 这个action主要的功能是输入参数，打印获得返回数据没了哈哈
>
> 测试输入输出，action调用等

```yaml
name: Test the action

run-name: Test the action that my create in the marcket

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

  workflow_dispatch:

jobs:
  test-print-something:
    name: test the action in marcket
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3
      - name: use the action
        id: use-action
        uses: Heachy/TestForDocsify@main # 这边可以改成版本号了
        with:
          msg_a: hello
          msg_b: world
      - name: use the outputs
        run: |
          echo "The resultA is ${{ steps.use-action.outputs.result_a }}"
          echo "The resultB is ${{ steps.use-action.outputs.result_b }}"
      - name: The End
        run: echo Hello,My Action!
```

- 运行结果
- 会有看到脚本中执行的打印cyan颜色的两行数据(输入的msgA和msgB)
- 也有看到打印出返回的数据resultA和resultB

![](https://bucketofpicture.oss-cn-hangzhou.aliyuncs.com/picgo20240128185926.png)
