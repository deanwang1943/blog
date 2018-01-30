# 工厂模式

## 简单工厂模式

## 工厂方法模式

> 定义：Define an interface for creating an object, but let subclasses decide which class instance. Factory Method lets a class defer instantiation to subclasses. （定义一个用于创建对象的接口 [这里的接口一词并不指Java中的接口构造，它可以是Java接口或抽象类] ，但是让子类决定去实例化哪个类。工厂方法将对象的实例化推迟到其子类。）

优势：

[1].良好的封装性，代码结构清晰。如果一个调用者需要一个具体的产品对象，只要知道这个产品的类名就可以了，不用关心对象是如何创建的，降低了模块见得耦合。

[2].工厂方法模式扩展性非常优秀。如果想增加一个产品类，只需要适当的修改具体的工厂类或扩展一个工厂类就可以完成。

[3].屏蔽品类。产品的实现如何变化，调用者都不需要关心，它只需要关心产品的接口，只要接口保持不变，系统中的上层模块就不需要发生变化。因为产品的实例化工作是由工厂类负责的，一个产品对象具体由哪一个产品生成是由工厂类决定的。 例如：在数据库开发中，如果使用 JDBC 连接数据库，数据库从 MySQL 且款到 Oracle，只需要改动的地方就是切换一下驱动名称。

[4].工厂方法模式是典型的解耦框架。高层模块值只需要知道产品的抽象类，其他的实现类都不用关心，符合迪米特法则，我不需要的就不要去交流；也符合依赖倒置原则，只依赖产品的抽象；也符合里氏替换原则，使用产品子类替换父类。

### 简单工厂模式（Simple Factory Pattern）

```
产品抽象类Product
具体产品类ConcreteProduct1 ConcreteProduct2
工厂类Creator
```

- 产品抽象

```java
public abstract class Product {
    public abstract void method();
}
```

- 具体产品

```java
public class ConcreteProduct1 extends Product{
    @Override
    public void method() {
        // do something...
    }
}
public class ConcreteProduct2 extends Product{
    @Override
    public void method() {
        // do something...
    }
}
```

- 工厂（第一种实现方式）

```java
  public class Creator{
    public static <T extends Product> T createProduct(Class<T> c) {
        Product product=null;
        try {
            product=(Product)Class.forName(c.getName()).newInstance();
        }catch(Exception e) {
            // do something...
        }
        return (T)product;
    }
  }
```

> 特点：工厂是一个具体类，非抽象类 非接口，它的create方法，是利用反射机制生成对象返回，增加一种产品时，不需要修改工厂的代码。 缺点：不同的产品需要不同额外参数的时候 不支持。

- 工厂（第二种实现方式）

```java
public class Creator{
        public static final int PRODUCT_ONE = 1;
        public static final int PROCUCT_TWO = 2;

    public static Product createProduct(int type) {
        switch(type){
            case PRODUCT_ONE:
                return new ConcreteProduct1();
            case PROCUCT_TWO:
            default:
                return new ConcreteProduct2();
        }
    }
}
```

> 特点：工厂是一个具体类，非抽象类 非接口，create方法通常是静态的，所以也称之为静态工厂。 缺点：扩展性差，当我们需要增加一个产品类时还需要修改工厂类； 不同的产品需要不同额外参数的时候 不支持。

### 多方法静态工厂

简单工厂模式的一个问题是 当产品需要不同额外参数的时候 不支持。 而且如果使用时传递的 type、Class 出错，将不能得到正确的对象，容错性不高。 而多方法的工厂模式为不同产品，提供不同的生产方法。

```
产品抽象类Product
具体产品类ConcreteProduct1 ConcreteProduct2
工厂类Creator
```

- 产品抽象

```java
public abstract class Product {
  public abstract void method();
}
```

- 具体产品

```java
public class ConcreteProduct1 extends Product{

    private String name;

    public ConcreteProduct1(String name){
        this.name = name;
    }

    @Override
    public void method() {
        // do something...
    }
}

public class ConcreteProduct2 extends Product{

    private String name;
    private int size;

    public ConcreteProduct2(String name, int size){
        this.name = name;
        this.size = size;
    }

    @Override
    public void method() {
        // do something...
    }
}
```

- 工厂

```java
public class Creator{

    public static Procuct createProduct1(String name){
        return new ConcreteProduct1(name);
    }

    public static Procuct createProduct2(String name, int size){
        return new ConcreteProduct2(name, size);
    }
}
```

> 优点：方便创建 同种类型的 复杂参数 对象

### 普通工厂

```
产品抽象类Product
工厂抽象类Creator
具体产品类ConcreteProduct1 ConcreteProduct2
具体工厂类ConcreteCreator1 ConcreteCreator2
```

- 产品抽象

```java
public abstract class Product {
    public abstract void method();
}
```

- 工厂抽象

```java
public abstract class Creator{
    public abstract Product create();
}
```

- 具体产品

```java
public class ConcreteProduct1 extends Product{
    @Override
    public void method() {
        // do something...
    }
}
public class ConcreteProduct2 extends Product{
    @Override
    public void method() {
        // do something...
    }
}
```

- 具体工厂

```java
public class ConcreteCreator1 extends Creator{
    @Override
    public Product create(){
        return new ConcreteCreator1();
    }
}
public class ConcreteCreator2 extends Creator{
    @Override
    public Product create(){
        return new ConcreteCreator2();
    }
}
```

> 特点：不仅仅产品需要抽象， 工厂也需要抽象；工厂方法使一个产品类的实例化延迟到其具体工厂子类。 优点：拥抱变化，当需求变化，只需要增删相应的类，不需要修改已有的类。而简单工厂需要修改工厂类的create方法，多方法静态工厂模式需要增加一个静态方法。 缺点：引入抽象工厂层后，每次新增一个具体产品类，也要同时新增一个具体工厂类。

## 抽象工厂模式
