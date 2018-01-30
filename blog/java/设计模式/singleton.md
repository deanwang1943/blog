# 单例模式

> 定义：Ensure a class has only one instance, and provide a global point of access to it. （确保一个类只有一个实例，并提供一个全局访问点来访问这个唯一实例。）

> 优势：通过使用 private 的构造函数确保在一个 application 中只产生一个实例，从而减少内存开支，特别是一个对象需要被频繁的创建和销毁时。

## 第一种形式：懒汉式，也是常用的形式。

```java
public class SingletonClass{
    private static SingletonClass instance=null;
    public static synchronized SingletonClass getInstance(){
        if(instance==null){
               instance=new SingletonClass();
        }
        return instance;
    }
    private SingletonClass(){
    }
}
```

## 第二种形式：饿汉式

```java
public class Singleton{

    // initailzed during class loading
    private static final Singleton instance = new Singleton();

    //to prevent creating another instance of Singleton
    private Singleton(){
        //do something
    }

    public static Singleton getInstance(){
        return instance;
    }
}
```

> 因为单例是静态的final变量，所以当类第一次加载到内存中的时候就初始化了，那么创建的实例固然是线程安全的。

## 第三种形式：双重锁的形式

```java
public class Singleton{
    private static volatile Singleton instance=null;
    private Singleton(){
        //do something
    }
    public static  Singleton getInstance(){
        if(instance==null){
            synchronized(Singleton.class){
                if(instance==null){
                    instance=new Singleton();
                }
            }
        }
        return instance;
     }
}
```

双重锁形式将同步内容下放到if内部，提高了执行的效率，这样就不必每次获取对象时都进行同步。

双重锁形式中双重判断加同步的方式，比第一个种懒汉式的效率大大提升，因为如果单层if判断，在服务器允许的情况下，假设有一百个线程，耗费的时间为100（同步判断时间+if判断时间），而如果双重if判断，100的线程可以同时if判断，理论消耗的时间只有一个if判断的时间。

## 第四种方式：静态内部类方式

```java
public class Singleton {
    private Singleton() {
    }
    public static Singleton getInstance() {
        return SingletonHolder.sInstance;
    }
    private static class SingletonHolder {
        private static Singleton sInstance = new Singleton();
    }
}
```

当外部类Singleton被加载时，其静态内部类SingeletonHolder不会被加载，所以它的成员变量sInstance是不会被初始化的，只有当调用Singleton.getInstance()方法时，才会加载SingeletonHolder并且初始化其成员变量，而类加载时是线程安全的，这样既保证了延迟加载，也保证了线程安全，同时也简化了代码量。

## 第五种方式：静态工厂方式(通过反射创建单例)

```java
public class SingletonFactory {

    private static Singleton singleton;

    static{
        try{
            Class cls = Class.forName(Singleton.class.getName());
            Constructor constructor = cls.getDeclaredConstructor();
            constructor.setAccessible(true);
            singleton = (Singleton)constructor.newInstance();
        }catch(Exception e){
            // do something...
        }
    }

    public static Singleton getSingleton(){
        return singleton;
    }
}
```

通过获取构造器，然后设置访问权限，生成对象，然后提供给外部访问，保证内存中的对象唯一。

## 第六种方式：枚举方式

（缺陷-反射产生多个实例）饿汉式、懒汉式、静态内部类、双重校验锁的写法通过反射还是可以创建出多个实例：

```java
private static void reflexCreate() {
        try {
            SingletonA s1 = SingletonA.getInstance();

            Class<SingletonA> cls = SingletonA.class;
            Constructor<SingletonA> constructor = cls.getDeclaredConstructor();
            constructor.setAccessible(true);
            SingletonA s2 = constructor.newInstance(new Object[] {});
        } catch (Exception e) {
            e.printStackTrace();
        }
}
```

（缺陷-序列化产生多个实例）饿汉式、懒汉式、静态内部类、双重校验锁的写法通过序列化还是可以创建出多个实例：

```java
class SingletonB implements Serializable {

    private static SingletonB instence = new SingletonB();

    private SingletonB() {
    }

    public static SingletonB getInstance() {
        return instence;
    }
}

private static void testSingletonB() {
        File file = new File("singleton");
        ObjectOutputStream oos = null;
        ObjectInputStream ois = null;
        try {
            oos = new ObjectOutputStream(new FileOutputStream(file));
            SingletonB SingletonB1 = SingletonB.getInstance();

            oos.writeObject(SingletonB1);
            oos.close();
            ois = new ObjectInputStream(new FileInputStream(file));
            SingletonB SingletonB2 = (SingletonB) ois.readObject();
            System.out.println(SingletonB1 == SingletonB2);//false

        } catch (FileNotFoundException | ClassNotFoundException | IOException e) {
            e.printStackTrace();
        } finally {
            if (oos != null) {
                try {
                    oos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (ois != null) {
                try {
                    ois.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
```

这个问题可以在类中添加readResolve()方法来避免，即：

```java
class SingletonB implements Serializable {

    private static SingletonB instence = new SingletonB();

    private SingletonB() {
    }

    public static SingletonB getInstance() {
        return instence;
    }

    // 不添加该方法则会出现 反序列化时出现多个实例的问题
    public Object readResolve() {
        return instence;
    }
}
```

使用单元素的枚举实现单例模式

```java
public enum  EnumSingleton {

    INSTACE; // 定义一个枚举元素，代表 EnumSingleton 一个实例

    /**
     * 枚举中的构造方法只能写成 private 或是不写「不写默认就是 private」，所以枚举防止外部来实例化对象
     */
    EnumSingleton(){
    }

    /**
     * 一些额外的方法
     */
    public void doSometing(){
        // do something...
    }
}
```

> 这种方法在功能上与公有域方法相近，但是它更加简洁，无偿提供了序列化机制，绝对防止多次实例化，即使是在面对复杂序列化或者反射攻击的时候。虽然这种方法还没有广泛采用，但是单元素的枚举类型已经成为实现Singleton的最佳方法。 ---《Effective Java 中文版 第二版》
