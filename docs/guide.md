# 小收获

#### 中文转拼音的依赖包

```xml
<dependency>
    <groupId>com.belerweb</groupId>
    <artifactId>pinyin4j</artifactId>
    <version>2.5.1</version>
</dependency>
```

使用方法(PinyinHelper)

```java
@Test
void PinyinTest() {
    //函数接收的是char类型数据，这个是输出bai2，数字为声
    String s = PinyinHelper.toHanyuPinyinStringArray("白纸".charAt(0))[0];
    System.out.println(s);
}
```

#### redis配置类

(主要是配置序列化器件)

```java
@Configuration
public class RedisConfig {
    private final RedisConnectionFactory factory;

    public TcmRedisConfig(RedisConnectionFactory factory) {
        this.factory = factory;
    }

    @Bean
    public RedisTemplate<String ,Object> redisTemplate() {
        RedisTemplate<String, Object> redisTemplate = new RedisTemplate<>();
        redisTemplate.setKeySerializer(new StringRedisSerializer());
        redisTemplate.setValueSerializer(new FastJsonRedisSerializer<>(Object.class));
        redisTemplate.setHashKeySerializer(new StringRedisSerializer());
        redisTemplate.setHashValueSerializer(new FastJsonRedisSerializer<>(Object.class));
        redisTemplate.setConnectionFactory(factory);
        return redisTemplate;
    }
}
```

`opsForValue()` 是 RedisTemplate 提供的一个方法，用于获取操作字符串类型值的操作接口。通过该方法，可以使用 RedisTemplate 执行字符串类型值的操作，例如设置值、获取值、设置过期时间等。

以下是一些常用的 `opsForValue()` 方法：

- `set(key, value)`：设置指定 key 的值为指定的 value。
- `get(key)`：获取指定 key 的值。
- `increment(key, delta)`：将 key 的值增加指定的 delta。
- `decrement(key, delta)`：将 key 的值减少指定的 delta。
- `setIfAbsent(key, value)`：如果指定 key 不存在，则设置 key 的值为指定的 value。
- `getAndSet(key, value)`：设置指定 key 的值为指定的 value，并返回原来的值。

这些方法可以通过 `redisTemplate.opsForValue()` 来调用。例如：

```java
redisTemplate.opsForValue().set("myKey", "myValue");
String value = redisTemplate.opsForValue().get("myKey");
redisTemplate.opsForValue().increment("myKey", 1);
```

还可以再对这个进行一次Util包装，这样就不用每次都调用opsForValue获得接口。

#### 接口传Json可以用map

```java
@PostMapping("/newPwd")
public CommonResult<Object> SetNewPwd(@RequestBody Map<String, String> form)
```

#### 使用构造函数去完成参数的注入

就不需要使用@Autowire去提示不推荐用了

```java
@RestController
@RequestMapping("admin")
public class AdminController {
    private final UmsServiceImpl umsService;
    private final AdminEsService adminEsService;
    private final SearchEsService searchEsService;
    private final AdminService adminService;

    public AdminController(UmsServiceImpl umsService, AdminEsService adminEsService, SearchEsService searchEsService, UmsUserServiceImpl umsUserService, AdminService adminService) {
        this.umsService = umsService;
        this.adminEsService = adminEsService;
        this.searchEsService = searchEsService;
        this.adminService = adminService;
    }
}
```

#### 判断邮箱是否符合格式

使用正则

```java
private boolean validateEmail(String email) {
    if (null==email || "".equals(email)) {
        return false;
    }
    Pattern p = Pattern.compile("^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}$");
    Matcher m = p.matcher(email);
    return m.matches();
}
```

#### 路由传参

```java
@GetMapping("/thread/{threadId}")
public CommonResult<FmsDetailResponse> getThreadDetailById(@PathVariable("threadId") int threadId)
```

#### Feign原理简要

简要说明

Feign这个名称源自于英语单词"feign"，意为"假装"、"伪装"。在计算机领域中，Feign是一个用于定义和实现声明式、类型安全的HTTP客户端的框架。

Feign的设计目标是简化和优化服务间的HTTP通信，使得开发者能够以简单、声明式的方式定义HTTP请求和响应的接口，而无需关注底层的网络细节和请求构建。通过在接口上添加注解，Feign可以根据接口定义自动生成对应的HTTP请求，实现了接口和HTTP请求的自动映射。

"Feign"这个名称暗示了在使用Feign时，开发者可以像"假装"调用本地方法一样去调用远程服务，无需关心底层的网络通信细节。这种声明式的编程风格使得服务间的通信变得更加简单、直观和可维护。

因为Feign在提供声明式的HTTP客户端功能上表现出色，并且具有简单易用、伪装远程调用的特点，所以被命名为Feign。这个名称准确地表达了该框架的设计理念和用途。



启动时，程序会进行包扫描，扫描所有包下所有@FeignClient注解的类，并将这些类注入到spring的IOC容器中。当定义的Feign中的接口被调用时，通过JDK的动态代理来生成RequestTemplate。

RequestTemplate中包含请求的所有信息，如请求参数，请求URL等。

RequestTemplate声场Request，然后将Request交给client处理，这个client默认是JDK的HTTPUrlConnection，也可以是OKhttp、Apache的HTTPClient等。

最后client封装成LoadBaLanceClient，结合ribbon负载均衡地发起调用。

[更详细说明链接](https://www.jianshu.com/p/8bca50cb11d8)

```java
@FeignClient(name = "example", url = "http://example.com")
public interface ExampleClient {

    @RequestMapping(method = RequestMethod.GET, value = "/api/example")
    String getExampleData(@RequestHeader("Authorization") String token);

}

```

在上面的例子中，`@RequestHeader("Authorization")` 用于指定请求头的名称为 "Authorization"，并将参数 `token` 的值作为请求头的值传递给远程服务。

通过这种方式，你可以在 Feign 接口方法中声明需要的请求头，并将其传递给远程服务，以实现更加灵活和精确的请求。

#### netty相关

##### 简要说明

Netty这个名称源自于英语单词"network"（网络）和"nifty"（精妙的、出色的）的组合。它是由JBOSS公司（现为Red Hat公司）开发的一个高性能的异步事件驱动的网络应用程序框架。命名为Netty旨在突出其在网络通信领域的出色表现和创新特性。

Netty的设计目标是提供简单、快速、灵活、可扩展的网络编程框架，使开发者能够轻松构建高性能、可靠的网络应用程序。它采用了基于事件驱动和异步非阻塞的网络通信模型，通过高效地利用计算资源和IO资源，可以处理大规模的并发连接和高吞吐量的数据传输。

Netty提供了丰富的网络编程组件和工具，包括了对TCP、UDP、HTTP、WebSocket等协议的支持，同时还提供了高级的功能，如编解码器、SSL/TLS安全传输、流量控制、拆包粘包处理等，以满足各种复杂的网络应用需求。

因为Netty在网络编程领域具有出色的表现和广泛的应用，逐渐成为了Java开发者首选的网络编程框架之一，所以被命名为Netty。

##### 异步事件驱动框架

#### 批量查询wrapper

```java
public List<Order> selectByOrderIdsAndProIds(List<UserCollection> orders, List<String> proIds) {
        LambdaQueryWrapper<Order> lambdaQueryWrapper = new LambdaQueryWrapper<>();
        lambdaQueryWrapper.in(Order::getId,orders)
                .in(!CollectionUtils.isEmpty(proIds),Order::getProjectId,proIds);
        return this.findList(lambdaQueryWrapper);
}
```

`lambdaQueryWrapper.in(Order::getId, orders)`: 使用 `in` 方法，传入订单列表 orders，表示查询的条件是 Order 表中的 id 字段在订单列表 orders 中的记录。

批量查询多个不同的数据

#### BindingResult

```java
@Controller
public class MyController {

    @PostMapping("/submitForm")
    public String submitForm(@ModelAttribute @Valid MyFormModel formModel, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            // 处理表单数据验证失败的情况
            // 可以返回错误信息给用户或进行其他逻辑处理
            return "error-page";
        } else {
            // 处理表单数据验证成功的情况
            // 可以进行业务逻辑处理或保存表单数据到数据库
            return "success-page";
        }
    }
}
```

在上面的代码中，`MyFormModel` 是一个 Java 类，用于映射表单数据。`@ModelAttribute` 注解表示将请求参数绑定到 `MyFormModel` 对象上，`@Valid` 注解表示需要对 `MyFormModel` 进行数据验证。验证结果会被封装到 `BindingResult` 对象中，通过 `bindingResult.hasErrors()` 判断是否有错误，如果有错误，则返回错误页面；如果没有错误，则进行业务逻辑处理或跳转到成功页面

#### docker部署项目

[这个好使](https://blog.csdn.net/weixin_43687024/article/details/130412125)

#### mysql自动生成代码

```java
import com.baomidou.mybatisplus.core.toolkit.StringPool;
import com.baomidou.mybatisplus.generator.AutoGenerator;
import com.baomidou.mybatisplus.generator.InjectionConfig;
import com.baomidou.mybatisplus.generator.config.*;
import com.baomidou.mybatisplus.generator.config.po.TableInfo;
import com.baomidou.mybatisplus.generator.config.rules.NamingStrategy;
import com.baomidou.mybatisplus.generator.engine.FreemarkerTemplateEngine;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

/**
 * <p>
 * mysql 代码生成器
 * </p>
 */
public class Generator {
    /**
     * RUN THIS
     */
    public static void main(String[] args) {
        //获取控制台的数据
        Scanner scanner = new Scanner(System.in);
        // 代码生成器
        AutoGenerator mpg = new AutoGenerator();
        // 全局配置
        GlobalConfig gc = new GlobalConfig();
        System.out.println("请输入文件输出目录的模块或者项目的地址:");
        String projectPath = scanner.nextLine();
        gc.setOutputDir(projectPath + "/src/main/java");      //生成文件的输出目录
        gc.setAuthor("Haechi");                                  //作者
        gc.setFileOverride(true);				              //是否覆蓋已有文件 默认值：false
        gc.setOpen(false);                                    //是否打开输出目录 默认值:true

        gc.setBaseColumnList(true);				              //开启 baseColumnList 默认false
        gc.setBaseResultMap(true);				               //开启 BaseResultMap 默认false
//      gc.setEntityName("%sEntity");			//实体命名方式  默认值：null 例如：%sEntity 生成 UserEntity
        gc.setMapperName("%sMapper");			                //mapper 命名方式 默认值：null 例如：%sDao 生成 UserDao
        gc.setXmlName("%sMapper");				                //Mapper xml 命名方式   默认值：null 例如：%sDao 生成 UserDao.xml
        gc.setServiceName("%sService");			                //service 命名方式   默认值：null 例如：%sBusiness 生成 UserBusiness
        gc.setServiceImplName("%sServiceImpl");	                //service impl 命名方式  默认值：null 例如：%sBusinessImpl 生成 UserBusinessImpl
        gc.setControllerName("%sController");	//controller 命名方式    默认值：null 例如：%sAction 生成 UserAction


        mpg.setGlobalConfig(gc);
// 数据源配置
        DataSourceConfig dsc = new DataSourceConfig();
        dsc.setUrl("jdbc:mysql://xx:3306/attendancesystem?useSSL=true&useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai");
// dsc.setSchemaName("public");
        dsc.setDriverName("com.mysql.cj.jdbc.Driver");
        dsc.setUsername("xx");
        dsc.setPassword("xx");
        mpg.setDataSource(dsc);
// 包配置
        PackageConfig pc = new PackageConfig();
//      pc.setModuleName(scanner("模块名"));
//      pc.setParent("com.stu");
        System.out.println("请输入模块名:");
        String name = scanner.nextLine();
        //自定义包配置
        pc.setParent(name);
        pc.setModuleName(null);
        pc.setMapper("mapper");
        pc.setEntity("domain");
        pc.setService("service");
        pc.setServiceImpl("service.impl");
        pc.setController("controller");
        mpg.setPackageInfo(pc);
// 自定义配置
        InjectionConfig cfg = new InjectionConfig() {
            @Override
            public void initMap() {
// to do nothing
            }
        };
        List<FileOutConfig> focList = new ArrayList<>();
        focList.add(new FileOutConfig("/templates/mapper.xml.ftl") {
            @Override
            public String outputFile(TableInfo tableInfo) {
// 自定义输入文件名称
                return projectPath + "/src/main/resources/mapper/" + /*pc.getModuleName() + "/" +*/
                        tableInfo.getEntityName() + "Mapper" +
                        StringPool.DOT_XML;
            }
        });
        cfg.setFileOutConfigList(focList);
        mpg.setCfg(cfg);
        mpg.setTemplate(new TemplateConfig().setXml(null));
        // 策略配置	数据库表配置，通过该配置，可指定需要生成哪些表或者排除哪些表
        StrategyConfig strategy = new StrategyConfig();
        strategy.setNaming(NamingStrategy.underline_to_camel);	//表名生成策略
        strategy.setColumnNaming(NamingStrategy.underline_to_camel);//数据库表字段映射到实体的命名策略, 未指定按照 naming 执行
//	    strategy.setCapitalMode(true);			    // 全局大写命名 ORACLE 注意
//	    strategy.setTablePrefix("prefix");		    //表前缀
//	    strategy.setSuperEntityClass("com.stu.domain");	//自定义继承的Entity类全称，带包名
//	    strategy.setSuperEntityColumns(new String[] { "test_id", "age" }); 	//自定义实体，公共字段
        strategy.setEntityLombokModel(true);	    //【实体】是否为lombok模型（默认 false
        strategy.setRestControllerStyle(true);	    //生成 @RestController 控制器
//	    strategy.setSuperControllerClass("com.baomidou.ant.common.BaseController");	//自定义继承的Controller类全称，带包名
//      strategy.setInclude(scanner("表名"));		//需要包含的表名，允许正则表达式（与exclude二选一配置）
        System.out.println("请输入映射的表名:");
        String tables = scanner.nextLine();
        String[] num = tables.split(",");
        strategy.setInclude(num);                       // 需要生成的表可以多张表
//	    strategy.setExclude(new String[]{"test"});      // 排除生成的表
//如果数据库有前缀，生成文件时是否要前缀acl_
//      strategy.setTablePrefix("bus_");
//      strategy.setTablePrefix("sys_");
        strategy.setControllerMappingHyphenStyle(true);	    //驼峰转连字符
        strategy.setTablePrefix(pc.getModuleName() + "_");	//是否生成实体时，生成字段注解
        mpg.setStrategy(strategy);
        mpg.setTemplateEngine(new FreemarkerTemplateEngine());
        mpg.execute();
    }
}
```

- 需要在上面的代码中配置数据库链接信息

- ```cmd
  请输入文件输出目录的模块或者项目的地址:
  D:\Desktop\java学习\ttd\ttd_generated
  请输入模块名:
  com.cy.generated
  请输入映射的表名:
  user
  ```

  ![1697196794180](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1697196794180.png)

- 大致结构图

#### 通过ip访问服务器文件

- 放在http下的server中，指的是访问对应ip地址下的端口并重定向路径

```json
listen       80;
server_name  localhost;

location /file 
{
	alias /www/wwwroot/xx.com;
}
```

#### 获得配置参数

`system.getProperty()`

```shell
java默认的系统变量有下面这些：

java.version:java运行时版本

java.vendor:java运行时环境供应商

java.vendor.url:java供应商url

java.home;java安装目录

java.vm.specification.version:java虚拟机规范版本

java.vm.specification.vendor:java虚拟机规范供应商

java.vm.specification.name:java虚拟机规范名称

java.vm.version:java虚拟机实现版本

java.vm.vendor:java虚拟机实现供应商

java.vm.name:java虚拟机实现名称

java.specification.version:java运行时环境规范版本

java.specification.vendor:java运行时环境规范运营商

java.specification.name:java运行时环境规范名称

java.class.version:java类格式版本

java.class.path:java类路径

java.library.path:加载库是搜索的路径列表

java.io.tmpdir:默认的临时文件路径

java.compiler:要使用的JIT编译器的路径

java.ext.dirs:一个或者多个扩展目录的路径

os.name:操作系统的名称

os.arch:操作系统的架构

os.version:操作系统的版本

file.separator:文件分隔符（在unix系统中是“/”）

path.separator:路径分隔符（在unix系统中是“:”）

line.separator:行分隔符（在unix系统中是“/n”）

user.name:用户的账户名称

user.home:用户的主目录

user.dir:用户的当前工作目录
```



# 代码

### setter方法 

```java
public CodingConfig setParityShards(int parityShards) {
        this.parityShards = parityShards;
        return this;
    }
```

> 这种模式通常被称为"Fluent Interface"（流畅接口）或"Method Chaining"（方法链式调用）。返回对象本身的 setter 方法允许你在一个语句中连续调用多个 setter 方法，从而提供一种更加流畅和可读性更高的方式来配置对象的属性。

可以这么使用

```java
CodingConfig codingnConfig = new CodingConfig()
    .setActiveTimeout(3600)
    .setTokenName("myToken")
    .setSomeOtherProperty(value);
```

### websocket

#### 心跳检测和鉴权

[推荐文章](https://my.oschina.net/code4j/blog/8795873)

### Aop

#### 例子

```java
// 定义注解
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface TestCheck {
}



// 实现切面
@Aspect
@Component
public class TestAspect {

    // 定义切点
    @Pointcut("@annotation(com.cy.aop.TestCheck)")
    public void check(){
        //System.out.println("checkPoint"); //这里不会执行
    }

    // 定义环绕通知
    // args()中的参数名要和目标方法中的参数名不一定一致,但是类型要一致，且顺序要一致
    // 加..表示任意个任意类型参数，但前提是必须有data1和data2
    @Around(value = "check()&&args(data1,data2,..)", argNames = "pjp,data1,data2")
    public Object around(ProceedingJoinPoint pjp,int data1,String data2) throws Throwable {
        System.out.println("around start");
        System.out.println("data1:"+data1);
        System.out.println("data2:"+data2);
        // 执行目标方法
        Object result = pjp.proceed();// 执行注解的方法
        System.out.println("around end");
        return result;
        /*
        // 在这里可以进行一些业务逻辑的判断
        // 符合条件的继续执行
        if (authStoreId == store_id) {
            return pjp.proceed();
        } else {
        // 不符合条件的就返回报错提示或者其他处理
            return new ResponseResult<>(401, "权限不足");
        }
        */

    }
}

// 使用
@TestCheck
@RequestMapping("/hello")
public String hello( @PathParam("data1") int data1,@PathParam("data2")String data2){
    System.out.println("hello");
    System.out.println("data1:"+data1);
    System.out.println("data2:"+data2);
    return "hello";
}
```

1. **@Aspect 注解：** 标识这个类是一个切面类，它包含了一些切点和通知。
2. **@Component 注解：** 将该类作为一个 Spring 组件，使其能够被 Spring 容器管理。
3. **RefundRequestMapper 和 OrderMapper：** 这两个是通过 `@Autowired` 注解注入的 DAO（数据访问对象），用于查询数据库。
4. **@Pointcut 注解和 check() 方法：** 定义一个切点，用于匹配被 `@StoreRefundCheck` 注解标记的方法。
5. **@Around 注解和 around() 方法：** 定义一个环绕通知，表示在目标方法执行前和执行后都要执行一些逻辑。`@Around` 注解中的表达式 `check() && args(store_id, refund_id,..)` 表示在 `check()` 切点的基础上，并且方法的参数列表中包含 `store_id` 和 `refund_id` 参数。
6. 在 `around()` 方法中，通过 `refundRequestMapper` 查询出 `refund_id` 对应的 `orderId`，再通过 `orderMapper` 查询出 `orderId` 对应的 `storeId`。
7. 然后判断 `authStoreId` 是否等于传入的 `store_id`，如果相等，说明有权限，调用 `pjp.proceed()` 执行原始方法，否则返回一个权限不足的响应结果。

### JSON工具类

```java
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * JSON 转换
 */
@Component
public final class JsonUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(JsonUtil.class);

    /**
     * 把Java对象转换成json字符串
     *
     * @param object 待转化为JSON字符串的Java对象
     * @return json 串 or null
     */
    public static String parseObjToJson(Object object) {
        String string = null;
        try {
            string = JSONObject.toJSONString(object);
        } catch (Exception e) {
            LOGGER.error(e.getMessage());
        }
        return string;
    }

    /**
     * 将Json字符串信息转换成对应的Java对象
     *
     * @param json json字符串对象
     * @param c    对应的类型
     */
    public static <T> T parseJsonToObj(String json, Class<T> c) {
        try {
            JSONObject jsonObject = JSON.parseObject(json);
            return JSON.toJavaObject(jsonObject, c);
        } catch (Exception e) {
            LOGGER.error(e.getMessage());
        }
        return null;
    }
}

```

### xml的sql还可以这样写

```xml
<select id="searchGood" parameterType="map" resultType="map">
        select t.* from(
        select t_good.*, ST_Distance_sphere(point(
        (SELECT store_address_lng from t_store where t_store.store_id = (SELECT t_store_good.store_id from t_store_good WHERE t_store_good.good_id = t_good.good_id)),
        (SELECT store_address_lat from t_store where t_store.store_id = (SELECT t_store_good.store_id from t_store_good WHERE t_store_good.good_id = t_good.good_id))),
        point(#{lng}, #{lat})) 'dis' from t_good WHERE 1=1
        <if test="goodName != null and goodName != ''">
        and good_name like concat('%',#{goodName},'%')
        </if>
        <if test="up != 0">
        and price >= #{down} and price <![CDATA[ <= ]]> up
        </if>
        <if test="categoryId != 0">
            and category_id = #{categoryId}
        </if>
        )t
        order by t.dis asc;
    </select>

```

1. **select 语句：**
   - 这是一个查询语句，返回的结果类型是 map 类型。
   - 使用了两个嵌套的 select 语句，外层的 `select t.* from(...)` 是为了给内层的查询结果进行排序。
   - 内层的查询主要计算了商品到指定坐标点的距离，并命名为 `dis`。
   - 使用了 `ST_Distance_sphere` 函数计算两个地理坐标点之间的球面距离。
   - 在内层查询的结果中，包含了商品表 `t_good` 的所有字段，并添加了 `dis` 字段。
2. **WHERE 子句：**
   - `WHERE 1=1` 是一个占位条件，用于后续动态添加其他条件。
   - `<if>` 标签用于条件判断。如果传递了 `goodName` 参数，则添加一个商品名称的模糊查询条件。
   - `<if>` 标签用于条件判断。如果 `up` 参数不等于 0，则添加商品价格在指定范围内的条件。
   - `<if>` 标签用于条件判断。如果 `categoryId` 参数不等于 0，则添加商品分类的条件。
3. **ORDER BY 子句：**
   - `ORDER BY t.dis asc` 是按照商品到指定坐标点的距离升序排序。

# vue的

#### 创建项目

```shell
vue ui
```

进入可视化页面创建

#### 添加element_plus

```shell
npm install element-plus
```



#### 添加echarr

```shell
npm install -S echarts
```

# Git



# Taro

## 文件path

需要在config/index.js中增加别名

```js
import path from 'path'//记得导入
const baseConfig = { // baseConfig本来就有，在这里头添加即可
    alias: {
      '@/components': path.resolve(__dirname, "..", "src/components"),
      "@/api": path.resolve(__dirname, "..", "src/api"),
      "@/assets": path.resolve(__dirname, "..", "src/assets"),
    }
}

//接下来就可以使用@/api
import storeDetailApi from "@/api/storeApi/storeDetail";
```

## 使用h5标签

需要导入`npm i @tarojs/plugin-html`

同样也是在`config/index.js`下的`baseConfig`中找到`plugins`选项，添加插件即可

```js
plugins: ['@tarojs/plugin-html']
```

## axios部分

### 注意项

- 不能使用alert去弹窗，需要使用`taro.showtoast`
- 不能使用localstorage需使用`wx.getStorageSync`

### 配置

- 需要额外导入`npm i axios-taro-adapter`

- 以及在使用axios的地方就是config.js中导入

  ```js
  import { TaroAdapter } from "axios-taro-adapter";
  
  //下面创建axios是配置适配器
  axios.create({
    //baseURL: 'https://rrewuq.com',
    baseURL: 'http://localhost:9737',
    timeout: 60000,
    adapter: TaroAdapter,  //适配器
    /*   withCredentials:true, */
    /* crossDomain:true, */
    headers: {
      'Content-Type': 'application/json; charset=utf-8'
    }
  })
  ```

- 小程序中需要关闭检测路由，在访问本地项目时

  ![1701263649072](C:\Users\86189\AppData\Roaming\Typora\typora-user-images\1701263649072.png)

# 注解解释

### @Transactional

`@Transactional` 是 Spring 框架中用于声明事务的注解，它可以被用于类、方法或者方法所在的接口上。它的作用是将被注解的方法（或者类中的所有方法）执行过程中划分为一个事务，确保事务的一致性和完整性。

主要特点和作用：

1. **事务的边界：** `@Transactional` 注解标记的方法（或者类中的所有方法）开始执行时，Spring 将创建一个事务。在方法执行期间，如果方法成功完成，事务将被提交。如果方法抛出异常，事务将被回滚。
2. **嵌套事务支持：** Spring 提供了对嵌套事务的支持，即在一个事务内部可以存在多个子事务。嵌套事务的行为取决于底层事务管理器的支持。
3. **传播行为：** `@Transactional` 注解提供了 `propagation` 属性，用于指定事务的传播行为。例如，如果一个事务内部调用了另一个带有 `@Transactional` 注解的方法，那么新的方法可以选择加入现有事务，创建新的事务，或者在没有事务的情况下执行。
4. **隔离级别：** `@Transactional` 注解提供了 `isolation` 属性，用于指定事务的隔离级别。隔离