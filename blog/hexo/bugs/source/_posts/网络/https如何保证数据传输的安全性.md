---
title: https如何保证数据传输的安全性
date: 2018-08-25 08:36:03
tags: [HTTP]
categories: [HTTP]
---

大家都知道，在客户端与服务器数据传输的过程中，http协议的传输是不安全的，也就是一般情况下http是明文传输的。但https协议的数据传输是安全的，也就是说https数据的传输是经过加密。

在客户端与服务器这两个完全没有见过面的陌生人交流中，https是如何保证数据传输的安全性的呢？

下面我将带大家一步步了解https是如何加密才得以保证数据传输的安全性的。我们先把客户端称为小客，服务器称为小服。然后一步步探索在小客与小服的交流中（就是一方请求一方响应）,https是如何保证他们的交流不会被中间人窃听的。


## 1. 对称加密

假如现在小客与小服要进行一次私密的对话，他们不希望这次对话内容被其他外人知道。可是，我们平时的数据传输过程中又是明文传输的，万一被某个黑客把他们的对话内容给窃取了，那就难受了。

为了解决这个问题，小服这家伙想到了一个方法来加密数据，让黑客看不到具体的内容。该方法是这样子的：

在每次数据传输之前，小服会先传输小客一把密钥，然后小服在之后给小客发消息的过程中，会用这把密钥对这些消息进行加密。小客在收到这些消息后，会用之前小服给的那把密钥对这些消息进行解密，这样，小客就能得到密文里面真正的数据了。如果小客要给小服发消息，也同样用这把密钥来对消息进行加密，小服收到后也用这把密钥进行解密。 这样，就保证了数据传输的安全性。如图所示:

![](https://user-gold-cdn.xitu.io/2018/8/23/16566f63546a212a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这时，小服想着自己的策咯，还是挺得意的。

可是，这时候问题来了。这个策略安全的前提是，小客拥有小服的那把密钥。可问题是，小服是以明文的方式把这把密钥传输给小客的，这个时候，如果黑客截取了这把密钥，那就难受了。小服与小客就算是加密了内容，在截取了密钥的黑客老哥眼里，这和明文没啥区别。


## 2. 非对称加密

小服还是挺聪明的，得意了一会之后，小服意识到了密钥会被截取这个问题。倔强的小服又想到了另外一种方法：用非对称加密的方法来加密数据。该方法是这样的：

小服和小客都拥有两把钥匙，一把钥匙的公开的（全世界都知道也没关系），称之为公钥；而另一把钥匙是保密（也就是只有自己才知道），称之为私钥。并且，用公钥加密的数据，只有对应的私钥才能解密；用私钥加密的数据，只有对应的公钥才能解密。

所以在传输数据的过程中，小服在给小客传输数据的过程中，会用小客给他的公钥进行加密，然后小客收到后，再用自己的私钥进行解密。小客给小服发消息的时候，也一样会用小服给他的公钥进行加密，然后小服再用自己的私钥进行解密。 这样，数据就能安全着到达双方。如图：

![](https://user-gold-cdn.xitu.io/2018/8/23/16566f637000c91b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

想着这么复杂的策略都能想出来，小服可是得意的不能在得意了…..

看着那么得意的小服，小客这时心情就不得好了。还没等小服得意多久，小客就给它泼了一波冷水了。

小客严肃着说：其实，你的这种方法也不是那么的安全啊。还是存在被黑客截取的危险啊。例如：

你在给我传输公钥的过程中，如果黑客截取了你的公钥，并且拿着自己的公钥来冒充你的公钥来发给我。我收到公钥之后，会用公钥进行加密传输（这时用的公钥实际上是黑客的公钥）。黑客截取了加密的消息之后，可以用他自己的私钥来进行解密来获取消息内容。然后在用你（小服）的公钥来对消息进行加密，之后再发给你（小服）。 这样子，我们的对话内容还是被黑客给截取了啊。（倒过来小客给小服传输公钥的时候也一样）。

我靠，这么精妙的想法居然也不行，小服这波，满脸无神。

插讲下

其实在传输数据的过程中，在速度上用对称加密的方法会比非对称加密的方法快很多。所以在传输数据的时候，一般不单单只用非对称加密这种方法(我们先假设非对称密码这种方法很安全)，而是会用非对称加密 + 对称加密这两种结合的方法。 你想啊，对于对称加密这种方法来说，之所以不安全是因为密钥在传输的过程中，被别人知道了。基于这个，我们可以用非对称加密方法来安全着传输密钥，之后在用对称加密的方法来传输消息内容（当然，我这里假定了非对称加密传输是安全的，下面会讲如何使之安全）。


## 数字证书

我们回头想一下，是什么原因导致非对称加密这种方法的不安全性呢？它和对称加密方法的不安全性不同。非对称加密之所以不安全，是因为小客收到了公钥之后，无法确定这把公钥是否真的是小服。

也就是说，我们需要找到一种策略来证明这把公钥就是小服的，而不是别人冒充的。

为了解决这个问题，小服和小客通过绞尽脑汁想出了一种终极策略：数字证书：

我们需要找到一个拥有公信力、大家都认可的认证中心(CA)

小服再给小客发公钥的过程中，会把公钥以及小服的个人信息通过Hash算法生成消息摘要。如图：

![](https://user-gold-cdn.xitu.io/2018/8/23/16566f6381174ad0?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

为了防止摘要被人调换，小服还会用CA提供的私钥对消息摘要进行加密来形成数字签名。如图：

![](https://user-gold-cdn.xitu.io/2018/8/23/16566f638e1ede02?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

并且，最后还会把原来没Hash算法之前的信息和数字签名合并在一起，形成数字证书。如图：

![](https://user-gold-cdn.xitu.io/2018/8/23/16566f6397cb6587?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

当小客拿到这份数字证书之后，就会用CA提供的公钥来对数字证书里面的数字签名进行解密得到消息摘要，然后对数字证书里面小服的公钥和个人信息进行Hash得到另一份消息摘要，然后把两份消息摘要进行对比，如果一样，则证明这些东西确实是小服的，否则就不是。如图：

![](https://user-gold-cdn.xitu.io/2018/8/23/16566f63a57b7cc2?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

这时可能有人会有疑问，CA的公钥是怎么拿给小客的呢？小服又怎么有CA的私钥呢？其实，(有些)服务器在一开始就向认证中心申请了这些证书，而客户端里，也会内置这些证书。如图(此图来元阮一峰的网络日志)

![](https://user-gold-cdn.xitu.io/2018/8/23/16566f63bb9b9ab2?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

当客户端收到服务器返回来的数据时，就会在内置的证书列表里，查看是否有有解开该数字证书的公钥，如果有则…..否则…..
