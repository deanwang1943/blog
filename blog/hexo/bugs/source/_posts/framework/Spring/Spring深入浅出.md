
## IOC 之深入理解 Spring IoC

IoC 全称为 Inversion of Control，翻译为 “控制反转”，它还有一个别名为 DI（Dependency Injection）,即依赖注入。

> 所谓 IOC ，就是由 Spring IOC 容器来负责对象的生命周期和对象之间的关系

简单点说，IoC 的理念就是让别人为你服务,在没有引入 IoC 的时候，被注入的对象直接依赖于被依赖的对象，有了 IoC 后，两者及其他们的关系都是通过 Ioc Service Provider 来统一管理维护的。

> IOC Service Provider 为被注入对象提供被依赖对象也有如下几种方式：构造方法注入、stter方法注入、接口注入。

```java
// 构造方法注入
YoungMan(BeautifulGirl beautifulGirl){
        this.beautifulGirl = beautifulGirl;
}
```

```java
// stter方法注入
public class YoungMan {
    private BeautifulGirl beautifulGirl;

    public void setBeautifulGirl(BeautifulGirl beautifulGirl) {
        this.beautifulGirl = beautifulGirl;
    }
}

//相比于构造器注入，setter 方式注入会显得比较宽松灵活些
```
* 各个组件

![](https://gitee.com/chenssy/blog-home/raw/master/image/201811/spring-201805091002.jpg)

该图为 ClassPathXmlApplicationContext 的类继承体系结构，虽然只有一部分，但是它基本上包含了 IOC 体系中大部分的核心类和接口。

### Resource体系

Resource，对资源的抽象，它的每一个实现类都代表了一种资源的访问策略，如ClasspathResource 、 URLResource ，FileSystemResource 等。

![](https://gitee.com/chenssy/blog-home/raw/master/image/201811/spring-201805091003.jpg)

有了资源，就应该有资源加载，Spring 利用 ResourceLoader 来进行统一资源加载，类图如下：

![](https://gitee.com/chenssy/blog-home/raw/master/image/201811/spring-201805091004.png)

### BeanFactory 体系

BeanFactory 是一个非常纯粹的 bean 容器，它是 IOC 必备的数据结构，其中 BeanDefinition 是她的基本结构，它内部维护着一个 BeanDefinition map ，并可根据 BeanDefinition 的描述进行 bean 的创建和管理。

![](https://gitee.com/chenssy/blog-home/raw/master/image/201811/spring-201805101001.png)

BeanFacoty 有三个直接子类 ListableBeanFactory、HierarchicalBeanFactory 和 AutowireCapableBeanFactory，DefaultListableBeanFactory 为最终默认实现，它实现了所有接口。

### Beandefinition 体系

> BeanDefinition 用来描述 Spring 中的 Bean 对象。

### BeandefinitionReader体系

> BeanDefinitionReader 的作用是读取 Spring 的配置文件的内容，并将其转换成 Ioc 容器内部的数据结构：BeanDefinition。

### ApplicationContext体系

应用上下文,继承 BeanFactory

它与 BeanFactory 的不同，其主要区别有：

* 继承 MessageSource，提供国际化的标准访问策略。
* 继承 ApplicationEventPublisher ，提供强大的事件机制。
* 扩展 ResourceLoader，可以用来加载多个 Resource，可以灵活访问不同的资源。
* 对 Web 应用的支持。

![](https://gitee.com/chenssy/blog-home/raw/master/image/201811/spring-201805101004.png)


## IOC 之 加载 Bean

```java
// 获取资源
ClassPathResource resource = new ClassPathResource("bean.xml");
// 获取 BeanFactory
DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
// 根据新建的 BeanFactory 创建一个BeanDefinitionReader对象，该Reader 对象为资源的解析器
XmlBeanDefinitionReader reader = new XmlBeanDefinitionReader(factory);
// 装载资源 整个过程就分为三个步骤：资源定位、装载、注册
reader.loadBeanDefinitions(resource);
```

`reader.loadBeanDefinitions(resource)` 才是加载资源的真正实现

```java
// 对 Resource 进行编码，保证内容读取的正确性。封装成 EncodedResource 
public int loadBeanDefinitions(Resource resource) throws BeanDefinitionStoreException {
    return loadBeanDefinitions(new EncodedResource(resource));
}
```

```java
public int loadBeanDefinitions(EncodedResource encodedResource) throws BeanDefinitionStoreException {
        Assert.notNull(encodedResource, "EncodedResource must not be null");
        if (logger.isInfoEnabled()) {
            logger.info("Loading XML bean definitions from " + encodedResource.getResource());
        }

        // 获取已经加载过的资源
        Set<EncodedResource> currentResources = this.resourcesCurrentlyBeingLoaded.get();
        if (currentResources == null) {
            currentResources = new HashSet<>(4);
            this.resourcesCurrentlyBeingLoaded.set(currentResources);
        }

        // 将当前资源加入记录中
        if (!currentResources.add(encodedResource)) {
            throw new BeanDefinitionStoreException(
                    "Detected cyclic loading of " + encodedResource + " - check your import definitions!");
        }
        try {
            // 从 EncodedResource 获取封装的 Resource 并从 Resource 中获取其中的 InputStream
            InputStream inputStream = encodedResource.getResource().getInputStream();
            try {
                InputSource inputSource = new InputSource(inputStream);
                // 设置编码
                if (encodedResource.getEncoding() != null) {
                    inputSource.setEncoding(encodedResource.getEncoding());
                }
                // 核心逻辑部分
                return doLoadBeanDefinitions(inputSource, encodedResource.getResource());
            }
            finally {
                inputStream.close();
            }
        }
        catch (IOException ex) {
            throw new BeanDefinitionStoreException(
                    "IOException parsing XML document from " + encodedResource.getResource(), ex);
        }
        finally {
            // 从缓存中剔除该资源
            currentResources.remove(encodedResource);
            if (currentResources.isEmpty()) {
                this.resourcesCurrentlyBeingLoaded.remove();
            }
        }
    }
```

方法 doLoadBeanDefinitions() 为从 xml 文件中加载 Bean Definition 的真正逻辑

```java
protected int doLoadBeanDefinitions(InputSource inputSource, Resource resource)
            throws BeanDefinitionStoreException {
        try {
            // 获取 Document 实例
            Document doc = doLoadDocument(inputSource, resource);
            // 根据 Document 实例****注册 Bean信息
            return registerBeanDefinitions(doc, resource);
        }
        catch (BeanDefinitionStoreException ex) {
            throw ex;
        }
        catch (SAXParseException ex) {
            throw new XmlBeanDefinitionStoreException(resource.getDescription(),
                    "Line " + ex.getLineNumber() + " in XML document from " + resource + " is invalid", ex);
        }
        catch (SAXException ex) {
            throw new XmlBeanDefinitionStoreException(resource.getDescription(),
                    "XML document from " + resource + " is invalid", ex);
        }
        catch (ParserConfigurationException ex) {
            throw new BeanDefinitionStoreException(resource.getDescription(),
                    "Parser configuration exception parsing XML from " + resource, ex);
        }
        catch (IOException ex) {
            throw new BeanDefinitionStoreException(resource.getDescription(),
                    "IOException parsing XML document from " + resource, ex);
        }
        catch (Throwable ex) {
            throw new BeanDefinitionStoreException(resource.getDescription(),
                    "Unexpected exception parsing XML document from " + resource, ex);
        }
    }
```

核心部分就是 try 块的两行代码。
1. 调用 doLoadDocument() 方法，根据 xml 文件获取 Document 实例。
2. 根据获取的 Document 实例注册 Bean 信息。

doLoadBeanDefinitions()主要就是做了三件事情。
1. 调用 getValidationModeForResource() 获取 xml 文件的验证模式
2. 调用 loadDocument() 根据 xml 文件获取相应的 Document 实例。
3. 调用 registerBeanDefinitions() 注册 Bean 实例。

###

```java
public int registerBeanDefinitions(Document doc, Resource resource) throws BeanDefinitionStoreException {
    BeanDefinitionDocumentReader documentReader = createBeanDefinitionDocumentReader();
    int countBefore = getRegistry().getBeanDefinitionCount();
    documentReader.registerBeanDefinitions(doc, createReaderContext(resource));
    return getRegistry().getBeanDefinitionCount() - countBefore;
}
```

DefaultBeanDefinitionDocumentReader 对该方法提供了实现：

```java
public void registerBeanDefinitions(Document doc, XmlReaderContext readerContext) {
    this.readerContext = readerContext;
    logger.debug("Loading bean definitions");
    Element root = doc.getDocumentElement();
    doRegisterBeanDefinitions(root);
}
```

调用 doRegisterBeanDefinitions() 开启注册 BeanDefinition 之旅。

```java
protected void doRegisterBeanDefinitions(Element root) {
        BeanDefinitionParserDelegate parent = this.delegate;
        this.delegate = createDelegate(getReaderContext(), root, parent);

        if (this.delegate.isDefaultNamespace(root)) {
              // 处理 profile
            String profileSpec = root.getAttribute(PROFILE_ATTRIBUTE);
            if (StringUtils.hasText(profileSpec)) {
                String[] specifiedProfiles = StringUtils.tokenizeToStringArray(
                        profileSpec, BeanDefinitionParserDelegate.MULTI_VALUE_ATTRIBUTE_DELIMITERS);
                if (!getReaderContext().getEnvironment().acceptsProfiles(specifiedProfiles)) {
                    if (logger.isInfoEnabled()) {
                        logger.info("Skipped XML bean definition file due to specified profiles [" + profileSpec +
                                "] not matching: " + getReaderContext().getResource());
                    }
                    return;
                }
            }
        }

      // 解析前处理
        preProcessXml(root);
        // 解析
        parseBeanDefinitions(root, this.delegate);
        // 解析后处理
        postProcessXml(root);

        this.delegate = parent;
    }
```

```java
protected void parseBeanDefinitions(Element root, BeanDefinitionParserDelegate delegate) {
        if (delegate.isDefaultNamespace(root)) {
            NodeList nl = root.getChildNodes();
            for (int i = 0; i < nl.getLength(); i++) {
                Node node = nl.item(i);
                if (node instanceof Element) {
                    Element ele = (Element) node;
                    if (delegate.isDefaultNamespace(ele)) {
                        parseDefaultElement(ele, delegate);
                    }
                    else {
                        delegate.parseCustomElement(ele);
                    }
                }
            }
        }
        else {
            delegate.parseCustomElement(root);
        }
    }
```

最终解析动作落地在两个方法处：`parseDefaultElement(ele, delegate)` 和 `delegate.parseCustomElement(root)`。我们知道在 Spring 有两种 Bean 声明方式：

配置文件式声明：`<bean id="studentService" class="org.springframework.core.StudentService"/>`

自定义注解方式：`<tx:annotation-driven>`

两种方式的读取和解析都存在较大的差异，所以采用不同的解析方法，如果根节点或者子节点采用默认命名空间的话，则调用 parseDefaultElement() 进行解析，否则调用 delegate.parseCustomElement() 方法进行自定义解析。

> Bean 的解析过程已经全部完成了，下面做一个简要的总结。

解析 BeanDefinition 的入口在 DefaultBeanDefinitionDocumentReader.parseBeanDefinitions() 。该方法会根据命令空间来判断标签是默认标签还是自定义标签，其中默认标签由 parseDefaultElement() 实现，自定义标签由 parseCustomElement() 实现。在默认标签解析中，会根据标签名称的不同进行 import 、alias 、bean 、beans 四大标签进行处理，其中 bean 标签的解析为核心，它由 processBeanDefinition() 方法实现。processBeanDefinition() 开始进入解析核心工作，分为三步：

1. 解析默认标签：BeanDefinitionParserDelegate.parseBeanDefinitionElement()
2. 解析默认标签下的自定义标签：BeanDefinitionParserDelegate.decorateBeanDefinitionIfRequired()
3. 注册解析的 BeanDefinition：BeanDefinitionReaderUtils.registerBeanDefinition

在默认标签解析过程中，核心工作由 parseBeanDefinitionElement() 方法实现，该方法会依次解析 Bean 标签的属性、各个子元素，解析完成后返回一个 GenericBeanDefinition 实例对象。

注册过程也不是那么的高大上，就是利用一个 Map 的集合对象来存放，key 是 beanName，value 是 BeanDefinition。

从 Bean 资源的定位，转换为 Document 对象，接着对其进行解析，最后注册到 IOC 容器中，都已经完美地完成了。现在 IOC 容器中已经建立了整个 Bean 的配置信息，这些 Bean 可以被检索、使用、维护，他们是控制反转的基础，是后面注入 Bean 的依赖。

## IOC 之开启 bean 的加载

```java
public Object getBean(String name) throws BeansException {
    return doGetBean(name, null, null, false);
}
```
* name：要获取 bean 的名字
* requiredType：要获取 bean 的类型
* args：创建 bean 时传递的参数。这个参数仅限于创建 bean 时使用
* typeCheckOnly：是否为类型检查

```java
 protected <T> T doGetBean(final String name, @Nullable final Class<T> requiredType,
                              @Nullable final Object[] args, boolean typeCheckOnly) throws BeansException {

        // 获取 beanName，这里是一个转换动作，将 name 转换Wie beanName, 不一定就是 beanName，可能是 aliasName，也有可能是 FactoryBean，所以这里需要调用 transformedBeanName() 方法对 name 进行一番转换
        final String beanName = transformedBeanName(name);
        Object bean;

        // 从缓存中或者实例工厂中获取 bean
        // *** 这里会涉及到解决循环依赖 bean 的问题
        Object sharedInstance = getSingleton(beanName);
        if (sharedInstance != null && args == null) {
            if (logger.isDebugEnabled()) {
                if (isSingletonCurrentlyInCreation(beanName)) {
                    logger.debug("Returning eagerly cached instance of singleton bean '" + beanName +
                            "' that is not fully initialized yet - a consequence of a circular reference");
                }
                else {
                    logger.debug("Returning cached instance of singleton bean '" + beanName + "'");
                }
            }
            bean = getObjectForBeanInstance(sharedInstance, name, beanName, null);
        }

        else {

            // 因为 Spring 只解决单例模式下得循环依赖，在原型模式下如果存在循环依赖则会抛出异常
            // **关于循环依赖后续会单独出文详细说明**
            if (isPrototypeCurrentlyInCreation(beanName)) {
                throw new BeanCurrentlyInCreationException(beanName);
            }

            // 如果容器中没有找到，则从父类容器中加载
            BeanFactory parentBeanFactory = getParentBeanFactory();
            if (parentBeanFactory != null && !containsBeanDefinition(beanName)) {
                String nameToLookup = originalBeanName(name);
                if (parentBeanFactory instanceof AbstractBeanFactory) {
                    return ((AbstractBeanFactory) parentBeanFactory).doGetBean(
                            nameToLookup, requiredType, args, typeCheckOnly);
                }
                else if (args != null) {
                    return (T) parentBeanFactory.getBean(nameToLookup, args);
                }
                else {
                    return parentBeanFactory.getBean(nameToLookup, requiredType);
                }
            }

            // 如果不是仅仅做类型检查则是创建bean，这里需要记录
            if (!typeCheckOnly) {
                markBeanAsCreated(beanName);
            }

            try {
                // 从容器中获取 beanName 相应的 GenericBeanDefinition，并将其转换为 RootBeanDefinition
                final RootBeanDefinition mbd = getMergedLocalBeanDefinition(beanName);

                // 检查给定的合并的 BeanDefinition
                checkMergedBeanDefinition(mbd, beanName, args);

                // 处理所依赖的 bean
                String[] dependsOn = mbd.getDependsOn();
                if (dependsOn != null) {
                    for (String dep : dependsOn) {
                        // 若给定的依赖 bean 已经注册为依赖给定的b ean
                        // 循环依赖的情况
                        if (isDependent(beanName, dep)) {
                            throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                                    "Circular depends-on relationship between '" + beanName + "' and '" + dep + "'");
                        }
                        // 缓存依赖调用
                        registerDependentBean(dep, beanName);
                        try {
                            getBean(dep);
                        }
                        catch (NoSuchBeanDefinitionException ex) {
                            throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                                    "'" + beanName + "' depends on missing bean '" + dep + "'", ex);
                        }
                    }
                }

                // bean 实例化
                // 单例模式
                if (mbd.isSingleton()) {
                    sharedInstance = getSingleton(beanName, () -> {
                        try {
                            return createBean(beanName, mbd, args);
                        }
                        catch (BeansException ex) {
                            // 显示从单利缓存中删除 bean 实例
                            // 因为单例模式下为了解决循环依赖，可能他已经存在了，所以销毁它
                            destroySingleton(beanName);
                            throw ex;
                        }
                    });
                    bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
                }

                // 原型模式
                else if (mbd.isPrototype()) {
                    // It's a prototype -> create a new instance.
                    Object prototypeInstance = null;
                    try {
                        beforePrototypeCreation(beanName);
                        prototypeInstance = createBean(beanName, mbd, args);
                    }
                    finally {
                        afterPrototypeCreation(beanName);
                    }
                    bean = getObjectForBeanInstance(prototypeInstance, name, beanName, mbd);
                }

                else {
                    // 从指定的 scope 下创建 bean
                    String scopeName = mbd.getScope();
                    final Scope scope = this.scopes.get(scopeName);
                    if (scope == null) {
                        throw new IllegalStateException("No Scope registered for scope name '" + scopeName + "'");
                    }
                    try {
                        Object scopedInstance = scope.get(beanName, () -> {
                            beforePrototypeCreation(beanName);
                            try {
                                return createBean(beanName, mbd, args);
                            }
                            finally {
                                afterPrototypeCreation(beanName);
                            }
                        });
                        bean = getObjectForBeanInstance(scopedInstance, name, beanName, mbd);
                    }
                    catch (IllegalStateException ex) {
                        throw new BeanCreationException(beanName,
                                "Scope '" + scopeName + "' is not active for the current thread; consider " +
                                        "defining a scoped proxy for this bean if you intend to refer to it from a singleton",
                                ex);
                    }
                }
            }
            catch (BeansException ex) {
                cleanupAfterBeanCreationFailure(beanName);
                throw ex;
            }
        }

        // 检查需要的类型是否符合 bean 的实际类型
        if (requiredType != null && !requiredType.isInstance(bean)) {
            try {
                T convertedBean = getTypeConverter().convertIfNecessary(bean, requiredType);
                if (convertedBean == null) {
                    throw new BeanNotOfRequiredTypeException(name, requiredType, bean.getClass());
                }
                return convertedBean;
            }
            catch (TypeMismatchException ex) {
                if (logger.isDebugEnabled()) {
                    logger.debug("Failed to convert bean '" + name + "' to required type '" +
                            ClassUtils.getQualifiedName(requiredType) + "'", ex);
                }
                throw new BeanNotOfRequiredTypeException(name, requiredType, bean.getClass());
            }
        }
        return (T) bean;
    }
```

> Spring 只处理单例模式下得循环依赖，对于原型模式的循环依赖直接抛出异常。主要原因还是在于 Spring 解决循环依赖的策略有关。对于单例模式 Spring 在创建 bean 的时候并不是等 bean 完全创建完成后才会将 bean 添加至缓存中，而是不等 bean 创建完成就会将创建 bean 的 ObjectFactory 提早加入到缓存中，这样一旦下一个 bean 创建的时候需要依赖 bean 时则直接使用 ObjectFactroy。但是原型模式我们知道是没法使用缓存的，所以 Spring 对原型模式的循环依赖处理策略则是不处理

每个 bean 都不是单独工作的，它会依赖其他 bean，其他 bean 也会依赖它，对于依赖的 bean ，它会优先加载，所以在 Spring 的加载顺序中，在初始化某一个 bean 的时候首先会初始化这个 bean 的依赖。

### IOC 之构造函数实例化 bean

createBeanInstance() 用于实例化 bean，它会根据不同情况选择不同的实例化策略来完成 bean 的初始化，主要包括：

1. Supplier 回调：obtainFromSupplier()
2. 工厂方法初始化：instantiateUsingFactoryMethod()
3. 构造函数自动注入初始化：autowireConstructor()
4. 默认构造函数注入：instantiateBean()

### 循环依赖

> 对于构造器的循环依赖，Spring 是无法解决的，只能抛出 BeanCurrentlyInCreationException 异常表示循环依赖，所以下面我们分析的都是基于 field 属性的循环依赖。

* singletonObjects：单例对象的cache
* singletonFactories ： 单例对象工厂的cache
* earlySingletonObjects ：提前暴光的单例对象的Cache

他们就是 Spring 解决 singleton bean 的关键因素所在，我称他们为三级缓存，第一级为 singletonObjects，第二级为 earlySingletonObjects，第三级为 singletonFactories。

看出 singletonFactories 这个三级缓存才是解决 Spring Bean 循环依赖的诀窍所在。同时这段代码发生在 createBeanInstance() 方法之后，也就是说这个 bean 其实已经被创建出来了，但是它还不是很完美（没有进行属性填充和初始化），但是对于其他依赖它的对象而言已经足够了（可以根据对象引用定位到堆中对象）

循环依赖 Spring 解决的过程：首先 A 完成初始化第一步并将自己提前曝光出来（通过 ObjectFactory 将自己提前曝光），在初始化的时候，发现自己依赖对象 B，此时就会去尝试 get(B)，这个时候发现 B 还没有被创建出来，然后 B 就走创建流程，在 B 初始化的时候，同样发现自己依赖 C，C 也没有被创建出来，这个时候 C 又开始初始化进程，但是在初始化的过程中发现自己依赖 A，于是尝试 get(A)，这个时候由于 A 已经添加至缓存中（一般都是添加至三级缓存 singletonFactories ），通过 ObjectFactory 提前曝光，所以可以通过 ObjectFactory.getObject() 拿到 A 对象，C 拿到 A 对象后顺利完成初始化，然后将自己添加到一级缓存中，回到 B ，B 也可以拿到 C 对象，完成初始化，A 可以顺利拿到 B 完成初始化。到这里整个链路就已经完成了初始化过程了。

### IOC 之 属性填充

doCreateBean() 主要用于完成 bean 的创建和初始化工作，我们可以将其分为四个过程：

1. createBeanInstance() 实例化 bean
2. populateBean() 属性填充
3. 循环依赖的处理
4. initializeBean() 初始化 bean

```java
protected void populateBean(String beanName, RootBeanDefinition mbd, @Nullable BeanWrapper bw) {
        // 没有实例化对象
        if (bw == null) {
            // 有属性抛出异常
            if (mbd.hasPropertyValues()) {
                throw new BeanCreationException(
                        mbd.getResourceDescription(), beanName, "Cannot apply property values to null instance");
            }
            else {
                // 没有属性直接返回
                return;
            }
        }

        // 在设置属性之前给 InstantiationAwareBeanPostProcessors 最后一次改变 bean 的机会
        boolean continueWithPropertyPopulation = true;

        // bena 不是"合成"的，即未由应用程序本身定义
        // 是否持有 InstantiationAwareBeanPostProcessor
        if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
            // 迭代所有的 BeanPostProcessors
            for (BeanPostProcessor bp : getBeanPostProcessors()) {
                // 如果为 InstantiationAwareBeanPostProcessor
                if (bp instanceof InstantiationAwareBeanPostProcessor) {
                    InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
                    // 返回值为是否继续填充 bean
                    // postProcessAfterInstantiation：如果应该在 bean上面设置属性则返回true，否则返回false
                    // 一般情况下，应该是返回true，返回 false 的话，
                    // 将会阻止在此 Bean 实例上调用任何后续的 InstantiationAwareBeanPostProcessor 实例。
                    if (!ibp.postProcessAfterInstantiation(bw.getWrappedInstance(), beanName)) {
                        continueWithPropertyPopulation = false;
                        break;
                    }
                }
            }
        }

        // 如果后续处理器发出停止填充命令，则终止后续操作
        if (!continueWithPropertyPopulation) {
            return;
        }

        // bean 的属性值
        PropertyValues pvs = (mbd.hasPropertyValues() ? mbd.getPropertyValues() : null);

        if (mbd.getResolvedAutowireMode() == RootBeanDefinition.AUTOWIRE_BY_NAME ||
                mbd.getResolvedAutowireMode() == RootBeanDefinition.AUTOWIRE_BY_TYPE) {

            // 将 PropertyValues 封装成 MutablePropertyValues 对象
            // MutablePropertyValues 允许对属性进行简单的操作，
            // 并提供构造函数以支持Map的深度复制和构造。
            MutablePropertyValues newPvs = new MutablePropertyValues(pvs);

            // 根据名称自动注入
            if (mbd.getResolvedAutowireMode() == RootBeanDefinition.AUTOWIRE_BY_NAME) {
                autowireByName(beanName, mbd, bw, newPvs);
            }

            // 根据类型自动注入
            if (mbd.getResolvedAutowireMode() == RootBeanDefinition.AUTOWIRE_BY_TYPE) {
                autowireByType(beanName, mbd, bw, newPvs);
            }

            pvs = newPvs;
        }

        // 是否已经注册了 InstantiationAwareBeanPostProcessors
        boolean hasInstAwareBpps = hasInstantiationAwareBeanPostProcessors();
        // 是否需要进行依赖检查
        boolean needsDepCheck = (mbd.getDependencyCheck() != RootBeanDefinition.DEPENDENCY_CHECK_NONE);

        if (hasInstAwareBpps || needsDepCheck) {
            if (pvs == null) {
                pvs = mbd.getPropertyValues();
            }

            // 从 bw 对象中提取 PropertyDescriptor 结果集
            // PropertyDescriptor：可以通过一对存取方法提取一个属性
            PropertyDescriptor[] filteredPds = filterPropertyDescriptorsForDependencyCheck(bw, mbd.allowCaching);
            if (hasInstAwareBpps) {
                for (BeanPostProcessor bp : getBeanPostProcessors()) {
                    if (bp instanceof InstantiationAwareBeanPostProcessor) {
                        InstantiationAwareBeanPostProcessor ibp = (InstantiationAwareBeanPostProcessor) bp;
                        // 对所有需要依赖检查的属性进行后处理
                        pvs = ibp.postProcessPropertyValues(pvs, filteredPds, bw.getWrappedInstance(), beanName);
                        if (pvs == null) {
                            return;
                        }
                    }
                }
            }
            if (needsDepCheck) {
                // 依赖检查，对应 depends-on 属性
                checkDependencies(beanName, mbd, filteredPds, pvs);
            }
        }

        if (pvs != null) {
            // 将属性应用到 bean 中
            applyPropertyValues(beanName, mbd, bw, pvs);
        }
    }
```

处理流程如下：

1. 根据 hasInstantiationAwareBeanPostProcessors 属性来判断是否需要在注入属性之前给 InstantiationAwareBeanPostProcessors 最后一次改变 bean 的机会，此过程可以控制 Spring 是否继续进行属性填充。
2. 根据注入类型的不同来判断是根据名称来自动注入（autowireByName()）还是根据类型来自动注入（autowireByType()），统一存入到 PropertyValues 中，PropertyValues 用于描述 bean 的属性。
3. 判断是否需要进行 BeanPostProcessor 和 依赖检测。
4. 将所有 PropertyValues 中的属性填充到 BeanWrapper 中。

### 自动注入

Spring 会根据注入类型（ byName / byType ）的不同，调用不同的方法（autowireByName() / autowireByType()）来注入属性值。

autowireByName()

方法 autowireByName() 是根据属性名称完成自动依赖注入的

```java
protected void autowireByName(
            String beanName, AbstractBeanDefinition mbd, BeanWrapper bw, MutablePropertyValues pvs) {

        // 对 Bean 对象中非简单属性
        String[] propertyNames = unsatisfiedNonSimpleProperties(mbd, bw);
        for (String propertyName : propertyNames) {
            // 如果容器中包含指定名称的 bean，则将该 bean 注入到 bean中
            if (containsBean(propertyName)) {
                // 递归初始化相关 bean
                Object bean = getBean(propertyName);
                // 为指定名称的属性赋予属性值  
                pvs.add(propertyName, bean);
                // 属性依赖注入
                registerDependentBean(propertyName, beanName);
                if (logger.isDebugEnabled()) {
                    logger.debug("Added autowiring by name from bean name '" + beanName +
                            "' via property '" + propertyName + "' to bean named '" + propertyName + "'");
                }
            }
            else {
                if (logger.isTraceEnabled()) {
                    logger.trace("Not autowiring property '" + propertyName + "' of bean '" + beanName +
                            "' by name: no matching bean found");
                }
            }
        }
    }
```

完成了所有注入属性的获取，将获取的属性封装在 PropertyValues 的实例对象 pvs 中，并没有应用到已经实例化的 bean 中，而 applyPropertyValues() 则是完成这一步骤的.

> 主要过程和根据名称自动注入差不多都是找到需要依赖注入的属性，然后通过迭代的方式寻找所匹配的 bean，最后调用 registerDependentBean() 注册依赖
