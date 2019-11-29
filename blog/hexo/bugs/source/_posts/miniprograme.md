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
```
var app = getApp();

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

app.js

App({
    //全局数据
    globalData: {
        //用户ID
        userId: "",
        //用户信息
        userInfo: null,
        //授权状态
        auth: {
            "scope.userInfo": false
        },
        //登录状态
        logged: false
    },
    onLaunch: function onLaunch() {
        if (!wx.cloud) {
            console.error("请使用 2.2.3 或以上的基础库以使用云能力");
        } else {
            wx.cloud.init({
                env: "ourtalk",
                //环境ID，
                traceUser: true
            });
        }
        this.globalData = {};
    }
});
```

业务代码

```
// pages/me/index/index.js
var app = getApp();

Page({
  /**
 * 页面的初始数据
 */
  data: {
    userInfoGridStatus: "false",
    openid: "",
    isHide: true
  },
  /**
 * 生命周期函数--监听页面加载
 */
  onLoad: function onLoad(options) {
    this.getOpenid();
    var openid = this.data.openid,
    userId = wx.getStorageSync("userId"), 
    userImg = wx.getStorageSync("userImg"), 
    userName = wx.getStorageSync("userName");
    if (userId) {
      this.setData({
        isHide: false,
        userName: userName,
        userImg: userImg,
        userId: userId
      });
    }
  },
  /**
 * 生命周期函数--监听页面显示
 */
  onShow: function onShow(options) { },
  /**
 * 生命周期函数--监听页面卸载
 */
  onUnload: function onUnload() { },
  onHelpClick: function onHelpClick() {
    wx.navigateTo({
      url: "../../About/meAbout/meAbout"
    });
  },
  onSetClick: function onSetClick() {
    wx.navigateTo({
      url: "../../set/index/index"
    });
  },
  //授权
  getUserInfoClick: function getUserInfoClick(e) {
    var _this = this;
    console.log(e);
    var d = e.detail.userInfo;
    this.setData({
      userImg: d.avatarUrl,
      userName: d.nickName,
      isHide: false
    });
    wx.setStorageSync("userName", d.nickName);
    wx.setStorageSync("userImg", d.avatarUrl);
    var db = wx.cloud.database();
    var _ = db.command;
    db.collection("user").where({
      _openid: this.data.openid
    }).get({
      success: function success(res) {
        console.log("查询用户:", res);
        if (res.data && res.data.length > 0) {
          console.log("已存在");
          wx.setStorageSync("userId", res.data[0].userId);
          wx.setStorageSync("openId", res.data[0]._openid);
          console.log(res.data[0].userId);
        } else {
          setTimeout(function () {
            var userImg = d.avatarUrl,
              userName = d.nickName,
              userId;
            if (!userId) {
              userId = _this.getUserId();
            }
            // db.collection("user").add({
            //   data: {
            //     userId: userId,
            //     userImg: userImg,
            //     userName: userName,
            //     iv: d.iv
            //   },
            wx.cloud.callFunction({
              name: 'addUser',
              data: {
                userId: userId,
                userImg: userImg,
                userName: userName,
              },
              success: function success(res) {
                wx.showToast({
                  title: "注册成功"
                });
                console.log('云addUser: ', res,res.result.openid)
                console.log("用户新增成功");
                db.collection("users").where({
                  userId: userId
                }).get({
                  success: function success(res) {
                    wx.setStorageSync("openId", res.data[0]._openid);
                  },
                  fail: function fail(err) {
                    console.log("openId缓存失败");
                  }
                });
              }
            });
          }, 100);
        }
      }
    });
    this.onLoad();
  },
  // 获取用户openid
  getOpenid: function getOpenid() {
    var _this2 = this;
    // let that = this;
    wx.cloud.callFunction({
      name: "getOpenId",
      complete: function complete(res) {
        console.log("云函数获取到的openid: ", res.result.openId);
        var openid = res.result.openId;
        _this2.setData({
          openid: openid
        });
        console.log(_this2.data.openid);
      }
    });
  },
  getUserId: function getUserId() {
    // var w = "abcdefghijklmnopqrstuvwxyz0123456789",
    //   firstW = w[parseInt(Math.random() * (w.length))];
    var firstW = "user";
    var userId = firstW + Date.now() + (Math.random() * 1e5).toFixed(0);
    console.log(userId);
    wx.setStorageSync("userId", userId);
    return userId;
  },
  toMyComment: function toMyComment(e) {
    wx.navigateTo({
      url: "../myComment/myComment?userId=" + e.currentTarget.dataset.userId
    });
  },
  toMyTopic: function toMyTopic(e) {
    wx.navigateTo({
      url: "../myTopic/myTopic?userId=" + e.currentTarget.dataset.userId
    });
  }
});
```


util.js
```
const formatTime = date => {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  const hour = date.getHours()
  const minute = date.getMinutes()
  const second = date.getSeconds()

  return [year, month, day].map(formatNumber).join('/') + ' ' + [hour, minute, second].map(formatNumber).join(':')
}

const formatNumber = n => {
  n = n.toString()
  return n[1] ? n : '0' + n
}

module.exports = {
  formatTime: formatTime
}
```

表单提交
```
js

// 提交表单
  formSubmit(e) {
    let params = Object.assign({}, e.detail.value, {
      cityId: this.data.cityId,
      cityName: this.data.cityName,
      countryId: this.data.countryId,
      provinceId: this.data.provinceId,
      countryName: this.data.countryName,
      provinceName: this.data.provinceName
    });
    if (this.options._id) params._id = this.options._id;
    app.store.cloudApi.updateAddress(params).then(r => {
      if (r.code === 0) {
        wx.navigateBack({
          delta: 1
        })
      }
    })
    
wsml

<form bindsubmit="formSubmit">
    <view class='upt-item'>
      <input class='upt-unit' name="name" placeholder="姓名" value="{{defaultInfo.name}}"/>
    </view>
    <view class='upt-item'>
      <input class='upt-unit' name="phone" placeholder="手机号码" value="{{defaultInfo.phone}}"/>
    </view>
    <view class='upt-item'>
      <input class='upt-unit' name="area" placeholder="省份、城市、区县" value="{{defaultInfo.area}}" disabled bindtap="showModal"/>
    </view>
    <view class='upt-item'>
      <input class='upt-unit' name="address" placeholder="详细地址，如楼道、楼盘号等" value="{{defaultInfo.address}}"/>
    </view>
    <!-- <view class='upt-item'>
      <radio-group class='upt-unit upt-default' name="radio-group">
        <label>
          <radio value="1"/>设为默认地址
        </label>
      </radio-group>
    </view> -->
    <view class='upt-btn'>
      <button formType="submit">保存</button>
    </view>
  </form>
```
