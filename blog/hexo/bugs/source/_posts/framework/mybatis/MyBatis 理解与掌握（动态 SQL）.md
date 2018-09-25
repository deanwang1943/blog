---
title: MyBatis 理解与掌握（动态 SQL）
date: 2018-09-20 08:36:03
tags: [mybatis]
categories: [mybatis]
---

> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://segmentfault.com/a/1190000016424222

## MyBatis 理解与掌握（动态 SQL）

@(MyBatis)[Java, 框架, MyBatis]

### if

if 就是__简单的条件判断 __，利用 if 语句我们可以实现某些简单的条件选择。
先来看如下一个例子：

```
<select id="selectUserByUserNameAndSex" resultType="com.george.pojo.User" parameterType="com.george.pojo.User">
    select * from user where
        <if test="userName != null">
           username=#{userName}
        </if>

        <if test="userName != null">
           and sex=#{sex}
        </if>
</select>
```

在 JDBC 中如果要实现条件查询，采用的是拼串的方式，而且 sql 语句往往和 java 代码混杂在一起，非常麻烦。

### choose（when，otherwise）

choose 元素的作用就相当于 JAVA 中的 switch 语句，基本上跟 JSTL 中的 choose 的作用和用法是一样的，通常都是与 when 和 otherwise 搭配的。看如下一个例子：

```
<select id="selectUserByChoose" resultType="com.george.pojo.User" parameterType="com.george.pojo.User">
      select * from user
      <where>
          <choose>
              <when test="id !='' and id != null">
                  id=#{id}
              </when>
              <when test="userName !='' and userName != null">
                  and username=#{userName}
              </when>
              <otherwise>
                  and sex=#{sex}
              </otherwise>
          </choose>
      </where>
  </select>
```

when 元素表示当 when 中的 **条件满足的时候就输出其中的内容 ，只有一个会输出** ，当 title!=null 的时候就输出 and titlte = #{title}，不再往下判断条件，当 title 为空且 content!=null 的时候就输出 and content = #{content}，当所有条件都不满足的时候就输出 otherwise 中的内容。

### where

where 语句的作用主要是 **简化 SQL 语句中 where 中的条件判断** ，先看一个例子，再解释一下 where 的好处。

```
<select id="selectUserByUserNameAndSex" resultType="com.george.pojo.User" parameterType="com.george.pojo.User">
    select * from user
    <where>
        <if test="userName != null">
           username=#{userName}
        </if>

        <if test="userName != null">
           and sex=#{sex}
        </if>
    </where>
</select>
```

（1）会在写入 where 元素的地方输出一个 where
（2）如果所有的条件都不满足那么 MyBatis 就会查出所有的记录
（3）如果输出后是 and 开头的，MyBatis 会把第一个 and 忽略，当然如果是 or 开头的，MyBatis 也会把它忽略
（4）在 where 元素中你不需要考虑空格的问题，MyBatis 会智能的帮你加上

### trim

```
<insert id="addBrand" parameterType="Brand">
    insert into bbs_brand
    <trim prefix="(" suffix=")">
     name,
     description,
     img_url,
     sort,
     is_display
    </trim>
    values
    <trim prefix="(" suffix=")">
     #{name},
     #{description},
     #{imgUrl},
     #{sort},
     #{isDisplay}
    </trim>
</insert>
```

trim 元素的主要功能是可以在自己包含的内容前加上某些前缀，也可以在其后加上某些后缀，与之对应的属性是 **prefix** 和 **suffix**.
可以把包含内容的首部某些内容覆盖，即忽略，也可以把尾部的某些内容覆盖，对应的属性是 **prefixOverrides** 和 **suffixOverrides**；

### set

set 元素主要是用 在更新操作的时候在包含的语句前输出一个 set 。
有了 set 元素我们就可以动态的更新那些修改了的字段。下面是一段示例代码：

```
<update id="updateUserById" parameterType="com.george.pojo.User">
    update user u
        <set>
            <if test="userName != null and userName != ''">
                u.username = #{userName},
            </if>
            <if test="sex != null and sex != ''">
                u.sex = #{sex}
            </if>
        </set>

     where id=#{id}
</update>
```

（1）如果包含的语句是以逗号结束的话将会把该逗号忽略
（2）如果 set 包含的内容为空的话则会出错

### foreach

foreach 的主要用在 **构建 in 条件中** ，它可以**在 SQL 语句中进行迭代一个集合** 。

foreach 元素的属性主要有：

*   **item** 表示集合中每一个元素进行迭代时的别名
*   **index** 指定一个名字，用于表示在迭代过程中，每次迭代到的位置
*   **open** 表示该语句以什么开始
*   **separator** 表示在每次进行迭代之间以什么符号作为分隔符
*   **close** 表示以什么结束
*   **collection** 属性，该属性是必须指定的，但是在不同情况下，该属性的值是不一样的，主要有一下 3 种情况：

（1）果传入的是单参数且参数类型是一个 List 的时候，collection 属性值为 list

```
<select id="dynamicForeachTest" resultType="Blog">
select * from t_blog where id in
<foreach collection="list" index="index" item="item" open="(" separator="," close=")" >
    #{item}
</foreach>
</select>
```

```
public List<Blog> dynamicForeachTest(List<Integer> ids);
```

（2）如果传入的是单参数且参数类型是一个 array 数组的时候，collection 的属性值为 array

```
<select id="dynamicForeach2Test" resultType="Blog">
select * from t_blog where id in
<foreach collection="array" index="index" item="item" open="(" separator="," close=")" >
    #{item}
</foreach>
</select>
```

```
public List<Blog> dynamicForeach2Test(int[] ids);  
```

（3）如果传入的参数是多个的时候，我们就需要把它们封装成一个 Map 了，所以这个时候 collection 属性值就是传入的 List 或 array 对象在自己封装的 map 里面的 key

```
<select id="dynamicForeach3Test" resultType="Blog">
select * from t_blog where title like "%"#{title}"%" and id in
<foreach collection="ids" index="index" item="item" open="(" separator="," close=")" >
    #{item}
</foreach>
</select>
```

```
public List<Blog> dynamicForeach3Test(Map<String, Object> params);  
```

**基于 3.3.1 版本验证的新特性**
（4）foreach 标签遍历的集合元素类型是 Map.Entry 类型时，index 属性指定的变量代表对应的 Map.Entry 的 key，item 属性指定的变量代表对应的 Map.Entry 的 value。此时如果对应的集合是 Map.entrySet，则对应的 collection 属性用 collection。foreach 在进行遍历的时候如果传入的参数是 List 类型，则其 collection 属性的值可以是 list 或 collection，但如果传入的参数是 Set 类型，则 collection 属性的值只能用 collection。

```
<select id="dynamicForeach2Test" resultType="Blog">
select * from t_blog where id in
<!-- 遍历的对象是Map.Entity时，index代表对应的Key，item代表对应的value   -->
<foreach collection="collection" index="key" item="value" open="(" separator="," close=")" >
    #{key},#{value}
</foreach>
</select>
```

```
public List<Blog> dynamicForeachTest(Set<Map.Entry<Integer, Integer>> ids);
```

### bind

bind 标签，动态 SQL 中已经包含了这样一个新的标签，它的功能是在当前 OGNL 上下文中创建一个变量并绑定一个值。
有了它以后我们以前的模糊查询就可以改成这个样子：

```
<select id="fuzzyQuery" resultType="Blog" parameterType="java.lang.String">
<!-- bind标签用于创建新的变量   -->
  <bind  />
  SELECT * FROM t_blog
  WHERE title LIKE #{titleLike}
</select>
```
