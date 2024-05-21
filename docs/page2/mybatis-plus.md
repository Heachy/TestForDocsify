# mybatis-plus源码解读

> 希望不是浪费时间QAQ
>
> 个人觉得最佳食用方法是配合Debug运行，可看看调试器里各变量的变化

## 初始化

### 相关类

#### MybatisSqlSessionFactoryBean

```java
	private static final Logger LOGGER = LoggerFactory.getLogger(MybatisSqlSessionFactoryBean.class);

    private static final ResourcePatternResolver RESOURCE_PATTERN_RESOLVER = new PathMatchingResourcePatternResolver();
    private static final MetadataReaderFactory METADATA_READER_FACTORY = new CachingMetadataReaderFactory();

	// MyBatis 配置文件的位置
	// Resource就是对输入流源(InputStreamSource)的一个实现类，有获得URL，IsOpen等见过的方法
    private Resource configLocation;

	// mybatis的配置实例
	// 有mapper注册，缓存，结果集，参数集，key的生成器等
    private MybatisConfiguration configuration;

	// mybatis映射文件的位置，就是mapper.xml的位置
    private Resource[] mapperLocations;

	// 数据源实例，用什么数据源进行连接，有deluyi，hikari，哈哈不会拼
    private DataSource dataSource;
	
	// 事物工厂示例
    private TransactionFactory transactionFactory;

	// 配置属性，和mybatis配置文件中的<properties>有关，里面就是个hashmap
    private Properties configurationProperties;

	// 顾名思义，就是个构造器
    private SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new MybatisSqlSessionFactoryBuilder();

	// sqlSession的工厂，负责创建session的会话，后面可以看到是有个Default的类去实现它
	// 里面有个configuration类，有各种配置，看看后面会不会碰到
    private SqlSessionFactory sqlSessionFactory;

	// 环境配置名称，默认使用类名`SQLSessionFactory`
    private String environment = SqlSessionFactoryBean.class.getSimpleName();

	// 是否快速失败的标志，目前不知道有啥用
    private boolean failFast;

	// 插件数组，有点印象，后面的什么插件都放到这边进行统一管理，像是我想做的动态表名插件应该也要放在这里吧哈哈
    private Interceptor[] plugins;

	// 类型处理器数组，感觉像是获得字段属性？
    private TypeHandler<?>[] typeHandlers;
	
	// 类型处理器包的路径!?
    private String typeHandlersPackage;

	// em... 默认的枚举类型处理器嘞
    @SuppressWarnings("rawtypes")
    private Class<? extends TypeHandler> defaultEnumTypeHandler;

	// 类型别名数组!
    private Class<?>[] typeAliases;

	// 对应的包路径
    private String typeAliasesPackage;
	
	// 父类别？
    private Class<?> typeAliasesSuperType;

	// 脚本语言驱动数组，去创建sqlSource去综合mapper.xml的内容和配置，还有创建参数处理器
    private LanguageDriver[] scriptingLanguageDrivers;

	// 默认的脚本语言处理器
    private Class<? extends LanguageDriver> defaultScriptingLanguageDriver;

	// 数据库ID提供者
    // issue #19. No default provider.
    private DatabaseIdProvider databaseIdProvider;

	// 虚拟文件系统类
    private Class<? extends VFS> vfs;

	// 缓存实例
    private Cache cache;

	// 对象工厂
    private ObjectFactory objectFactory;

	// 对象包装工厂
    private ObjectWrapperFactory objectWrapperFactory;
	
	// 全局配置实例，后面有详解
	@Setter
    private GlobalConfig globalConfig;
```

#### GlobalConfig

> 这几个config感觉都大差不差，换皮哈哈，或者里面使用其他的config，省事
>
> 就爱这种自带注释的，还是中文的
>
> 就是...复制过来有点花...哈哈

```java
@Data
@Accessors(chain = true)
public class GlobalConfig implements Serializable {
    //是否开启 LOGO
    private boolean banner = true;
    
    //是否初始化 SqlRunner
    private boolean enableSqlRunner = false;
    
    // 数据库相关配置
    private DbConfig dbConfig;
    
    //SQL注入器
    private ISqlInjector sqlInjector = new DefaultSqlInjector();
    
    //Mapper父类
    private Class<?> superMapperClass = Mapper.class;
    
    //仅用于缓存 SqlSessionFactory(外部勿进行set,set了也没用)
    @Deprecated
    private SqlSessionFactory sqlSessionFactory;
    
    //缓存已注入CRUD的Mapper信息
    private Set<String> mapperRegistryCache = new ConcurrentSkipListSet<>();
    
    //元对象字段填充控制器
    private MetaObjectHandler metaObjectHandler;
    
    // 注解控制器
    private AnnotationHandler annotationHandler = new AnnotationHandler(){};
    
    //参与 TableInfo 的初始化
    private PostInitTableInfoHandler postInitTableInfoHandler = new PostInitTableInfoHandler() {
    };
    
    //主键生成器
    private IdentifierGenerator identifierGenerator;

    @Data
    public static class DbConfig {
        
        //主键类型
        private IdType idType = IdType.ASSIGN_ID;
        
        //表名前缀
        private String tablePrefix;
        
        // schema @since 3.1.1
        private String schema;
        
        // db字段 format 例: `%s` 对主键无效 @since 3.1.1
        private String columnFormat;
        
        //db 表 format
        // 例: `%s`
        private String tableFormat;
        
        // entity 的字段(property)的 format,只有在 column as property 这种情况下生效 例: `%s` 对主键无效 @since 3.3.0
        private String propertyFormat;
        
        // 实验性功能,占位符替换,等同于 {@link com.baomidou.mybatisplus.extension.plugins.inner.ReplacePlaceholderInnerInterceptor},
         // 只是这个属于启动时替换,用得地方多会启动慢一点点,不适用于其他的 {@link org.apache.ibatis.scripting.LanguageDriver}
        private boolean replacePlaceholder;
        
        // 转义符* 配合 {@link #replacePlaceholder} 使用时有效 <p>
        // 例: " 或 ' 或 `
        private String escapeSymbol;
        
        // 表名是否使用驼峰转下划线命名,只对表名生效
        private boolean tableUnderline = true;
        
        // 大写命名,对表名和字段名均生效
        private boolean capitalMode = false;
        
        // 表主键生成器
        private List<IKeyGenerator> keyGenerators;
        
        // 逻辑删除全局属性名
        private String logicDeleteField;
        
        // 逻辑删除全局值（默认 1、表示已删除）
        private String logicDeleteValue = "1";
        
        // 逻辑未删除全局值（默认 0、表示未删除）
        private String logicNotDeleteValue = "0";
        
        // 字段验证策略之 insert
        private FieldStrategy insertStrategy = FieldStrategy.NOT_NULL;
        
        // 字段验证策略之 update
        private FieldStrategy updateStrategy = FieldStrategy.NOT_NULL;

        // 字段验证策略之 select
        @Deprecated
        private FieldStrategy selectStrategy;

        /**
         * 字段验证策略之 where
         * 替代selectStrategy，保持与{@link TableField#whereStrategy()}一致
         */
        private FieldStrategy whereStrategy = FieldStrategy.NOT_NULL;

        /**
         * 生成INSERT语句时忽略自增主键字段(默认不忽略,主键有值时写入主键值,无值自增).
         * <p>当设置为true时,执行生成SQL语句无论ID是否有值都会忽视 (此为3.4.3.1版本下策略,如果升级遇到问题可以考虑开启此配置来兼容升级)</p>
         */
        private boolean insertIgnoreAutoIncrementColumn = false;

        /**
         * 重写whereStrategy的get方法，适配低版本：
         * - 如果用户自定义了selectStrategy则用用户自定义的，
         * - 后续版本移除selectStrategy后，直接删除该方法即可。
         * @return 字段作为查询条件时的验证策略
         */
        public FieldStrategy getWhereStrategy() {
            return selectStrategy == null ? whereStrategy : selectStrategy;
        }
    }
}
```



### 相关方法

> 差不多就是按照初始化的流程走下去，有点分支会看到挺多的函数，主要还是记录感觉比较重要的函数吧。

#### sqlSessionFactory

```java
	@Bean
    @ConditionalOnMissingBean
	// 用于配置和创建 MyBatis 的 SqlSessionFactory 实例。它接受一个 DataSource 对象作为参数，并在此基础上配置各种 MyBatis 的属性和组件，最终返回一个配置好的 SqlSessionFactory 实例
    public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception {
        
        // 工厂实例
        MybatisSqlSessionFactoryBean factory = new MybatisSqlSessionFactoryBean();
        
        // 配置里面的数据源
        factory.setDataSource(dataSource);
        
        // 配置虚拟文件系统，以便在 Spring Boot 环境中正确加载资源。
        factory.setVfs(SpringBootVFS.class);
        
        // 如果配置文件位置不为空，则加载该配置文件。
        if (StringUtils.hasText(this.properties.getConfigLocation())) {
            factory.setConfigLocation(this.resourceLoader.getResource(this.properties.getConfigLocation()));
        }
        // 应用自定义配置，如果上述配置文件为空，就会导入一系列的默认配置在里面
        applyConfiguration(factory);
        
        // 如果有配置属性，则设置这些属性。
        if (this.properties.getConfigurationProperties() != null) {
            factory.setConfigurationProperties(this.properties.getConfigurationProperties());
        }
        // 如果有配置插件，则设置这些插件
        if (!ObjectUtils.isEmpty(this.interceptors)) {
            factory.setPlugins(this.interceptors);
        }
        
        // 如果有数据库ID提供者，则设置该提供者。
        if (this.databaseIdProvider != null) {
            factory.setDatabaseIdProvider(this.databaseIdProvider);
        }
        // 如果有类型别名包，则设置该包路径
        if (StringUtils.hasLength(this.properties.getTypeAliasesPackage())) {
            factory.setTypeAliasesPackage(this.properties.getTypeAliasesPackage());
        }
        
        // 如果有类型别名的父类，则设置该父类
        if (this.properties.getTypeAliasesSuperType() != null) {
            factory.setTypeAliasesSuperType(this.properties.getTypeAliasesSuperType());
        }
        
        // 如果有类型处理器包，则设置该包路径
        if (StringUtils.hasLength(this.properties.getTypeHandlersPackage())) {
            factory.setTypeHandlersPackage(this.properties.getTypeHandlersPackage());
        }
        // 如果有类型处理器，则设置这些处理器
        if (!ObjectUtils.isEmpty(this.typeHandlers)) {
            factory.setTypeHandlers(this.typeHandlers);
        }
        
        // 如果有映射文件，则设置这些文件的位置
        if (!ObjectUtils.isEmpty(this.properties.resolveMapperLocations())) {
            factory.setMapperLocations(this.properties.resolveMapperLocations());
        }
        // 设置事物工厂
        this.getBeanThen(TransactionFactory.class, factory::setTransactionFactory);

        // 设置默认脚本语言驱动程序
        Class<? extends LanguageDriver> defaultLanguageDriver = this.properties.getDefaultScriptingLanguageDriver();
        if (!ObjectUtils.isEmpty(this.languageDrivers)) {
            factory.setScriptingLanguageDrivers(this.languageDrivers);
        }
        Optional.ofNullable(defaultLanguageDriver).ifPresent(factory::setDefaultScriptingLanguageDriver);

        // 应用自定义的 SqlSessionFactoryBean 配置器
        applySqlSessionFactoryBeanCustomizers(factory);

        // 设置全局配置
        GlobalConfig globalConfig = this.properties.getGlobalConfig();
        this.getBeanThen(MetaObjectHandler.class, globalConfig::setMetaObjectHandler);
        this.getBeanThen(AnnotationHandler.class, globalConfig::setAnnotationHandler);
        this.getBeanThen(PostInitTableInfoHandler.class, globalConfig::setPostInitTableInfoHandler);
        this.getBeansThen(IKeyGenerator.class, i -> globalConfig.getDbConfig().setKeyGenerators(i));
        this.getBeanThen(ISqlInjector.class, globalConfig::setSqlInjector);
        this.getBeanThen(IdentifierGenerator.class, globalConfig::setIdentifierGenerator);
        factory.setGlobalConfig(globalConfig);
        
        // 返回 SqlSessionFactory 实例
        return factory.getObject();
    }
```

#### afterPropertiesSet

> 在`factory.getObject()`中调用，当配置都设置完后才去执行

```java
public void afterPropertiesSet() throws Exception {
    notNull(dataSource, "Property 'dataSource' is required");
    state((configuration == null && configLocation == null) || !(configuration != null && configLocation != null),
        "Property 'configuration' and 'configLocation' can not specified with together");
    this.sqlSessionFactory = buildSqlSessionFactory();
}
```

#### **buildSqlSessionFactory**

> 构建 `SqlSessionFactory` 实例。根据配置文件或直接使用配置对象来初始化 MyBatis 的 `Configuration` 对象，加载各种配置和映射文件，注册插件、类型处理器、别名等。

```java
protected SqlSessionFactory buildSqlSessionFactory() throws Exception {

    // 初始化 Configuration 对象
    final Configuration targetConfiguration;

    MybatisXMLConfigBuilder xmlConfigBuilder = null;

    // 如果已经有 configuration 对象，则使用它并设置相应的变量
    if (this.configuration != null) {

        targetConfiguration = this.configuration;

        if (targetConfiguration.getVariables() == null) {
            targetConfiguration.setVariables(this.configurationProperties);
        } else if (this.configurationProperties != null) {
            targetConfiguration.getVariables().putAll(this.configurationProperties);
        }
        // 如果提供了 XML 配置文件位置，则使用 MybatisXMLConfigBuilder 读取配置文件并初始化 Configuration 对象。
    } else if (this.configLocation != null) {
        xmlConfigBuilder = new MybatisXMLConfigBuilder(this.configLocation.getInputStream(), null, this.configurationProperties);
        targetConfiguration = xmlConfigBuilder.getConfiguration();

        // 如果都没有提供，则使用默认配置
    } else {
        LOGGER.debug(() -> "Property 'configuration' or 'configLocation' not specified, using default MyBatis Configuration");
        targetConfiguration = new MybatisConfiguration();
        Optional.ofNullable(this.configurationProperties).ifPresent(targetConfiguration::setVariables);
    }


    // 设置全局配置 GlobalConfig,如果没有配置，使用Utils里的默认
    this.globalConfig = Optional.ofNullable(this.globalConfig).orElseGet(GlobalConfigUtils::defaults);
    this.globalConfig.setDbConfig(Optional.ofNullable(this.globalConfig.getDbConfig()).orElseGet(GlobalConfig.DbConfig::new));

    GlobalConfigUtils.setGlobalConfig(targetConfiguration, this.globalConfig);

    // 下面也同理，存在则直接使用，否则就使用默认的
    Optional.ofNullable(this.objectFactory).ifPresent(targetConfiguration::setObjectFactory);
    Optional.ofNullable(this.objectWrapperFactory).ifPresent(targetConfiguration::setObjectWrapperFactory);

    Optional.ofNullable(this.vfs).ifPresent(targetConfiguration::setVfsImpl);

    // 包地址String不为0的话，通过包扫描注册类型别名
    if (hasLength(this.typeAliasesPackage)) {
        scanClasses(this.typeAliasesPackage, this.typeAliasesSuperType).stream()
            .filter(clazz -> !clazz.isAnonymousClass()).filter(clazz -> !clazz.isInterface())
            .filter(clazz -> !clazz.isMemberClass()).forEach(targetConfiguration.getTypeAliasRegistry()::registerAlias);
    }

    // 别名不为空的话，注册类型别名
    if (!isEmpty(this.typeAliases)) {
        Stream.of(this.typeAliases).forEach(typeAlias -> {
            targetConfiguration.getTypeAliasRegistry().registerAlias(typeAlias);
            LOGGER.debug(() -> "Registered type alias: '" + typeAlias + "'");
        });
    }

    // 插件不为空的话，遍历添加到target中
    if (!isEmpty(this.plugins)) {
        Stream.of(this.plugins).forEach(plugin -> {
            targetConfiguration.addInterceptor(plugin);
            LOGGER.debug(() -> "Registered plugin: '" + plugin + "'");
        });
    }

    // 不为空的话，通过包扫描注册类型处理器
    if (hasLength(this.typeHandlersPackage)) {
        scanClasses(this.typeHandlersPackage, TypeHandler.class).stream().filter(clazz -> !clazz.isAnonymousClass())
            .filter(clazz -> !clazz.isInterface()).filter(clazz -> !Modifier.isAbstract(clazz.getModifiers()))
            .forEach(targetConfiguration.getTypeHandlerRegistry()::register);
    }
    // 不为空的话，注册类型处理器
    if (!isEmpty(this.typeHandlers)) {
        Stream.of(this.typeHandlers).forEach(typeHandler -> {
            targetConfiguration.getTypeHandlerRegistry().register(typeHandler);
            LOGGER.debug(() -> "Registered type handler: '" + typeHandler + "'");
        });
    }

    // 设置默认枚举类型处理器
    targetConfiguration.setDefaultEnumTypeHandler(defaultEnumTypeHandler);

    // 不为空的话，注册脚本语言驱动
    if (!isEmpty(this.scriptingLanguageDrivers)) {
        Stream.of(this.scriptingLanguageDrivers).forEach(languageDriver -> {
            targetConfiguration.getLanguageRegistry().register(languageDriver);
            LOGGER.debug(() -> "Registered scripting language driver: '" + languageDriver + "'");
        });
    }
    Optional.ofNullable(this.defaultScriptingLanguageDriver)
        .ifPresent(targetConfiguration::setDefaultScriptingLanguage);

    // 设置数据库 ID 提供者
    if (this.databaseIdProvider != null) {// fix #64 set databaseId before parse mapper xmls
        try {
            targetConfiguration.setDatabaseId(this.databaseIdProvider.getDatabaseId(this.dataSource));
        } catch (SQLException e) {
            throw new IOException("Failed getting a databaseId", e);
        }
    }
    // 添加缓存
    Optional.ofNullable(this.cache).ifPresent(targetConfiguration::addCache);

    // 不为空的话，解析 XML 配置文件
    if (xmlConfigBuilder != null) {
        try {
            xmlConfigBuilder.parse();
            LOGGER.debug(() -> "Parsed configuration file: '" + this.configLocation + "'");
        } catch (Exception ex) {
            throw new IOException("Failed to parse config resource: " + this.configLocation, ex);
        } finally {
            ErrorContext.instance().reset();
        }
    }
    // 设置环境
    targetConfiguration.setEnvironment(new Environment(this.environment,
        this.transactionFactory == null ? new SpringManagedTransactionFactory() : this.transactionFactory,
        this.dataSource));

    // 解析映射文件
    if (this.mapperLocations != null) {
        if (this.mapperLocations.length == 0) {
            LOGGER.warn(() -> "Property 'mapperLocations' was specified but matching resources are not found.");
        } else {
            // mapper.xml文件的地址，比如：
            // E:/java/LearnProject/springboot-test/target/classes/mapper/DeptMapper.xml
            for (Resource mapperLocation : this.mapperLocations) {
                if (mapperLocation == null) {
                    continue;
                }
                try {
                    MybatisXMLMapperBuilder xmlMapperBuilder = new MybatisXMLMapperBuilder(mapperLocation.getInputStream(),
                        targetConfiguration, mapperLocation.toString(), targetConfiguration.getSqlFragments());
                    xmlMapperBuilder.parse();
                } catch (Exception e) {
                    throw new IOException("Failed to parse mapping resource: '" + mapperLocation + "'", e);
                } finally {
                    ErrorContext.instance().reset();
                }
                LOGGER.debug(() -> "Parsed mapper file: '" + mapperLocation + "'");
            }
        }
    } else {
        LOGGER.debug(() -> "Property 'mapperLocations' was not specified.");
    }
    //构建 SqlSessionFactory 实例
    final SqlSessionFactory sqlSessionFactory = this.sqlSessionFactoryBuilder.build(targetConfiguration);

    // 设置全局 SqlSessionFactory
    SqlHelper.FACTORY = sqlSessionFactory;

    // 打印 MyBatis Plus 版本横幅（如果启用了横幅）
    if (globalConfig.isBanner()) {
        System.out.println(" _ _   |_  _ _|_. ___ _ |    _ ");
        System.out.println("| | |\\/|_)(_| | |_\\  |_)||_|_\\ ");
        System.out.println("     /               |         ");
        System.out.println("                        " + MybatisPlusVersion.getVersion() + " ");
    }

    return sqlSessionFactory;
}
```

### Mapper部分

#### 方法

##### XmlMapperBuilder.parse()

> 解析mapper.xml的方法

```java
public void parse() {
    // 检查资源是否已加载
    if (!configuration.isResourceLoaded(resource)) {
        // 解析 <mapper> 元素
        // 处理解析后的 <mapper> 元素。将 <mapper> 元素中的配置加载到 configuration 对象中。
        configurationElement(parser.evalNode("/mapper"));
        
        // 添加资源到已加载列表  将当前资源标记为已加载，防止重复加载
        configuration.addLoadedResource(resource);
        
        // 绑定命名空间   将解析后的 mapper.xml 与相应的 Mapper 接口绑定。这通常涉及将 XML 中定义的 SQL 语句与接口方法关联起来。
        bindMapperForNamespace();
    }
    // 解析挂起的结果映射
    configuration.parsePendingResultMaps(false);
    
    // 解析挂起的缓存引用
    configuration.parsePendingCacheRefs(false);
    
    // 解析挂起的语句
    configuration.parsePendingStatements(false);
}
```

###### configurationElement

> 这个方法 `configurationElement(XNode context)` 负责解析 `mapper.xml` 文件的内容，并将这些内容加载到 MyBatis 的配置对象中。下面是对这个方法的详细解释：

```java
private void configurationElement(XNode context) {
    try {
        // 获取并设置命名空间
        String namespace = context.getStringAttribute("namespace");
        if (namespace == null || namespace.isEmpty()) {
            throw new BuilderException("Mapper's namespace cannot be empty");
        }
        builderAssistant.setCurrentNamespace(namespace);
        
        //解析 <cache-ref> 元素  处理该元素并将其配置到 configuration 对象中。	
        // 上面的configuration中不是有个属性和cache有关嘛，就是这个了
        cacheRefElement(context.evalNode("cache-ref"));
        cacheElement(context.evalNode("cache"));
        
        // 解析参数集映射
        parameterMapElement(context.evalNodes("/mapper/parameterMap"));
        
        // 解析结果集映射
        resultMapElements(context.evalNodes("/mapper/resultMap"));
        
        // 解析sql语句吧，configuration中也有sqlFragments
        sqlElement(context.evalNodes("/mapper/sql"));
        
        // 这里就是去解析自己写的sql语句
        buildStatementFromContext(context.evalNodes("select|insert|update|delete"));
    } catch (Exception e) {
        throw new BuilderException("Error parsing Mapper XML. The XML location is '" + resource + "'. Cause: " + e, e);
    }
}
```

###### parseStatementNode

> 这个是buildStatementFromContext里面的，遍历解析传入的nodeList
>
> 用于解析 XML 配置文件中的 SQL 语句节点的方法。它会从 XML 节点中提取属性，创建并配置相应的 `MappedStatement` 对象，最终将其添加到 MyBatis 配置中

```java
public void parseStatementNode() {
    
    // 获取 SQL 语句的唯一标识符 id 和数据库标识符 databaseId
    String id = context.getStringAttribute("id");
    String databaseId = context.getStringAttribute("databaseId");

    // 如果数据库标识符不匹配当前的配置，直接返回，不解析该节点
    if (!databaseIdMatchesCurrent(id, databaseId, this.requiredDatabaseId)) {
      return;
    }

    // 获取节点名称（如 select, insert, update, delete）并将其转换为 SqlCommandType
    String nodeName = context.getNode().getNodeName();
    SqlCommandType sqlCommandType = SqlCommandType.valueOf(nodeName.toUpperCase(Locale.ENGLISH));
    
    // 是否是 SELECT 语句
    boolean isSelect = sqlCommandType == SqlCommandType.SELECT;
    
    // 获取 flushCache、useCache 和 resultOrdered 属性，这些属性决定了缓存和结果排序等行为
    boolean flushCache = context.getBooleanAttribute("flushCache", !isSelect);
    boolean useCache = context.getBooleanAttribute("useCache", isSelect);
    boolean resultOrdered = context.getBooleanAttribute("resultOrdered", false);

    // Include Fragments before parsing
    // 处理 include 片段，将其内容包含进来
    XMLIncludeTransformer includeParser = new XMLIncludeTransformer(configuration, builderAssistant);
    includeParser.applyIncludes(context.getNode());

    // 获取并解析参数类型 parameterType
	// 获取并解析语言驱动器 lang
    String parameterType = context.getStringAttribute("parameterType");
    Class<?> parameterTypeClass = resolveClass(parameterType);

    String lang = context.getStringAttribute("lang");
    LanguageDriver langDriver = getLanguageDriver(lang);

    // Parse selectKey after includes and remove them.
    // 处理 selectKey 节点，这是 MyBatis 用于生成主键的特殊节点
    processSelectKeyNodes(id, parameterTypeClass, langDriver);

    // Parse the SQL (pre: <selectKey> and <include> were parsed and removed)
    // 根据 selectKey 节点或者 useGeneratedKeys 属性确定主键生成器。
    KeyGenerator keyGenerator;
    String keyStatementId = id + SelectKeyGenerator.SELECT_KEY_SUFFIX;
    keyStatementId = builderAssistant.applyCurrentNamespace(keyStatementId, true);
    if (configuration.hasKeyGenerator(keyStatementId)) {
      keyGenerator = configuration.getKeyGenerator(keyStatementId);
    } else {
      keyGenerator = context.getBooleanAttribute("useGeneratedKeys",
          configuration.isUseGeneratedKeys() && SqlCommandType.INSERT.equals(sqlCommandType))
              ? Jdbc3KeyGenerator.INSTANCE : NoKeyGenerator.INSTANCE;
    }

    // 使用语言驱动器创建 SqlSource，包含实际的 SQL 语句
    SqlSource sqlSource = langDriver.createSqlSource(configuration, context, parameterTypeClass);
    StatementType statementType = StatementType
        .valueOf(context.getStringAttribute("statementType", StatementType.PREPARED.toString()));
    
    // 解析并设置其他属性，如 statementType、fetchSize、timeout、parameterMap、resultType、resultMap、resultSetType、keyProperty、keyColumn、resultSets 和 dirtySelect
    Integer fetchSize = context.getIntAttribute("fetchSize");
    Integer timeout = context.getIntAttribute("timeout");
    String parameterMap = context.getStringAttribute("parameterMap");
    String resultType = context.getStringAttribute("resultType");
    Class<?> resultTypeClass = resolveClass(resultType);
    String resultMap = context.getStringAttribute("resultMap");
    if (resultTypeClass == null && resultMap == null) {
      resultTypeClass = MapperAnnotationBuilder.getMethodReturnType(builderAssistant.getCurrentNamespace(), id);
    }
    String resultSetType = context.getStringAttribute("resultSetType");
    ResultSetType resultSetTypeEnum = resolveResultSetType(resultSetType);
    if (resultSetTypeEnum == null) {
      resultSetTypeEnum = configuration.getDefaultResultSetType();
    }
    String keyProperty = context.getStringAttribute("keyProperty");
    String keyColumn = context.getStringAttribute("keyColumn");
    String resultSets = context.getStringAttribute("resultSets");
    boolean dirtySelect = context.getBooleanAttribute("affectData", Boolean.FALSE);

    // 使用 builderAssistant 将解析后的所有信息构建成 MappedStatement 对象，并添加到 MyBatis 的 Configuration 中
    // 和下面的其实是一样的
    builderAssistant.addMappedStatement(id, sqlSource, statementType, sqlCommandType, fetchSize, timeout, parameterMap,
    parameterTypeClass, resultMap, resultTypeClass, resultSetTypeEnum, flushCache, useCache, resultOrdered,
    keyGenerator, keyProperty, keyColumn, databaseId, langDriver, resultSets, dirtySelect);
}
```



##### bindMapperForNamespace

> `bindMapperForNamespace` 方法负责将 `mapper.xml` 文件中的命名空间与相应的 Mapper 接口类绑定。它确保命名空间对应的 Mapper 接口类在 MyBatis 配置中注册。

```java
private void bindMapperForNamespace() {
    // 获取当前命名空间
    String namespace = builderAssistant.getCurrentNamespace();
    // 尝试加载命名空间对应的类
    if (namespace != null) {
        Class<?> boundType = null;
        try {
            boundType = Resources.classForName(namespace);
        } catch (ClassNotFoundException e) {
            // ignore, bound type is not required
        }
        //检查并添加 Mapper
        if (boundType != null && !configuration.hasMapper(boundType)) {
            // 添加一个标志，表示该资源已经加载。这个标志用于防止 Spring 再次从 Mapper 接口加载这个资源
            configuration.addLoadedResource("namespace:" + namespace);
            // 将命名空间对应的 Mapper 接口类添加到 MyBatis 配置中
            configuration.addMapper(boundType);
        }
    }
}
```

##### addMapper

> 用于将一个 Mapper 接口类添加到 MyBatis 的 Mapper 注册表中。它的主要作用是确保接口类型的 Mapper 被正确地注册和解析，以便 MyBatis 能够使用这些 Mapper 进行数据库操作。

```java
public <T> void addMapper(Class<T> type) {
    if (type.isInterface()) {
        // 检查该类型是否已经注册。如果已经注册，则直接返回，不进行重复注册
        if (hasMapper(type)) {
            return;
//                throw new BindingException("Type " + type + " is already known to the MapperRegistry.");
        }
        boolean loadCompleted = false;
        try {
            knownMappers.put(type, new MybatisMapperProxyFactory<>(type));
            // 将类型和对应的 MybatisMapperProxyFactory 实例添加到 knownMappers 映射中。这一步非常重要，因为它确保类型在解析之前已经被注册。
            MybatisMapperAnnotationBuilder parser = new MybatisMapperAnnotationBuilder(config, type);
            parser.parse();
            // 如果解析成功，将 loadCompleted 标志设置为 true。
            loadCompleted = true;
        } finally {
            if (!loadCompleted) {
                // 如果解析过程中发生异常，则在 finally 块中移除先前添加的类型，确保注册表的一致性。
                knownMappers.remove(type);
            }
        }
    }
}
```

##### parse()

> 主要功能是读取和处理 Mapper 接口及其方法上的注解，以便生成相应的 SQL 语句和映射配置。

```java
public void parse() {
    String resource = type.toString();

    // 检查当前资源是否已经被加载。如果已经加载，则不再重复解析。
    if (!configuration.isResourceLoaded(resource)) {
        // 加载 XML 资源
        loadXmlResource();
        configuration.addLoadedResource(resource);
        
        // 设置命名空间
        String mapperName = type.getName();
        assistant.setCurrentNamespace(mapperName);
        
        // 解析缓存配置
        parseCache();
        parseCacheRef();
        
        // 初始化 SQL 解析忽略策略
        IgnoreStrategy ignoreStrategy = InterceptorIgnoreHelper.initSqlParserInfoCache(type);
        
        // 遍历当前 Mapper 接口中的所有方法。
        for (Method method : type.getMethods()) {
            // 检查方法是否可以包含 SQL 语句
            if (!canHaveStatement(method)) {
                continue;
            }
            // 如果方法上存在 @Select 或 @SelectProvider 注解且没有 @ResultMap 注解
            // 则调用 parseResultMap(method) 方法解析结果映射。
            if (getAnnotationWrapper(method, false, Select.class, SelectProvider.class).isPresent()
                && method.getAnnotation(ResultMap.class) == null) {
                parseResultMap(method);
            }
            try {
                // 初始化方法的 SQL 解析忽略策略
                InterceptorIgnoreHelper.initSqlParserInfoCache(ignoreStrategy, mapperName, method);
                
                // 解析方法上的 SQL 语句
                parseStatement(method);
            } catch (IncompleteElementException e) {
                configuration.addIncompleteMethod(new MybatisMethodResolver(this, method));
            }
        }
        try {
            // https://github.com/baomidou/mybatis-plus/issues/3038
            // 处理超级 Mapper 父类
            if (GlobalConfigUtils.isSupperMapperChildren(configuration, type)) {
                // 将父类的方法都注入进来
                parserInjector();
            }
        } catch (IncompleteElementException e) {
            configuration.addIncompleteMethod(new InjectorResolver(this));
        }
    }
    configuration.parsePendingMethods(false);
}
```

##### parseStatement

> 用于解析 Mapper 接口中方法的注解，并生成相应的 `MappedStatement` 对象的一个关键方法。它的主要作用是根据方法上的注解信息，构建并注册 SQL 语句的相关配置

```java
void parseStatement(Method method) {
    //  获取参数类型和语言驱动
    final Class<?> parameterTypeClass = getParameterType(method);
    final LanguageDriver languageDriver = getLanguageDriver(method);

    // 获取方法上的 SQL 语句相关的注解（如 @Select, @Insert, @Update, @Delete）
	// 如果存在这些注解，则进行后续处理
    getAnnotationWrapper(method, true, statementAnnotationTypes).ifPresent(statementAnnotation -> {
        // 构建 SqlSource
        final SqlSource sqlSource = buildSqlSource(statementAnnotation.getAnnotation(), parameterTypeClass,
            languageDriver, method);
        
        // 获取 SQL 命令类型(SELECT ...)和选项(Option)
        final SqlCommandType sqlCommandType = statementAnnotation.getSqlCommandType();
        final Options options = getAnnotationWrapper(method, false, Options.class).map(x -> (Options) x.getAnnotation())
            .orElse(null);
        // mappedStatementId：生成唯一的 MappedStatement ID，格式为 Mapper接口名.方法名。
        final String mappedStatementId = type.getName() + "." + method.getName();

        // 处理键生成器和相关属性
        final KeyGenerator keyGenerator;
        String keyProperty = null;
        String keyColumn = null;
        
        // 根据 sqlCommandType 判断是否为 INSERT 或 UPDATE 操作。
        if (SqlCommandType.INSERT.equals(sqlCommandType) || SqlCommandType.UPDATE.equals(sqlCommandType)) {
            // first check for SelectKey annotation - that overrides everything else
            SelectKey selectKey = getAnnotationWrapper(method, false, SelectKey.class)
                .map(x -> (SelectKey) x.getAnnotation()).orElse(null);
            
            // 如果有 @SelectKey 注解，使用 handleSelectKeyAnnotation 方法处理键生成器，并获取 keyProperty。
            if (selectKey != null) {
                keyGenerator = handleSelectKeyAnnotation(selectKey, mappedStatementId, getParameterType(method),languageDriver);
                
                keyProperty = selectKey.keyProperty();
                
            } else if (options == null) {
                
                // 如果没有 @SelectKey 注解，根据配置决定使用哪种键生成器（Jdbc3KeyGenerator 或 NoKeyGenerator）。
                keyGenerator = configuration.isUseGeneratedKeys() ? Jdbc3KeyGenerator.INSTANCE : NoKeyGenerator.INSTANCE;
            } else {
                keyGenerator = options.useGeneratedKeys() ? Jdbc3KeyGenerator.INSTANCE : NoKeyGenerator.INSTANCE;
                keyProperty = options.keyProperty();
                keyColumn = options.keyColumn();
            }
        } else {
            keyGenerator = NoKeyGenerator.INSTANCE;
        }

        Integer fetchSize = null;
        Integer timeout = null;
        StatementType statementType = StatementType.PREPARED;
        ResultSetType resultSetType = configuration.getDefaultResultSetType();
        boolean isSelect = sqlCommandType == SqlCommandType.SELECT;
        boolean flushCache = !isSelect;
        boolean useCache = isSelect;
        
        // 根据 @Options 注解设置 fetchSize、timeout、statementType、resultSetType、flushCache、useCache 等选项。
        if (options != null) {
            if (FlushCachePolicy.TRUE.equals(options.flushCache())) {
                flushCache = true;
            } else if (FlushCachePolicy.FALSE.equals(options.flushCache())) {
                flushCache = false;
            }
            useCache = options.useCache();
            // issue #348
            fetchSize = options.fetchSize() > -1 || options.fetchSize() == Integer.MIN_VALUE ? options.fetchSize() : null;
            timeout = options.timeout() > -1 ? options.timeout() : null;
            statementType = options.statementType();
            if (options.resultSetType() != ResultSetType.DEFAULT) {
                resultSetType = options.resultSetType();
            }
        }

        String resultMapId = null;
        
        // 如果是 SELECT 操作，处理 @ResultMap 注解，生成结果映射 ID。
        if (isSelect) {
            ResultMap resultMapAnnotation = method.getAnnotation(ResultMap.class);
            if (resultMapAnnotation != null) {
                resultMapId = String.join(",", resultMapAnnotation.value());
            } else {
                resultMapId = generateResultMapName(method);
            }
        }
		// 调用 assistant.addMappedStatement 方法，将上述所有配置信息添加到 MappedStatement 中。
        assistant.addMappedStatement(mappedStatementId, sqlSource, statementType, sqlCommandType, fetchSize, timeout,
            // ParameterMapID
            null, parameterTypeClass, resultMapId, getReturnType(method, type), resultSetType, flushCache, useCache,
            // TODO gcode issue #577
            false, keyGenerator, keyProperty, keyColumn, statementAnnotation.getDatabaseId(), languageDriver,
            // ResultSets
            options != null ? nullOrEmpty(options.resultSets()) : null, statementAnnotation.isDirtySelect());
    });
}
```

##### parserInjector

```java
public void inspectInject(MapperBuilderAssistant builderAssistant, Class<?> mapperClass) {
    
    // 获取 Mapper 类的泛型参数（模型类）：
    Class<?> modelClass = ReflectionKit.getSuperClassGenericType(mapperClass, Mapper.class, 0);
    if (modelClass != null) {

    	// 获取 mapperClass 的类名，并检查全局配置中的 Mapper 注册缓存，如果缓存中已存在该类名，则不进行后续操作。
        String className = mapperClass.toString();
        Set<String> mapperRegistryCache = GlobalConfigUtils.getMapperRegistryCache(builderAssistant.getConfiguration());
        if (!mapperRegistryCache.contains(className)) {
            
            // 使用 TableInfoHelper 初始化模型类的表信息。表信息包括表名、字段名等，便于后续方法的注入和使用。
            TableInfo tableInfo = TableInfoHelper.initTableInfo(builderAssistant, modelClass);
            
            // 通过 getMethodList 方法获取自定义方法列表。如果方法列表为空，则使用另一种方法获取
            // 然后，遍历方法列表，调用 inject 方法将每个自定义方法注入到 mapperClass 中。
            List<AbstractMethod> methodList = this.getMethodList(mapperClass, tableInfo);
            // 兼容旧代码
            if (CollectionUtils.isEmpty(methodList)) {
                methodList = this.getMethodList(builderAssistant.getConfiguration(), mapperClass, tableInfo);
            }
            if (CollectionUtils.isNotEmpty(methodList)) {
                // 循环注入自定义方法
                methodList.forEach(m -> m.inject(builderAssistant, mapperClass, modelClass, tableInfo));
            } else {
                logger.debug(className + ", No effective injection method was found.");
            }
            
            // 更新 Mapper 注册缓存
            mapperRegistryCache.add(className);
        }
    }
}
```

- List<AbstractMethod> methodList = this.getMethodList(mapperClass, tableInfo);

  这个函数处于的类是`AbstractSqlInjector`，然后默认是`DefaultSqlInjector`

  所以当调用这个方法时，就会来到这里。

  ```java
  public List<AbstractMethod> getMethodList(Configuration configuration, Class<?> mapperClass, TableInfo tableInfo) {
      GlobalConfig.DbConfig dbConfig = GlobalConfigUtils.getDbConfig(configuration);
      Stream.Builder<AbstractMethod> builder = Stream.<AbstractMethod>builder()
          .add(new Insert(dbConfig.isInsertIgnoreAutoIncrementColumn()))
          .add(new Delete())
          .add(new Update())
          .add(new SelectCount())
          .add(new SelectMaps())
          .add(new SelectObjs())
          .add(new SelectList());
      if (tableInfo.havePK()) {
          builder.add(new DeleteById())
              .add(new DeleteBatchByIds())
              .add(new UpdateById())
              .add(new SelectById())
              .add(new SelectBatchByIds());
      } else {
          logger.warn(String.format("%s ,Not found @TableId annotation, Cannot use Mybatis-Plus 'xxById' Method.",
              tableInfo.getEntityType()));
      }
      return builder.build().collect(toList());
  }
  ```

- 所以会获得一些默认方法列表，因为每个方法都继承了`AbstractMethod`，所以都要重写对应的`injectMappedStatement`

- 比如`Update`的

  ```java
  public MappedStatement injectMappedStatement(Class<?> mapperClass, Class<?> modelClass, TableInfo tableInfo) {
      SqlMethod sqlMethod = SqlMethod.UPDATE;
      String sql = String.format(sqlMethod.getSql(), tableInfo.getTableName(),
          sqlSet(true, true, tableInfo, true, ENTITY, ENTITY_DOT),
          sqlWhereEntityWrapper(true, tableInfo), sqlComment());
      SqlSource sqlSource = super.createSqlSource(configuration, sql, modelClass);
      return this.addUpdateMappedStatement(mapperClass, modelClass, methodName, sqlSource);
  }
  ```

  他这里就回去设置sql的method为UPDATE，为后边的sql拼接做准备

- 然后`AbstractMethod`里面也有对不同的method编写不同的`addMappedStatement`的方法

##### injectMappedStatement

> 就是上面的m.inject()方法
>
> 负责为 MyBatis 的 Mapper 接口生成一个 `MappedStatement` 对象，该对象包含了插入操作所需的 SQL 语句及相关配置信息。

```java
public MappedStatement injectMappedStatement(Class<?> mapperClass, Class<?> modelClass, TableInfo tableInfo) {
    // keyGenerator：用于生成主键，默认是 NoKeyGenerator（表示不使用生成器）
    KeyGenerator keyGenerator = NoKeyGenerator.INSTANCE;
    
    // sqlMethod：SQL 方法类型，这里是插入操作（INSERT_ONE）
    SqlMethod sqlMethod = SqlMethod.INSERT_ONE;
    
    // columnScript：生成插入操作中列名部分的脚本
    String columnScript = SqlScriptUtils.convertTrim(tableInfo.getAllInsertSqlColumnMaybeIf(null, ignoreAutoIncrementColumn), LEFT_BRACKET, RIGHT_BRACKET, null, COMMA);
    
    // valuesScript：生成插入操作中值部分的脚本。
    String valuesScript = LEFT_BRACKET + NEWLINE + SqlScriptUtils.convertTrim(tableInfo.getAllInsertSqlPropertyMaybeIf(null, ignoreAutoIncrementColumn),
        null, null, null, COMMA) + NEWLINE + RIGHT_BRACKET;
    
    // 处理主键逻辑
    String keyProperty = null;
    String keyColumn = null;
    // 表包含主键处理逻辑,如果不包含主键当普通字段处理
    if (StringUtils.isNotBlank(tableInfo.getKeyProperty())) {
        if (tableInfo.getIdType() == IdType.AUTO) {
            /* 自增主键 */
            keyGenerator = Jdbc3KeyGenerator.INSTANCE;
            keyProperty = tableInfo.getKeyProperty();
            // 去除转义符
            keyColumn = SqlInjectionUtils.removeEscapeCharacter(tableInfo.getKeyColumn());
        } else if (null != tableInfo.getKeySequence()) {
            keyGenerator = TableInfoHelper.genKeyGenerator(methodName, tableInfo, builderAssistant);
            keyProperty = tableInfo.getKeyProperty();
            keyColumn = tableInfo.getKeyColumn();
        }
    }
    // 生成 SQL 语句
    String sql = String.format(sqlMethod.getSql(), tableInfo.getTableName(), columnScript, valuesScript);
    
    // 调用父类的方法创建 SqlSource 对象，该对象包含了解析后的 SQL 语句
    SqlSource sqlSource = super.createSqlSource(configuration, sql, modelClass);
    
    // 调用 addInsertMappedStatement 方法将所有信息添加到 MappedStatement 对象中，并返回该对象
    return this.addInsertMappedStatement(mapperClass, modelClass, methodName, sqlSource, keyGenerator, keyProperty, keyColumn);
}
```

- sql

  ```sql
  <script>
  INSERT INTO dept <trim prefix="(" suffix=")" suffixOverrides=",">
  <if test="deptno != null">deptno,</if>
  <if test="dname != null">dname,</if>
  <if test="dbSource != null">db_source,</if>
  </trim> VALUES (
  <trim suffixOverrides=",">
  <if test="deptno != null">#{deptno},</if>
  <if test="dname != null">#{dname},</if>
  <if test="dbSource != null">#{dbSource},</if>
  </trim>
  )
  </script>
  ```

- method.sql()

  ```sql
  <script>
  INSERT INTO %s %s VALUES %s
  </script>
  ```

- tableName

  ```sql
  dept
  ```

- columnScript

  ```sql
  <trim prefix="(" suffix=")" suffixOverrides=",">
  <if test="deptno != null">deptno,</if>
  <if test="dname != null">dname,</if>
  <if test="dbSource != null">db_source,</if>
  </trim>
  ```

- valuesScript

  ```sql
  (
  <trim suffixOverrides=",">
  <if test="deptno != null">#{deptno},</if>
  <if test="dname != null">#{dname},</if>
  <if test="dbSource != null">#{dbSource},</if>
  </trim>
  )
  ```

- MyBatis 使用 XML 配置文件中的 `<script>` 标签和一系列动态 SQL 标签（如 `<if>` 和 `<trim>`）来生成动态 SQL 语句。这个示例展示了如何根据条件动态生成一个插入语句（INSERT INTO）。

  下面详细解释一下这个示例中的每一部分：

  **示例解释**

  ```
  xml复制代码<script>
      INSERT INTO dept
      <trim prefix="(" suffix=")" suffixOverrides=",">
          <if test="deptno != null">deptno,</if>
          <if test="dname != null">dname,</if>
          <if test="dbSource != null">db_source,</if>
      </trim>
      VALUES (
      <trim suffixOverrides=",">
          <if test="deptno != null">#{deptno},</if>
          <if test="dname != null">#{dname},</if>
          <if test="dbSource != null">#{dbSource},</if>
      </trim>
      )
  </script>
  ```

  **`<script>` 标签**

  - `<script>` 标签是 MyBatis 中用于包含动态 SQL 的根标签。

  **`INSERT INTO dept`**

  - 这是一个基本的 SQL 插入语句的开始部分，表示要向 `dept` 表中插入数据。

  **`<trim>` 标签**

  - `<trim>` 标签用于动态地构建 SQL 片段，可以去除指定的前缀、后缀或多余的符号。

  **`prefix="(" suffix=")" suffixOverrides=","`**

  - `prefix="("` 和 `suffix=")"`：在生成的 SQL 片段前后添加括号 `(` 和 `)`。
  - `suffixOverrides=","`：去除生成的 SQL 片段末尾多余的逗号 `,`。

  **`<if>` 标签**

  - `<if>` 标签用于判断条件是否满足，如果条件为真，则包含该标签中的内容，否则不包含。

  **条件测试 `test="deptno != null"` 等**

  - 这些条件表示只有当 `deptno`、`dname` 或 `dbSource` 不为 `null` 时，才会将相应的字段名和字段值包含在生成的 SQL 中。

  **动态生成的列名和列值**

  - 第一部分 `<trim>` 标签内包含一系列 `<if>` 标签，用于动态生成要插入的列名（如 `deptno`、`dname`、`db_source`）。
  - 第二部分 `<trim>` 标签内包含一系列 `<if>` 标签，用于动态生成对应的列值（如 `#{deptno}`、`#{dname}`、`#{dbSource}`）。

  **示例生成的 SQL**

  假设传入的参数对象如下：

  ```java
  {
      deptno: 10,
      dname: "Sales",
      dbSource: null
  }
  ```

  则生成的 SQL 语句如下：

  ```sql
  INSERT INTO dept (deptno, dname) VALUES (#{deptno}, #{dname})
  ```

  如果传入的参数对象如下：

  ```java
  {
      deptno: 20,
      dname: null,
      dbSource: "db1"
  }
  ```

  则生成的 SQL 语句如下：

  ```sql
  INSERT INTO dept (deptno, db_source) VALUES (#{deptno}, #{dbSource})
  ```

  **结论**

  这个示例展示了 MyBatis 如何利用动态 SQL 标签来根据传入参数的不同，生成不同的 SQL 语句。这种方式可以极大地提高 SQL 语句的灵活性和可维护性。

##### addMappedStatement

> 用于将一个新的 `MappedStatement` 添加到 MyBatis 的 `Configuration` 中。`MappedStatement` 是 MyBatis 中一个核心概念，代表一个映射的 SQL 语句。

```java
protected MappedStatement addMappedStatement(Class<?> mapperClass, String id, SqlSource sqlSource,
                                                 SqlCommandType sqlCommandType, Class<?> parameterType,
                                                 String resultMap, Class<?> resultType, KeyGenerator keyGenerator,
                                                 String keyProperty, String keyColumn) {
    
    // 生成语句名并检查是否已经存在
    String statementName = mapperClass.getName() + DOT + id;
    if (hasMappedStatement(statementName)) {
        logger.warn(LEFT_SQ_BRACKET + statementName + "] Has been loaded by XML or SqlProvider or Mybatis's Annotation, so ignoring this injection for [" + getClass() + RIGHT_SQ_BRACKET);
        return null;
    }
    /* 缓存逻辑处理 */
    // isSelect: 检查 sqlCommandType 是否为 SELECT 类型，以便后续处理缓存逻辑
    boolean isSelect = sqlCommandType == SqlCommandType.SELECT;
    return builderAssistant.addMappedStatement(id, sqlSource, StatementType.PREPARED, sqlCommandType,
        null, null, null, parameterType, resultMap, resultType,
        null, !isSelect, isSelect, false, keyGenerator, keyProperty, keyColumn,
        configuration.getDatabaseId(), languageDriver, null);
}
```

##### addMappedStatement

> 用于向 MyBatis 的 `Configuration` 中添加一个新的 `MappedStatement`。`MappedStatement` 是 MyBatis 中用于描述一个映射的 SQL 语句的对象

```java
public MappedStatement addMappedStatement(String id, SqlSource sqlSource, StatementType statementType,
      SqlCommandType sqlCommandType, Integer fetchSize, Integer timeout, String parameterMap, Class<?> parameterType,
      String resultMap, Class<?> resultType, ResultSetType resultSetType, boolean flushCache, boolean useCache,
      boolean resultOrdered, KeyGenerator keyGenerator, String keyProperty, String keyColumn, String databaseId,
      LanguageDriver lang, String resultSets, boolean dirtySelect) {

    // 如果存在未解析的缓存引用，抛出异常。
    if (unresolvedCacheRef) {
      throw new IncompleteElementException("Cache-ref not yet resolved");
    }

    // 将 id 应用当前命名空间，以确保唯一性
    id = applyCurrentNamespace(id, false);
    
	// 创建一个 MappedStatement.Builder 对象
    //并设置各种属性，如 resource、fetchSize、timeout、statementType、keyGenerator 等等
    MappedStatement.Builder statementBuilder = new MappedStatement.Builder(configuration, id, sqlSource, sqlCommandType)
        .resource(resource).fetchSize(fetchSize).timeout(timeout).statementType(statementType)
  .keyGenerator(keyGenerator).keyProperty(keyProperty).keyColumn(keyColumn).databaseId(databaseId).lang(lang)
        .resultOrdered(resultOrdered).resultSets(resultSets)
        .resultMaps(getStatementResultMaps(resultMap, resultType, id)).resultSetType(resultSetType)
        .flushCacheRequired(flushCache).useCache(useCache).cache(currentCache).dirtySelect(dirtySelect);

    // 获取参数映射对象 ParameterMap 并设置到 statementBuilder 中
    ParameterMap statementParameterMap = getStatementParameterMap(parameterMap, parameterType, id);
    if (statementParameterMap != null) {
      statementBuilder.parameterMap(statementParameterMap);
    }

    // 构建并添加 MappedStatement
    MappedStatement statement = statementBuilder.build();
    configuration.addMappedStatement(statement);
    return statement;
}
```



### Table部分

#### 方法

##### InitTableInfo

> 用于初始化和缓存表信息的一个静态同步方法。它检查是否已经为给定的类初始化了表信息，如果没有，则进行初始化。如果已经存在但属于不同的 `Configuration` 实例，也会重新初始化。

```java
public static synchronized TableInfo initTableInfo(MapperBuilderAssistant builderAssistant, Class<?> clazz) {
    // 从缓存中获取类的表信息
    TableInfo targetTableInfo = TABLE_INFO_CACHE.get(clazz);
    // 获取当前的 Configuration 实例
    final Configuration configuration = builderAssistant.getConfiguration();
    
    // 如果缓存中存在表信息
    if (targetTableInfo != null) {
        // 获取缓存的表信息所属的 Configuration 实例
        Configuration oldConfiguration = targetTableInfo.getConfiguration();
        // 如果不是同一个 Configuration 实例，重新初始化表信息
        if (!oldConfiguration.equals(configuration)) {
            targetTableInfo = initTableInfo(configuration, builderAssistant.getCurrentNamespace(), clazz);
        }
        // 返回缓存的表信息
        return targetTableInfo;
    }
    // 如果缓存中不存在表信息，初始化表信息并返回
    return initTableInfo(configuration, builderAssistant.getCurrentNamespace(), clazz);
}

```

##### InitTableInfo

> 负责为给定类初始化 `TableInfo` 对象，并缓存这些信息。该方法处理表名、字段、ResultMap 等相关信息的初始化，并确保在初始化完成后将结果缓存。	

```java
private static synchronized TableInfo initTableInfo(Configuration configuration, String currentNamespace, Class<?> clazz) {
    
    // 从 Configuration 中获取全局配置对象 GlobalConfig，并从中获取 PostInitTableInfoHandler 后处理器
    GlobalConfig globalConfig = GlobalConfigUtils.getGlobalConfig(configuration);
    PostInitTableInfoHandler postInitTableInfoHandler = globalConfig.getPostInitTableInfoHandler();
    
    /* 没有获取到缓存信息,则初始化 */
    //使用后处理器创建 TableInfo 对象，并设置当前命名空间。
    TableInfo tableInfo = postInitTableInfoHandler.creteTableInfo(configuration, clazz);
    tableInfo.setCurrentNamespace(currentNamespace);

    /* 初始化表名相关 */
    // 调用 initTableName 方法初始化表名相关信息，并返回需要排除的属性。将这些属性转换成列表，以便后续处理。
    final String[] excludeProperty = initTableName(clazz, globalConfig, tableInfo);

    List<String> excludePropertyList = excludeProperty != null && excludeProperty.length > 0 ? Arrays.asList(excludeProperty) : Collections.emptyList();

    /* 初始化字段相关 */
    // 调用 initTableFields 方法初始化表的字段信息，传递配置、类、全局配置、TableInfo 对象和需要排除的属性列表。
    initTableFields(configuration, clazz, globalConfig, tableInfo, excludePropertyList);

    /* 自动构建 resultMap */
    tableInfo.initResultMapIfNeed();
    postInitTableInfoHandler.postTableInfo(tableInfo, configuration);
    TABLE_INFO_CACHE.put(clazz, tableInfo);
    TABLE_NAME_INFO_CACHE.put(tableInfo.getTableName(), tableInfo);

    /* 缓存 lambda */
    LambdaUtils.installCache(tableInfo);
    return tableInfo;
}
```

##### InitTableTame

> 负责初始化一个类对应的数据库表名及相关信息，并更新 `TableInfo` 对象。该方法主要根据类上的注解和全局配置来确定最终的表名、表前缀、模式（schema）等信息，并设置这些信息到 `TableInfo` 对象中。

```java
private static String[] initTableName(Class<?> clazz, GlobalConfig globalConfig, TableInfo tableInfo) {
    /* 数据库全局配置 */
    // 通过全局配置对象 globalConfig 获取数据库配置 DbConfig 和注解处理器 AnnotationHandler。
    GlobalConfig.DbConfig dbConfig = globalConfig.getDbConfig();
    AnnotationHandler annotationHandler = globalConfig.getAnnotationHandler();
    TableName table = annotationHandler.getAnnotation(clazz, TableName.class);

    
    // 初始化表名为类名的简单名，获取全局配置中的表前缀和模式，设置表前缀有效性标志为 true，并初始化排除属性数组。
    String tableName = clazz.getSimpleName();
    String tablePrefix = dbConfig.getTablePrefix();
    String schema = dbConfig.getSchema();
    boolean tablePrefixEffect = true;
    String[] excludeProperty = null;

    // 如果注解中定义了表名，则使用注解中的表名，并根据配置决定是否保留全局表前缀。
    if (table != null) {
        if (StringUtils.isNotBlank(table.value())) {
            tableName = table.value();
            if (StringUtils.isNotBlank(tablePrefix) && !table.keepGlobalPrefix()) {
                tablePrefixEffect = false;
            }
        } else {
            // 如果注解中没有定义表名，则调用 initTableNameWithDbConfig 方法根据全局配置初始化表名。
            tableName = initTableNameWithDbConfig(tableName, dbConfig);
        }
        // 如果注解中定义了 schema，则覆盖全局配置中的 schema。
        if (StringUtils.isNotBlank(table.schema())) {
            schema = table.schema();
        }
        /* 表结果集映射 */
        // 如果注解中定义了 resultMap，则设置 TableInfo 对象的 resultMap 属性。
        if (StringUtils.isNotBlank(table.resultMap())) {
            tableInfo.setResultMap(table.resultMap());
        }
        
        // 设置 TableInfo 对象是否自动初始化 resultMap 以及排除的属性。
        tableInfo.setAutoInitResultMap(table.autoResultMap());
        excludeProperty = table.excludeProperty();
    } else {
        tableName = initTableNameWithDbConfig(tableName, dbConfig);
    }

    // 表追加前缀
    String targetTableName = tableName;
    if (StringUtils.isNotBlank(tablePrefix) && tablePrefixEffect) {
        targetTableName = tablePrefix + targetTableName;
    }

    // 表格式化
    String tableFormat = dbConfig.getTableFormat();
    if (StringUtils.isNotBlank(tableFormat)) {
        targetTableName = String.format(tableFormat, targetTableName);
    }

    // 表追加 schema 信息
    if (StringUtils.isNotBlank(schema)) {
        targetTableName = schema + StringPool.DOT + targetTableName;
    }

    tableInfo.setTableName(targetTableName);

    /* 开启了自定义 KEY 生成器 */
    if (CollectionUtils.isNotEmpty(dbConfig.getKeyGenerators())) {
        tableInfo.setKeySequence(annotationHandler.getAnnotation(clazz, KeySequence.class));
    }
    return excludeProperty;
}
```

## sql调用

> 大概就是通过动态代理和反射去调用函数，然后最终获得mappedStatement，再根据实际情况将参数加进原本的sql模板中
>
> 最后再进行查询

### 方法

#### DefaultSqlSession

> 不论是selectOne，还是list，都会到这边来

```java
private <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds, ResultHandler handler) {
    try {
      // 从configuration中获得mappedStatement
      // statement="com.cy.sbt.mapper.DeptMapper.selectList"
      // 和前面addStatement呼应起来了
      MappedStatement ms = configuration.getMappedStatement(statement);
      dirty |= ms.isDirtySelect();
        
      // 这里调用后会进入插件的Intecepter的拦截
      return executor.query(ms, wrapCollection(parameter), rowBounds, handler);
    } catch (Exception e) {
      throw ExceptionFactory.wrapException("Error querying database.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
}
```

### 插件

> 当执行`executor.query`时会被拦截，并执行拦截器的方法。
>
> 有点像动态代理吧，还是说就是哈哈

```java
public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
    try {
      Set<Method> methods = signatureMap.get(method.getDeclaringClass());
      if (methods != null && methods.contains(method)) {
          // 调用拦截器的方法
			return interceptor.intercept(new Invocation(target, method, args));
      }
      return method.invoke(target, args);
    } catch (Exception e) {
      throw ExceptionUtil.unwrapThrowable(e);
    }
}
```

**又好像不是哦**

> 上面有点像是总的拦截住，然后这个方法再去调用拦截器集合`List<InnerInterceptor> interceptors`，再依次调用
>
> 这个函数在`MybatisPlusInterceptor`中

```java
public Object intercept(Invocation invocation) throws Throwable {
    Object target = invocation.getTarget();
    Object[] args = invocation.getArgs();
    if (target instanceof Executor) {
        final Executor executor = (Executor) target;
        Object parameter = args[1];
        boolean isUpdate = args.length == 2;
        MappedStatement ms = (MappedStatement) args[0];
        if (!isUpdate && ms.getSqlCommandType() == SqlCommandType.SELECT) {
            RowBounds rowBounds = (RowBounds) args[2];
            ResultHandler resultHandler = (ResultHandler) args[3];
            BoundSql boundSql;
            if (args.length == 4) {
                boundSql = ms.getBoundSql(parameter);
            } else {
                // 几乎不可能走进这里面,除非使用Executor的代理对象调用query[args[6]]
                boundSql = (BoundSql) args[5];
            }
            // 挨个调用拦截器
            for (InnerInterceptor query : interceptors) {
                if (!query.willDoQuery(executor, ms, parameter, rowBounds, resultHandler, boundSql)) {
                    return Collections.emptyList();
                }
                query.beforeQuery(executor, ms, parameter, rowBounds, resultHandler, boundSql);
            }
            CacheKey cacheKey = executor.createCacheKey(ms, parameter, rowBounds, boundSql);
            return executor.query(ms, parameter, rowBounds, resultHandler, cacheKey, boundSql);
        } else if (isUpdate) {
            // 挨个调用拦截器
            for (InnerInterceptor update : interceptors) {
                if (!update.willDoUpdate(executor, ms, parameter)) {
                    return -1;
                }
                update.beforeUpdate(executor, ms, parameter);
            }
        }
    } else {
        // StatementHandler
        final StatementHandler sh = (StatementHandler) target;
        // 目前只有StatementHandler.getBoundSql方法args才为null
        if (null == args) {
            for (InnerInterceptor innerInterceptor : interceptors) {
                innerInterceptor.beforeGetBoundSql(sh);
            }
        } else {
            Connection connections = (Connection) args[0];
            Integer transactionTimeout = (Integer) args[1];
            
            // 挨个调用拦截器
            for (InnerInterceptor innerInterceptor : interceptors) {
                innerInterceptor.beforePrepare(sh, connections, transactionTimeout);
            }
        }
    }
    return invocation.proceed();
}
```

