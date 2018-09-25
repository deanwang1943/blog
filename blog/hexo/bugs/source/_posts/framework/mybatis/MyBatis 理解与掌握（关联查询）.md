---
title: MyBatis 理解与掌握（关联查询)
date: 2018-09-20 08:36:03
tags: [mybatis]
categories: [mybatis]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://segmentfault.com/a/1190000016438167

## MyBatis 理解与掌握（关联查询）

@(MyBatis)[Java, 框架, MyBatis]

### 一对一查询

案例：查询所有订单信息，关联查询下单用户信息

![](https://segmentfault.com/img/bVbg8tv?w=596&h=139)

从 Order 的角度，一个订单对应一个用户：order----->user (一对一）
从 User 的角度，一个用户可以有多个订单：user------>order (多对一）

场景需求：查询订单，同时关联查询用户信息
------------------------------- 表设计 ------------------------------------------
在 t_orders(多方表) 中增加一个字段 user_id，作为外键

------------------------------- 类设计 ------------------------------------------

```
public class Order {
  private int oId;
  private int number;
  private User user;
    //省略get、set方法
}
public class User {
  private Integer userId;
  private String userName;
    //省略get、set方法
}
```

----------------------- 映射文件 mapping.xml-----------------------

#### 方法一：嵌套结果

`<association/>`关联元素处理 “有一个” 类型的关系。例如, 在下面的`<resultMap/>`中表示一个订单对应了一个用户。
association 标签可用的属性如下：

```
property:对象属性的名称
javaType:对象属性的类型
column:所对应的外键字段名称
select:使用另一个查询封装的结果
columnPrefix:当连接多表时，你将不得不使用列别名来避免ResultSet中的重复列名。指定columnPrefix允许你映射列名到一个外部的结果集中。

```

```
<select id="getOrder" parameterType="int" resultMap="orderResultMap ">
  select
    t_orders.order_id,t_orders.order_number,t_user.id,t_user.user_name,t_user.user_address
  from t_orders,t_user
  <where>
    t_orders.user_id = t_user.id
    and t_orders.order_id = #{oId}
  </where>
 </select>

 <resultMap type="com.george.pojo.Order" id="orderResultMap ">
  <id property="oId" column="order_id"/>
  <result property="number" column="order_number"/>
  <association property="user" resultMap="userResultMap "/>
 </resultMap>

 <resultMap type="com.george.pojo.User" id="userResultMap ">
  <id property="userId" column="id"/>
  <result property="userName" column="user_name"/>
 </resultMap>
```

执行过程：

```
DEBUG [main] - ==>  Preparing: select t_orders.order_id, t_orders.order_number, t_user.id, t_user.user_name, t_user.user_address from t_orders,t_user WHERE t_orders.user_id = t_user.id and t_orders.order_id = ?
DEBUG [main] - ==> Parameters: 1(Integer)
TRACE [main] - <==    Columns: order_id, order_number, id, user_name, user_address
TRACE [main] - <==        Row: 1, 30, 1, zhangsan, 北京
DEBUG [main] - <==      Total: 1
打印查询结果对象： Order [oId=1, number=30, user=User [userId=1, userName=zhangsan]]
```

#### 方法二：嵌套查询

通过执行另外一个 SQL 映射语句来返回预期的复杂类型

```
<select id="getOrder" parameterType="int" resultMap="orderResultMap">
  select
     order_id,
     order_number,
     user_id   
  from t_orders
  <where>
     order_id = #{oIddddd}
  </where>
 </select>

 <resultMap type="com.george.bean.Order" id="orderResultMap">
  <id property="oId" column="order_id"/>
  <result property="number" column="order_number"/>
  <association property="user" javaType="com.george.bean.User" column="user_id" select="getUser"/>
 </resultMap>

  <select id="getUser" parameterType="int" resultType="com.george.bean.User">
  <!-- 使用别名来映射字段和属性 -->
  select user_id as userId , user_name as userName
  from t_user
  <where>
     user_id=#{idddd}   <!-- 外键字段或者和外键关联那个字段的值，由上一条查询中得到 -->
  </where>
  </select>
```

---------------------------java 代码 ---------------------

```
@Test
  public void test() {
    SqlSession session = DBUtil.getSession();
    Order order = session.selectOne("getOrder",1 );
    System.out.println("打印查询结果对象："+order);
}
```

--------------------------sql 执行过程 -------------------------

```
DEBUG [main] - ==>  Preparing: select order_id, order_number, user_id from t_orders WHERE order_id = ?
DEBUG [main] - ==> Parameters: 1(Integer)
TRACE [main] - <==    Columns: order_id, order_number, user_id
TRACE [main] - <==        Row: 1, 30, 3
DEBUG [main] - ====>  Preparing: select user_id as userId , user_name as userName from t_user WHERE user_id=?
DEBUG [main] - ====> Parameters: 3(Integer)
TRACE [main] - <====    Columns: userId, userName
TRACE [main] - <====        Row: 3, wangwu
DEBUG [main] - <====      Total: 1
DEBUG [main] - <==      Total: 1
打印查询结果对象：Order [oId=1, number=30, user=User [userId=3, userName=wangwu]]
```

__注意__：我们有两个查询语句: 一个来加载 order, 另外一个来加载 user。
这种方式很简单, 但会产生 “N+1 查询问题”。概括地讲, N+1 查询问题可以是这样引起的:

```
（1）你执行了一个单独的 SQL 语句来获取结果列表(就是“+1”)。
（2）假设返回的是一个集合，集合中的每个元素对应了一条记录,你还需要执行了一个查询语句来为每条记录加载细节(就是“N”)。
```

MyBatis 延迟加载是一种处理方式，然而，如果你加载一个列表，之后迅速迭代来访问嵌套的数据，你会调用所有的延迟加载，问题没有解决。

#### 方法三：增加一个包含订单信息和用户信息的类，用这个类作为返回类型 resultType

```
public class OrdersCustom extends Orders {
            private String username ; // 用户名称
            private String address ; // 用户地址
            省略get、set方法
｝
```

```
<!-- OrdersCustom 类继承 Orders 类后 OrdersCustom 类包括了 Orders 类的所有字段， 只需要定义用户的信息字段即可。 -->
<select id ="findOrdersList"   resultType ="cn.george.mybatis.po.OrdersCustom"  parameterType="Integer">
      SELECT
         orders.*,
         user.user_name,
         user.user_address
      FROM
         orders, user
      WHERE orders.user_id = #{user.id}
</select>
```

总结：定义专门的 po 类作为输出类型，其中定义了 sql 查询结果集所有的字段。此方法较为简单，企业中普遍使用。

### 一对多查询

案例：通过订单 id 查询订单信息及订单下的订单明细信息。
订单信息与订单明细为一对多关系。

![](https://segmentfault.com/img/bVbg8tE?w=771&h=334)

--------------------------- 类设计 ----------------------------------------

```
  private int oId;
  private int number; //订单编号
  private User user; //用户信息
  private List<Orderdetail> orderdetails;  //订单详情信息
  //省略get、set方法
  }
```

------------------------- 映射文件 -----------------------------

#### 方法一：嵌套结果

```
<select id="getOrder" parameterType="int" resultMap="orderdetailResultMap">
     select
     t_orders.order_id,
     t_orders.order_number,
     t_user.user_id,
     t_user.user_name,
     t_user.user_address,
     t_orderdetail.od_id,
     t_orderdetail.items_id,
     t_orderdetail.items_num,
     t_orderdetail.order_id
     from t_orders,t_user,t_orderdetail
     <where>
       t_orderdetail.order_id = t_orders.order_id
       and t_orders.user_id = t_user.user_id
       and t_orders.order_id = #{id}
     </where>
  </select>
  <resultMap type="com.hh.bean.Order" id="orderdetailResultMap">
     <id property="oId" column="order_id" />
     <result property="number" column="order_number" />
     <association property="user" javaType="com.hh.bean.User">
       <id property="userId" column="user_id" />
       <result property="userName" column="user_name" />
     </association>
     <!-- 集合的泛型，指定集合中的对象类型-->
     <collection property="orderdetails" ofType="com.hh.bean.Orderdetail">
       <id property="odId" column="od_id" />
       <result property="itemsId" column="items_id" />
       <result property="itemsNum" column="items_num" />
     </collection>
  </resultMap>
```

使用继承 extends, 上面的 <resultMap/> 可以改写为：

```
<!--关联查询用户-->
<resultMap type="com.hh.bean.Order" id="orderResultMap">
     <id property="oId" column="order_id" />
     <result property="number" column="order_number" />
     <association property="user" javaType="com.hh.bean.User">
       <id property="userId" column="user_id" />
       <result property="userName" column="user_name" />
     </association>
  </resultMap>
```

```
 <!--继承上一个resultMap，关联查询用户和订单详情-->
  <resultMap type="com.hh.bean.Order" id="orderdetailResultMap" extends="orderResultMap">
     <!-- 集合的泛型，指定集合中的对象类型 -->
     <collection property="orderdetails" ofType="com.hh.bean.Orderdetail">
       <id property="odId" column="od_id" />
       <result property="itemsId" column="items_id" />
       <result property="itemsNum" column="items_num" />
     </collection>
  </resultMap>
```

```
打印查询结果对象：Order [oId=1, number=30000001, user=User [userId=3, userName=wangwu],
orderdetails=[Orderdetail [odId=1, itemsId=2, itemsNum=30], Orderdetail [odId=2, itemsId=1, itemsNum=32]]]
```

#### 方法二：嵌套查询

```
<select id="getOrder" parameterType="int" resultMap="orderResultMap">
     select
     order_id,
     order_number,
     user_id
     from t_orders
     <where>
       order_id = #{oIddddd}
     </where>
  </select>

  <resultMap type="com.hh.bean.Order" id="orderResultMap">
     <id property="oId" column="order_id" />
     <result property="number" column="order_number" />
     <association property="user" javaType="com.hh.bean.User"
       column="user_id" select="getUser" />
     <!-- column 哪一个字段和多方表中的外键对应 -->
     <collection property="orderdetails" column="order_id" select="getOrderdeatil"/>
  </resultMap>

  <select id="getUser" parameterType="int" resultType="com.hh.bean.User">
     <!-- 使用别名来映射字段和属性 -->
     select user_id as userId , user_name as userName
     from t_user
     <where>
       user_id=#{idddd}   <!-- 外键字段或者和外键关联那个字段的值，由上一条查询中得到 -->
     </where>
  </select>

  <select id="getOrderdeatil" parameterType="int" resultType="com.hh.bean.Orderdetail">
     select od_id as odId,items_id as itemsId,items_num as itemsNum
     from t_orderdetail
     <where>
       order_id = #{id}   <!-- 外键字段或者和外键关联那个字段的值，由上一条查询中得到 -->
     </where>
  </select>
```

---------------------------java 代码 ---------------------

```
@Test
  public void test() {
    SqlSession session = DBUtil.getSession();
    Order order = session.selectOne("getOrder",1 );
    System.out.println("打印查询结果对象："+order);
}
```

------------------------sql 执行结果 -----------------------

```
打印查询结果对象：Order [oId=1, number=30000001, user=User [userId=3, userName=wangwu],
orderdetails=[Orderdetail [odId=1, itemsId=2, itemsNum=30], Orderdetail [odId=2, itemsId=1, itemsNum=32]]]
```

### 多对多查询

案例：查询用户购买的商品信息
需要查询所有用户信息，关联查询订单及订单明细信息，订单明细信息中关联查询商品信息

分析：
需要关联查询映射的信息是：订单、订单明细、商品信息

*   订单：一个用户对应多个订单，使用 collection 映射到用户对象的订单列表属性中
*   订单明细：一个订单对应多个明细，使用 collection 映射到订单对象中的明细属性中
*   商品信息： 一个订单明细对应一个商品， 使用 association 映射到订单明细对象的商品属性中。

![](https://segmentfault.com/img/bVbg8tH?w=702&h=511)

--------------------------- 类设计 -----------------------------------

```
public class User {
  private Integer userId;
  private String userName;
  private List<Order> orders;  //订单列表
}

public class Order {
  private int oId;
  private int number; //订单编号
  private List<Orderdetail> orderdetails;  //订单详情信息
}

public class Orderdetail {
  private int odId;
  private Items item; //商品信息
  private int itemsNum; //商品数量
}

public class Items {
  private int itemId;
  private String itemName; //商品名称
}
```

----------------------------- 映射文件 --------------------------------------

```

<select id="getUser" resultMap="userOrderListResultMap">
     select
     t_orders.order_id,
     t_orders.order_number,
     t_user.user_id,
     t_user.user_name,
     t_user.user_address,
     t_orderdetail.od_id,
     t_orderdetail.items_id,
     t_orderdetail.items_num,
     t_orderdetail.order_id,
     t_items.item_id,
     t_items.item_name
     from t_orders,t_user,t_orderdetail,t_items
     <where>
       t_orderdetail.order_id = t_orders.order_id
       and t_orders.user_id = t_user.user_id
       and t_orderdetail.items_id = t_items.item_id
     </where>
  </select>

  <resultMap type="com.hh.bean.User" id="userOrderListResultMap">
     <id property="userId" column="user_id" />
     <result property="userName" column="user_name" />
     <collection property="orders" ofType="com.hh.bean.Order">
       <id property="oId" column="order_id" />
       <result property="number" column="order_number" />
       <collection property="orderdetails" ofType="com.hh.bean.Orderdetail">
          <id property="odId" column="od_id" />
          <result property="itemsNum" column="items_num" />
          <association property="item" javaType="com.hh.bean.Items">
            <id property="itemId" column="item_id" />
            <result property="itemName" column="item_name" />
          </association>
       </collection>
     </collection>
  </resultMap>
```

---------------------------java 代码 ---------------------

```
@Test
  public void test() {
    SqlSession session = DBUtil.getSession();
    List<User> users = session.selectList("getUser");
    for (User user : users) {
      System.out.println("打印用户信息："+user);
    }
  }
```

------------------------sql 执行结果 -----------------------

```
打印用户信息：User [userId=1, userName=zhangsan, orders=[Order [oId=1, number=30000001, orderdetails=[Orderdetail [odId=1, item=Items [itemId=2, itemName=香蕉], itemsNum=30], Orderdetail [odId=2, item=Items [itemId=1, itemName=苹果], itemsNum=32]]], Order [oId=3, number=30000003, orderdetails=[Orderdetail [odId=3, item=Items [itemId=3, itemName=橘子], itemsNum=25]]]]]
打印用户信息：User [userId=3, userName=wangwu, orders=[Order [oId=4, number=30000004, orderdetails=[Orderdetail [odId=4, item=Items [itemId=3, itemName=橘子], itemsNum=45]]]]]
```

### 自关联

![](https://segmentfault.com/img/bVbg8tN?w=566&h=280)

![](https://segmentfault.com/img/bVbg8tO?w=871&h=463)

### 延迟加载

什么是延迟加载

resultMap 可实现高级映射（使用 association、collection 实现一对一及一对多映射），association、collection 具备延迟加载功能。

例如：先从单表查询，需要时再从关联表去关联查询，大大 提高数据库性能 ，因为查询单表要比关联查询多张表速度要快。

![](https://segmentfault.com/img/bVbg8tS?w=620&h=299)

mybatis 框架默认不支持延迟加载功能，如果想要使用，需要启用延迟加载功能

```
<!-- 打开延迟加载的开关 -->
<setting  />
```

默认框架会采用侵入式的延迟加载：

*   如果查询主动方数据，而不使用，那么关联数据是不会被查询的。
*   如果使用了主动方的数据，那么关联数据即使没有使用也会被查询。

可以禁用侵入式延迟加载功能

```
<!-- 将积极加载改为消息加载即按需加载 -->
<setting  />
```

综上所述，在主配置文件 mybatis-config.xml 中做如下配置：

```

  <settings>
    <setting    />
    <setting    />
  </settings>
```

注意一个异常：Caused by: org.xml.sax.SAXParseException; lineNumber: 36; columnNumber: 17; 元素类型为 "configuration" 的内容必须匹配 "(properties?,settings?,typeAliases?,typeHandlers?,objectFactory?,objectWrapperFactory?,reflectorFactory?,plugins?,environments?,databaseIdProvider?,mappers?)"。
![](https://segmentfault.com)
在关联的元素（association ，collection ，discriminator）中，我们存在一个属性： fetchType 来决定是否需要延迟加载，如果配置它，它将覆盖掉原有在 MyBatis 设置的策略。

对于它而言，它有两个取值：

```
* lazy: 延迟加载（默认）
* eager:即刻加载
```

由它来决定是否需要延迟或者即刻加载。

### 总结

#### resultType

作用：

*   将查询结果按照 sql 列名 pojo 属性名一致性映射到 pojo 中。

场合：

*   常见一些明细记录的展示， 比如用户购买商品明细， 将关联查询信息全部展示在页面时，此时可直接使用 resultType 将每一条记录映射到 pojo 中， 在前端页面遍历 list （ list 中是 pojo ）即可。

#### resultMap

*   使用 association 和 collection 完成一对一和一对多高级映射 （对结果有特殊的映射要求） 。

#### association

作用：

*   将关联查询信息映射到一个 pojo 对象中。

场合：

*   为了方便查询关联信息可以使用 association 将关联订单信息映射为用户对象的 pojo 属性中，比如：查询订单及关联用户信息。使用 resultType 无法将查询结果映射到 pojo 对象的 pojo 属性中，根据对结果集查询遍历的需要选择使用 resultType 还是 resultMap 。

#### collection

作用：

*   将关联查询信息映射到一个 list 集合中。

场合：

*   为了方便查询遍历关联信息可以使用 collection 将关联信息映射到 list 集合中，比如：查询用户权限范围模块及模块下的菜单，可使用 collection 将模块映射到模块 list 中，将菜单列表映射到模块对象的菜单 list 属性中， 这样的作的目的也是方便对查询结果集进行遍历查询。

如果使用 resultType 无法将查询结果映射到 list 集合中。
