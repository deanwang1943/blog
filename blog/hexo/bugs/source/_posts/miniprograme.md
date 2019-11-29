# 小程序-记录

### 云函数

1. 新建云函数

新建bookinfo的云函数文件

> tip:安装三方库npm install --save request npm install --save request-promise (异步请求)

2. 云函数编写

通过event来拿到对应的数据
(event, context, cb) => event.x + event.y

exports.main = async (event, context) => {
  console.log(event)
  return {
    event,
    openid: wxContext.OPENID,
    appid: wxContext.APPID,
    unionid: wxContext.UNIONID,
  }
}

或

exports.main = async (event, context) => {
  console.log(event)
  try {
    return await db.collection('books').where ({
      _openid: "xfeefsdfsdfsdfsdf"
    }).
    update({
      data: {
        price: 20
      }
    })
    }
  } catch(e) {
    
  }
  
}

上传云函数

3. 调用云函数

wx.cloud.callFunction({
  name: '云函数名字',
  data: {
  x: 1,
  y: 2,
  },
  succcess: res => {
    // res.result
  },
  fail: err => {
  
  }
})

4. 云函数服务

添加服务逻辑部分，将返回结果放入结果中返回小程序

5. 结果处理

在小程序端，JSON等方式处理返回的结果集

6. 云数据库

创建云数据库后初始化数据库，在小程序端
const db = wx.cloud.database({});
const book = db.collection('book');//连接book的数据库

var bookString = ''

db.collection('books').add({
  data: JSON.parse(bookString)
}).then(res => {
  console.log(res)
}).catch(err => {
  console.error(err)
})

查询结果显示
const db = wx.cloud.database({})
const cont = db.collection('books')

Page({
  data: {
    book_list: []
  },
  onLoad: function(options) {
    var _this = this
    db.collection('books').get({
      success(res) {
        console.log(res.data)
        console.log(this)
        this.setData({
          book_list: res.data
        })
      }
    })
  }
})

wxml:

<view wx:for="book_list">
{{item.price}}
</view>

7. 列表到详情跳转

wxml:
<van-button data-id="{{item.id}}" bind:click="detail">
  
detail: function(event) {
  var id = event.currentTarget.dataset.id;
  
  wx.navigateTo({
    url: '../../details/details?id=' +id,
  })
}


onLoad里面
console.log(options.id)
