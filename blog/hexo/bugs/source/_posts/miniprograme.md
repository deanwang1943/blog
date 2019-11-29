# 小程序-记录

### 云函数

1. 新建云函数

新建bookinfo的云函数文件

> tip:安装三方库npm install --save request npm install --save request-promise (异步请求)

2. 云函数编写

通过event来拿到对应的数据
```
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
 ``` 
}

上传云函数

3. 调用云函数
```
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
```
4. 云函数服务

添加服务逻辑部分，将返回结果放入结果中返回小程序

5. 结果处理

在小程序端，JSON等方式处理返回的结果集

6. 云数据库

创建云数据库后初始化数据库，在小程序端
```
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
```
查询结果显示
```
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
```

7. 列表到详情跳转
```
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
```


## 实列代码

首页js

Page({
    data: {
        avatarUrl: "./user-unlogin.png",
        userInfo: {},
        logged: false,
        takeSession: false,
        requestResult: ""
    },
    onLoad: function onLoad() {
        var _this = this;
        if (!wx.cloud) {
            wx.redirectTo({
                url: "../chooseLib/chooseLib"
            });
            return;
        }
        // 获取用户信息
        wx.getSetting({
            success: function success(res) {
                if (res.authSetting["scope.userInfo"]) {
                    // 已经授权，可以直接调用 getUserInfo 获取头像昵称，不会弹框
                    wx.getUserInfo({
                        success: function success(res) {
                            _this.setData({
                                avatarUrl: res.userInfo.avatarUrl,
                                userInfo: res.userInfo
                            });
                        }
                    });
                }
            }
        });
    },
    onGetUserInfo: function onGetUserInfo(e) {
        if (!this.logged && e.detail.userInfo) {
            this.setData({
                logged: true,
                avatarUrl: e.detail.userInfo.avatarUrl,
                userInfo: e.detail.userInfo
            });
        }
    },
    onGetOpenid: function onGetOpenid() {
        // 调用云函数
        wx.cloud.callFunction({
            name: "login",
            data: {},
            success: function success(res) {
                console.log("[云函数] [login] user openid: ", res.result.openid);
                app.globalData.openid = res.result.openid;
                wx.navigateTo({
                    url: "../userConsole/userConsole"
                });
            },
            fail: function fail(err) {
                console.error("[云函数] [login] 调用失败", err);
                wx.navigateTo({
                    url: "../deployFunctions/deployFunctions"
                });
            }
        });
    },
    // 上传图片
    doUpload: function doUpload() {
        // 选择图片
        wx.chooseImage({
            count: 1,
            sizeType: [ "compressed" ],
            sourceType: [ "album", "camera" ],
            success: function success(res) {
                wx.showLoading({
                    title: "上传中"
                });
                var filePath = res.tempFilePaths[0];
                // 上传图片
                                var cloudPath = "my-image" + filePath.match(/\.[^.]+?$/)[0];
                wx.cloud.uploadFile({
                    cloudPath: cloudPath,
                    filePath: filePath,
                    success: function success(res) {
                        console.log("[上传文件] 成功：", res);
                        app.globalData.fileID = res.fileID;
                        app.globalData.cloudPath = cloudPath;
                        app.globalData.imagePath = filePath;
                        wx.navigateTo({
                            url: "../storageConsole/storageConsole"
                        });
                    },
                    fail: function fail(e) {
                        console.error("[上传文件] 失败：", e);
                        wx.showToast({
                            icon: "none",
                            title: "上传失败"
                        });
                    },
                    complete: function complete() {
                        wx.hideLoading();
                    }
                });
            },
            fail: function fail(e) {
                console.error(e);
            }
        });
    }
});
