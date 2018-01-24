# 改造renren开源项目

1.日期处理

在实体对象中日期类型

```java
@JsonFormat(pattern = "yyyy-MM-dd")
private Date startDate;
```

日期控件

```html
<el-date-picker
      v-model="endDate"
      type="date"
      format="yyyy 年 MM 月 dd 日"
      placeholder="选择日期">
</el-date-picker>
```

2.引入element-ui的元素

```html项目
<!-- 引入样式 -->
<link rel="stylesheet" href="../../plugins/element-ui/lib/theme-chalk/index.css">
<!-- 引入组件库 -->
<script src="../../plugins/element-ui/lib/index.js"></script>
```

3.修改HTML中grid的属性

```javascript
  {label: 'supplierId', name: 'supplierId', index: 'supplier_id', width: 50, key: true, hidden: true},
```

4.配置格式化

```javascript
{
                label: '状态',
                name: 'status',
                index: 'status',
                width: 80,
                formatter: function (cellvalue, options, rowObject) {
                    var temp = "";
                    if (cellvalue == 0) {
                        temp = temp + "New";
                    } else if (cellvalue == 1) {
                        temp = temp + "Activity";
                    } else {
                        temp = temp + "None";
                    }
                    // temp = temp + "' border =’0′ />"
                    return temp;
                }
            },
```

5.动态加载参数

```javascript
getInfo: function (productId) {
            $.get(baseURL + "drp/product/info/" + productId, function (r) {
                vm.product = r.product;
                vm.catalogValue = r.product.catalog;
            });
            vm.getCatalog();

        },
        reload: function (event) {
            vm.showList = true;
            var page = $("#jqGrid").jqGrid('getGridParam', 'page');
            $("#jqGrid").jqGrid('setGridParam', {
                page: page
            }).trigger("reloadGrid");
        },
        getCatalog: function () {
            $.get(baseURL + "drp/catalog/getOpt", function (r) {
                vm.catalogs = r;
            });
        }
```

6.下拉菜单

```html
<el-select v-model="supplierIdValue" clearable placeholder="请选择">
                        <el-option
                                v-for="item in supplierOpns"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value">
                        </el-option>
                    </el-select>
```

```java
public class Option {
    private Long value;
    private String label;

    public Option(Long value, String label) {
        this.label = label;
        this.value = value;
    }

    public Long getValue() {
        return value;
    }

    public void setValue(Long value) {
        this.value = value;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }
}
```

7.TextArea控件

```html
<el-input type="textarea" v-model="catalog.remark"></el-input>
```

8.数字控件

```html
<el-input-number v-model="quantity" @change="handleChange" :min="1" label="数量"></el-input-number>
```
