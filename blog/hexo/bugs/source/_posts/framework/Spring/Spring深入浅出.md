
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

