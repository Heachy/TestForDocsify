# Netty网络编程框架

### NIO

#### 1. 基础说明

nio就是no-blocking-io 没有阻塞的io

#### 2. 三大组件

##### Channel&Buffer

Channel就是数据传输通道，是双向的，Buffer就是缓冲区，写数据时暂存的地方，以及读数据时的缓冲区。

##### Selector

selector就是一个线程与多个通道之间的处理器，去监测这个线程，处理多个通道的消息请求

#### 3. ByteBuffer

字节流缓冲

```java
//FileChannel
try (FileChannel channel = new FileInputStream("data.txt").getChannel()) {
    //准备缓冲区
    ByteBuffer buffer = ByteBuffer.allocate(10);

    while (true) {
        //从channel读取数据，向buffer写入
        int len = channel.read(buffer);
        System.out.println("len=" + len);
        if (len == -1) {
            break;
        }
        //打印buffer的内容
        buffer.flip();
        while (buffer.hasRemaining()) {
            byte b = buffer.get();
            System.out.println((char) b);
        }
        //清空缓冲区
        buffer.clear();
    }
} catch (IOException e) {
}
```

#### 	4. FileChannel

`from.transferTo(0,from.size(),to)`

<u>效率高，底层会用系统的零拷贝进行优化 **上限2g**</u>

复制函数，from和to都是fileChannel，也可以理解为从0开始复制到最后一个，from是InputStream，to是OutStream分别对应的getChannel获得的

#### 5. File

基本是Path文件路径通过工具类Paths.get("路径")去获得

然后通过Files.各种方法(copy,move,delete等)

walkFileTree遍历多级文件目录

#### 6. 阻塞模式

服务器端

```java
public class Server {
    public static void main(String[] args) throws IOException {
        //准备缓冲区
        ByteBuffer buffer = ByteBuffer.allocate(10);

        //打开服务器端的channel
        ServerSocketChannel ssc = ServerSocketChannel.open();

        //绑定监听端口
        ssc.bind(new InetSocketAddress(8081));

        //链接集合
        List<SocketChannel> channels = new ArrayList<>();

        while(true){
            //接收客户端的链接
            System.out.println("等待客户端的链接...");
            SocketChannel channel = ssc.accept();
            System.out.println("客户端链接成功...");
            channels.add(channel);

            for (SocketChannel socketChannel : channels) {
                //从channel读取数据，向buffer写入
                System.out.println("等待客户端发送数据...");
                int len = socketChannel.read(buffer);
                System.out.println("len=" + len);
                if (len == -1) {
                    channels.remove(socketChannel);
                    break;
                }
                //打印buffer的内容
                buffer.flip();
                while (buffer.hasRemaining()) {
                    byte b = buffer.get();
                    System.out.println((char) b);
                }
                //清空缓冲区
                buffer.clear();
            }
        }

    }
}

```

阻塞模式下，会在`ssc.accept()`下等待链接，如果没有链接，则线程就会堵塞，同理在`socketChannel.read(buffer)`这里也会堵塞，需要有数据传输才会往下继续执行

客户端

```java
public class Client1 {
    public static void main(String[] args) throws Exception{
        SocketChannel channel = SocketChannel.open();

        channel.connect(new InetSocketAddress("localhost",8081));



        System.out.println("waiting...");

        //暂停5秒
        Thread.sleep(10000);

        channel.write(ByteBuffer.wrap("hello1".getBytes()));

        //暂停5秒
        Thread.sleep(10000);

        channel.write(ByteBuffer.wrap("hello3".getBytes()));
    }
}
```

#### 7. 非阻塞模式

![1688974780137](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1688974780137.png)

就是开启服务之后把Blocking改为false

#### 8. Selector的使用

##### Accept和Read

```java
public class SelectorServer {
    public static void main(String[] args) throws Exception{

        //打开服务器端的channel
        ServerSocketChannel ssc = ServerSocketChannel.open();

        //绑定监听端口
        ssc.bind(new InetSocketAddress(8081));

        //设置为非阻塞
        ssc.configureBlocking(false);

        //注册到selector上
        Selector selector = Selector.open();

        //设置感兴趣的事件->监听事件
        SelectionKey selectionKey = ssc.register(selector, SelectionKey.OP_ACCEPT, null);

        System.out.println("selectionKey=" + selectionKey);

        while(true){
            //select方法是阻塞的，直到有事件发生
            System.out.println("等待事件发生...");
            selector.select();
            //获取事件 -> selectionKeys中包含了所有发生的事件
            Set<SelectionKey> selectionKeys = selector.selectedKeys();

            //遍历selectionKeys 并处理事件，不处理的话，下次select方法会再次获取到
            Iterator<SelectionKey> iterator = selectionKeys.iterator();

            while(iterator.hasNext()){
                SelectionKey key = iterator.next();
                //处理事件
                System.out.println("处理事件..." + key);

                //处理完后，从selectionKeys中移除
                iterator.remove();

                //如果是OP_ACCEPT事件，说明是新的客户端链接
                if(key.isAcceptable()){
                    //获取channel
                    ServerSocketChannel channel = (ServerSocketChannel)key.channel();

                    SocketChannel socketChannel = channel.accept();
                    System.out.println("客户端链接成功..."+socketChannel);

                    //设置为非阻塞
                    socketChannel.configureBlocking(false);

                    //准备缓冲区
                    ByteBuffer buffer = ByteBuffer.allocate(16);

                    //注册到selector上
                    socketChannel.register(selector,SelectionKey.OP_READ,buffer);
                } else if (key.isReadable()) {
                    try {
                        //读取数据
                        System.out.println("读取数据..." + key);
                        SocketChannel channel = (SocketChannel)key.channel();

                        //获取buffer 这个是注册时候的attachment附件
                        ByteBuffer buffer = (ByteBuffer)key.attachment();

                        int len = channel.read(buffer);

                        if(len == -1){
                            key.cancel();
                            System.out.println("客户端正常断开连接...");
                            continue;
                        }
                        System.out.println("len=" + len);
                        buffer.flip();

                        //这边一般会有对buffer的处理，比如对消息的分段，粘包，半包的处理
                        //如果发现有半包，那么就把buffer的内容拷贝到一个新的更大的buffer中，然后把旧的buffer替换掉

                        while(buffer.hasRemaining()){
                            byte b = buffer.get();
                            System.out.println((char)b);
                        }
                        buffer.clear();
                    } catch (IOException e) {
                        System.out.println("客户端异常断开连接...");
                        e.printStackTrace();
                        key.cancel();
                    }

                }
            }


        }


    }
```

selector算是一个注册中心，需要把ServerSocketChannel的key保存在里面，然后里面会有存储一个事件的注册中心selectionKeys，里面存储事件的key

对key进行判别，是Accept还是Read等，Accept的话需要创建一个ServerSocketChannel的新key注册到selector中。

在对事件进行处理时，要即使清除对应的selectionKey，直接调用迭代器的move即可。

在处理read的时候，如果链接断开，也是发送的read事件，但是Channel内部信息长度为-1，可以以此作为判断，这是正常断开的处理方式，如果遇到意外断开的话，需要try catch一下。

对于黏包，半包的处理，就是在向selector注册的时候附带一个附件，这个附件就是读取的缓冲区，一个链接一个对应的buffer，如果buffer过小可以进行更新buffer。

split函数就是将buffer按照需要的字符分开，是对黏包的处理。

OP_ACCEPT或者OP_READ就是只对要注册的Channel进行的监听事件

一开始建立的ServerSocketChannel还是后面新添加的SocketChannel都需要对是否blocking改为false

##### 处理write事件

```java
while(iterator.hasNext()){
                SelectionKey key = iterator.next();

                iterator.remove();

                if(key.isAcceptable()){
                    SocketChannel socketChannel = ssc.accept();

                    System.out.println("客户端链接成功..." + socketChannel);

                    socketChannel.configureBlocking(false);

                    SelectionKey selectionKey = socketChannel.register(selector, SelectionKey.OP_READ, null);

                    StringBuilder sb = new StringBuilder();

                    sb.append("a".repeat(5000000));

                    ByteBuffer buffer = ByteBuffer.wrap(sb.toString().getBytes());

                    int write = socketChannel.write(buffer);

                    System.out.println("一开始写了：" + write);

                    if (buffer.hasRemaining()) {
                        System.out.println("还有剩余：" + buffer.remaining());

                        selectionKey.interestOps(selectionKey.interestOps()+SelectionKey.OP_WRITE);

                        selectionKey.attach(buffer);
                    }
                } else if (key.isWritable()) {
                    SocketChannel socketChannel = (SocketChannel)key.channel();

                    ByteBuffer buffer = (ByteBuffer)key.attachment();

                    int write = socketChannel.write(buffer);

                    System.out.println("在读事件中又写了：" + write);

                    if (!buffer.hasRemaining()) {
                        System.out.println("写完了");
                        key.attach(null);

                        key.interestOps(key.interestOps()-SelectionKey.OP_WRITE);
                    }
                }
}
```

***<u>注意点</u>***

在向通道中传输数据时，即写数据时，要先将数据搞到buffer缓冲区中，如果一次性写不完，需要对这个channel绑定监听读事件。

在设置interestOps时不要直接等于`selectionKey.OP_WRITE`，需要通过`selectionKey.interestOps`加上原先的值，使其同时监听多个事件。（ps：这些值和linux中的文件操作权限一个道理，由数字1,2,4叠加区分）

在读事件中，如果写完了，需要将其绑定的附件buffer给消除，以及将监听读事件取消掉，即减去对应的值。

##### 多线程处理

![1689061920668](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689061920668.png)

![1689062066704](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689062066704.png)

![1689062092725](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689062092725.png)

有一个总的selector->boss，也可以说是分发器，对外接收所有的channel链接，但是将这些链接分配给其他线程worker。

在往其他线程里的selector中注册channel时，需要注意，因为在线程正在运行的时候run里面被`selector.select()`给堵塞了，一时半会是不会去执行channel注册的。

可以使用消息队列以及wakeup函数去解决，也可以直接使用一个wakeup即可。

重点是wakeup，可以让selector继续继续往下执行注册channel

主要是注意堵塞时和注册时的时间顺序问题

最后就是根据分配给线程的任务去写实际业务代码。

#### 9. 与BIO对比

##### Stream与Channel

Stream没有缓冲区，Channel有

Stream只支持阻塞API，Channel两者都支持

两者都支持全双工，即读写可以同时进行

##### IO模型

阻塞、非阻塞、多路复用

##### 零拷贝

![1689065250987](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689065250987.png)



### Netty

#### 基础介绍

Netty是一个异步的、基于事件驱动的网络应用框架，用于快速开发可维护、高性能的网络服务器和客户端

Netty并没有使用异步IO，这里的异步是指Netty的一些方法调用、处理结果，Netty的IO是基于多路复用的

#### HelloWorld例子

客户端

```java
public class HelloClient {
    public static void main(String[] args) throws InterruptedException {
        //1.启动器，负责组装netty组件，启动客户端
        new Bootstrap()
                //2.添加EventLoop
                .group(new NioEventLoopGroup())
                //3.选择客户端channel实现
                .channel(NioSocketChannel.class)
                //4.添加handler
                .handler(new ChannelInitializer<NioSocketChannel>() {
                    @Override
                    //在连接建立后被调用
                    protected void initChannel(NioSocketChannel channel) throws Exception {
                        //添加处理器，将ByteBuf转换为字符串
                        channel.pipeline().addLast(new StringEncoder());
                    }
                })
                //5.连接到服务器
                .connect("localhost",8081)
                //6.阻塞方法，直到连接建立
                .sync()
                //7.获得连接对象
                .channel()
                //8.向服务器发送数据
                .writeAndFlush("hello world");
    }
}
```

服务端

```java
public class HelloServer {
    public static void main(String[] args) {
        // 1. 启动器，负责组装netty组件，启动服务器
        new ServerBootstrap()
                // 2. BossEventLoop, WorkerEventLoop(selector, thread), group组
                .group(new NioEventLoopGroup())
                // 3. 选择服务器的ServerSocketChannel实现
                .channel(NioServerSocketChannel.class)
                // 4. boss负责处理连接，worker(child)负责处理读写，决定了worker(child)能执行哪些操作(handler)
                .childHandler(
                        // 5. channel代表和客户端进行数据读写的通道Initializer初始化，负责添加别的handler
                        new ChannelInitializer<NioSocketChannel>() {
                            @Override
                            protected void initChannel(NioSocketChannel channel) throws Exception {
                                // 6. 添加具体handler
                                //将ByteBuf转换为字符串
                                channel.pipeline().addLast(new StringDecoder());
                                //自定义handler
                                channel.pipeline().addLast(new ChannelInboundHandlerAdapter(){
                                    @Override
                                    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
                                        System.out.println(msg);
                                    }
                                });
                            }
                        }
                )
                // 7. 绑定监听端口
                .bind("localhost",8081);
    }
}
```

serverBootStrap和bootStrap是服务端和客户端的启动器

NioEvenLoopGroup就是线程管理组，每个线程都会循环用selector监听事件的请求发生，算是一个数组，里面有boss负责分发channel，有worker处理对应的read、write事件

NioServerSocketChannel和NioSocketChannel就是服务端和客户端对应使用的channel

handler就是对应的处理器，childHandler可以理解为上面worker所需要执行的内容

当链接建立后会执行ChannelInitializer进行initChannel初始化，往里面添加具体的处理器，和处理对应事件的处理器。

StringDecoder就是将ByteBuf转换为字符串，与之相反的客户端就是Encoder。

转换为字符串后就会传送到对应的事件处理器中的msg，再根据实际业务去处理

客户端中的sync就是让线程阻塞，知道socket连接上，然后获得channel后进行数据传输。

![1689141349797](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689141349797.png)

#### 组件

##### EventLoop

![1689148778625](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689148778625.png)

![1689149507525](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689149507525.png)

![1689154989199](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689154989199.png)

如果有些业务代码处理事件较久，可以再开个线程专门处理这个业务，及再细分到一个EvenLoop中去。

fireChannelRead(msg)让消息传递给下一个handler

![1689156002314](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689156002314.png)

一个小源码剖析

##### Channel

![1689156239157](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689156239157.png)

![1689174233167](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689174233167.png)

这边客户端获得链接是异步的，然后处理链接后的结果可以在主线程中等待，也可以规划到异步里，channelFuture感觉可以理解为未来的，之后获得的channel放在这里，要用再取。

operationComplete就是当链接成功后要做的事



![1689221246993](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689221246993.png)

在处理连接关闭时，由于NIO关闭步骤是异步的，如果想在关闭后执行一些业务代码，要么同步等待，或者像上面一样去放到operationComplete里面去。

连接断开之后，对应的事件组应该要去关闭，就去调用shutdownGracefully

#####  Future&Promise

概述

![1689223146894](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689223146894.png)

两个future都是等任务结束后执行，promise是两个线程任务间传递信息的容器，可以主动设置isSuccess

![1689223998540](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689223998540.png)

大差不差

![1689224546657](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689224546657.png)

promise的基础使用

##### Handler&PipeLine

![1689225275966](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689225275966.png)

在设置进入的处理器时，是按顺序的，出的是反着来，如果没有出的写操作，则不会触发出的处理器

![1689235545397](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689235545397.png)

这两个可以模拟入栈出栈的操作。

如果直接ctx去向外写数据，则会从当前的处理器往前找出栈处理器，不会从tail再去找

##### ByteBuf

ByteBuf是对NIO中的ByteBuff中的一个增强

创建

```java
ByteBuf byteBuf = ByteBufAllocator.DEFAULT.buffer()
```

buffer()里面可以设置初始长度和最大长度，byteBuf可以自适应去调节长度

默认是director内存，也可以改heap，就直接heapBuffer

也可以改是否池化，就是用的是不是一个buffer，和bean一个意思

ByteBuf里有四个参数，一个是读指针，一个是写指针，一个是当前容量，一个是最大容量

![1689240519467](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689240519467.png)

 多种写入方法

![1689242391347](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689242391347.png)

ByteBuf里面有个计数器，计数器初始化为1,0的时候无法使用，也有函数是让这个计数器加一的

谁最后接管ByteBuf，谁去释放这个ByteBuf对象

如果顺利走到head或者tail会自动处理ByteBuf，否则要手动释放

![1689244184102](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689244184102.png)

并不是物理上的切片，而是创建两个buffer有对饮的读写指针，并指向同一块连续内存

![1689244462200](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689244462200.png)

下面一更改，两个输出都变了，映射到同一个buffer上

原则上，分片后的buffer不能更改

 如果旧的buffer回收了，想要保存切片，可以用retain，使计数加一

![1689245098319](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689245098319.png)

​                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            

![1689252220302](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689252220302.png)

不用复制的将两个buffer拼接在一起，那个true参数，可以理解为是否拼接两个写指针的位置

![1689252748471](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689252748471.png)

在handler中创建buffer是，最好这样子创建



#### 黏包与半包

![1689307334821](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689307334821.png)

可以用换行符作为分隔符来进行处理黏包半包，maxlength就是如果超出这个长度还没识别到分隔符，就会显示数据异常。

![1689308964113](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689308964113.png)

帧解码器

![1689308943882](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689308943882.png)

这四个参数：

`lengthFieldOffset`这个是整个帧的一个头部长度

`lengthFieldLength`这个是帧里面数据的长度，根据这个长度来说明数据长度多少

`lengthAdjustment`这个是说明数据的头部有多长，这个的长度不计算在length里面

`initialBytesToStrip`这个是说明从头开始去除多少字节的长度，根据这个获取所需要的数据

#### 自定义协议

![1689322496272](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689322496272.png)

可以加一个字节凑够16个字节，2的4次方

![1689328096474](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689328096474.png)

编码与解码的handler

![1689328714978](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689328714978.png)

如果要用可以被多个线程共用的处理器的话，可以继承这个父类，然后就可以加Sharable注解

#### 实际业务

![1689391152213](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689391152213.png)

 经过message解码后，可以通过`SimpleChannelInboundHandler`去点名操作那个类，这边就点名要login的消息

然后再根据实际需要去写业务代码

![1689410511839](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689410511839.png)

可以将handler给提取出来，这边是处理断开链接的，记得清空SessionFactory里面的channel

![1689411241627](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689411241627.png)

`IDLEStateHandler`检测空闲的，第一个参数是检测读空闲多久，第二个是检测写空闲多久，第三个是检测都什么都没干多久

`ChannelDuplexHandler`这个是出站入站都经过的处理器

同样，这个可以放在客户端那边，作为心跳，跟服务器说明，我这个链接应该继续保持

#### 优化

可以选择json作为序列化的方法，在出站时进行编码，在入站时进行解码

协议要做好配置

![1689475761428](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689475761428.png)

通过option去配置channel

设置连接超时的时间

如果在300ms内没连接上就会抛出异常，如果时间过短，本来能连接上，因为网络波动就无法连上，所以超时时间应该要合理设置，过长的时候，会有更底层的判断是否连接成功来断言连接不上，并抛出异常



SO_BACKLOG

![1689477584903](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689477584903.png)

当进行完TCP三次握手之后，并不会立马accept，因为服务器处理有限，不一定会立马处理，所以先放到一个队列中等待处理。![1689477701711](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689477701711.png)

在找初始值时，可以用ctrl+alt+B找到finduse，然后顺着找到赋值链

![1689478303016](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689478303016.png)

第三个是一个进程最大能打开的文件数量

第四个是是否一有数据就立马发送

第五个是缓冲区的大小设置

![1689479047700](D:\Desktop\java学习\1689479047700.png)

根据这个来改变获得的buffer是否池化，堆内存还是直接内存

和SystemPropertyUtil获得的参数都在这边去配置环境变量

在默认入站那边的ByteBuffer是默认director内存，无法改变

#### 源码分析

![1689583829570](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689583829570.png)

![1689583798659](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1689583798659.png)

